import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/curriculum_provider.dart';

class LessonReaderScreen extends ConsumerWidget {
  final String lessonId;

  const LessonReaderScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(lessonBlocksProvider(lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text("Lesson")),
      body: blocks.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final block = data[index];

            switch (block.type) {
              case "text":
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(block.content),
                );

              case "scripture":
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("📖 ${block.content}"),
                  ),
                );

              case "question":
                return ListTile(
                  title: Text("❓ ${block.content}"),
                );

              case "prayer":
                return ListTile(
                  title: Text("🙏 ${block.content}"),
                );

              default:
                return Text(block.content);
            }
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text("$e"),
      ),
    );
  }
}
