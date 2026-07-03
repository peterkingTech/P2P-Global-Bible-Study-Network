import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../application/curriculum_provider.dart';
import '../application/lesson_progress_provider.dart';

class LessonReaderScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonReaderScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonReaderScreen> createState() =>
      _LessonReaderScreenState();
}

class _LessonReaderScreenState extends ConsumerState<LessonReaderScreen> {
  double _progress = 0;

  // Last percent value that was persisted to Supabase.
  int _lastPersistedPercent = -1;

  // Debounce timer — fires a write 2 s after the last scroll event.
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ── Local progress update (called on every scroll tick) ──────────────────

  void _handleScrollProgress(double value) {
    final percent = (value * 100).toInt();

    setState(() => _progress = value);

    // Update in-memory cache immediately for responsive UX.
    ref
        .read(lessonProgressProvider.notifier)
        .setProgress(widget.lessonId, percent);

    // Persist to Supabase only when progress moved ≥5 percentage points
    // OR after 2 s of scroll inactivity — whichever comes first.
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      _persistIfChanged(percent);
    });

    if ((percent - _lastPersistedPercent).abs() >= 5) {
      _debounce?.cancel();
      _persistIfChanged(percent);
    }
  }

  void _persistIfChanged(int percent) {
    if (percent == _lastPersistedPercent) return;
    _lastPersistedPercent = percent;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // Fire-and-forget; failures are non-fatal (progress is already cached
    // in memory and will be retried on next significant scroll change).
    ref
        .read(curriculumRepositoryProvider)
        .updateLessonProgress(
          userId: userId,
          lessonId: widget.lessonId,
          percent: percent,
        )
        .ignore();
  }

  // ── Scroll notification handler ───────────────────────────────────────────

  bool _onScroll(ScrollNotification scroll) {
    final max = scroll.metrics.maxScrollExtent;

    if (max > 0) {
      final ratio = scroll.metrics.pixels / max;
      _handleScrollProgress(ratio.clamp(0.0, 1.0));
    } else {
      // Content fits entirely on screen — treat as fully read.
      _handleScrollProgress(1.0);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(lessonBlocksProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lesson"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: _progress),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: blocks.when(
          data: (data) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final block = data[index];

              switch (block.type) {
                case "text":
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      block.content,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );

                case "scripture":
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "📖 ${block.content}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );

                case "question":
                  return Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      title: Text("❓ ${block.content}"),
                    ),
                  );

                case "prayer":
                  return Card(
                    color: Colors.green.shade50,
                    child: ListTile(
                      title: Text("🙏 ${block.content}"),
                    ),
                  );

                default:
                  return Text(block.content);
              }
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("$e"),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () async {
            final userId =
                Supabase.instance.client.auth.currentUser?.id;

            if (userId != null) {
              final messenger = ScaffoldMessenger.of(context);

              await ref
                  .read(curriculumRepositoryProvider)
                  .markLessonComplete(userId, widget.lessonId);

              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text("Lesson Completed 🎉")),
                );
              }
            }
          },
          child: const Text("Mark as Complete"),
        ),
      ),
    );
  }
}
