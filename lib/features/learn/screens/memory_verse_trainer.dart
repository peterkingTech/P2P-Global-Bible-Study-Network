import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../shared/widgets/custom_button.dart';

/// Stand-alone Memory Verse Trainer screen (deep-linked from GoRouter).
/// Also exposes [VerseFlipCard] as a reusable widget for the lesson view.
class MemoryVerseTrainer extends StatefulWidget {
  final String verseId;
  const MemoryVerseTrainer({super.key, required this.verseId});

  @override
  State<MemoryVerseTrainer> createState() => _MemoryVerseTrainerState();
}

class _MemoryVerseTrainerState extends State<MemoryVerseTrainer> {
  _Mode _mode = _Mode.flip;

  // TODO: fetch verse by ID from lessonProvider
  String get _verse =>
      'I am the vine; you are the branches. Whoever abides in me and I in him, '
      'he it is that bears much fruit, for apart from me you can do nothing.';
  String get _ref => 'John 15:5';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          'Memory Verse',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            // Mode selector
            Container(
              decoration: BoxDecoration(
                color: AppColors.borderBeige,
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.all(3.r),
              child: Row(
                children: _Mode.values.map((m) {
                  final active = _mode == m;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.primaryGreen
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 28.h),

            // Content by mode
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildMode(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMode() {
    switch (_mode) {
      case _Mode.flip:
        return VerseFlipCard(verse: _verse, reference: _ref, key: const ValueKey('flip'));
      case _Mode.practice:
        return _PracticeMode(verse: _verse, reference: _ref, key: const ValueKey('practice'));
      case _Mode.test:
        return _TestMode(verse: _verse, reference: _ref, key: const ValueKey('test'));
    }
  }
}

enum _Mode {
  flip('Flip card'),
  practice('Practice'),
  test('Test');

  final String label;
  const _Mode(this.label);
}

// ── Flip card ─────────────────────────────────────────────────────────────────

class VerseFlipCard extends StatefulWidget {
  final String verse;
  final String reference;
  const VerseFlipCard({
    super.key,
    required this.verse,
    required this.reference,
  });

  @override
  State<VerseFlipCard> createState() => _VerseFlipCardState();
}

class _VerseFlipCardState extends State<VerseFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;
  late final Animation<double> _rotation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _rotation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flip, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _doFlip() {
    if (_flip.isAnimating) return;
    if (_showFront) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _doFlip,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (_, __) {
          final angle = _rotation.value * 3.14159;
          final showingFront = _rotation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: showingFront
                ? _CardFace(
                    color: AppColors.primaryGreen,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '"${widget.verse}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontStyle: FontStyle.italic,
                            height: 1.7,
                            color: AppColors.cream,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Tap to see reference →',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.lightGreen.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                    child: _CardFace(
                      color: AppColors.amber,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📖', style: TextStyle(fontSize: 40.sp)),
                          SizedBox(height: 12.h),
                          Text(
                            widget.reference,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap to flip back',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final Color color;
  final Widget child;
  const _CardFace({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 220.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Practice mode (word-by-word reveal) ──────────────────────────────────────

class _PracticeMode extends StatefulWidget {
  final String verse;
  final String reference;
  const _PracticeMode({super.key, required this.verse, required this.reference});
  @override
  State<_PracticeMode> createState() => _PracticeModeState();
}

class _PracticeModeState extends State<_PracticeMode> {
  int _revealedWords = 0;
  late final List<String> _words;

  @override
  void initState() {
    super.initState();
    _words = widget.verse.split(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 5.w,
              runSpacing: 6.h,
              children: _words.asMap().entries.map((e) {
                final revealed = e.key < _revealedWords;
                return GestureDetector(
                  onTap: () {
                    if (!revealed) setState(() => _revealedWords = e.key + 1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: revealed
                          ? Colors.transparent
                          : AppColors.borderBeige,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      revealed ? e.value : '▓' * e.value.length,
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.6,
                        color: revealed
                            ? AppColors.textDark
                            : AppColors.borderBeige,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Reveal next word',
                onPressed: _revealedWords < _words.length
                    ? () => setState(() => _revealedWords++)
                    : null,
                compact: true,
              ),
            ),
            SizedBox(width: 12.w),
            OutlinedButton(
              onPressed: () => setState(() => _revealedWords = 0),
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Test mode (type from memory) ──────────────────────────────────────────────

class _TestMode extends StatefulWidget {
  final String verse;
  final String reference;
  const _TestMode({super.key, required this.verse, required this.reference});
  @override
  State<_TestMode> createState() => _TestModeState();
}

class _TestModeState extends State<_TestMode> {
  final _ctrl = TextEditingController();
  bool _submitted = false;
  double? _accuracy;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _check() {
    final input = _ctrl.text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final original =
        widget.verse.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final inputWords = input.split(RegExp(r'\s+'));
    final originalWords = original.split(RegExp(r'\s+'));
    var matches = 0;
    for (var i = 0; i < inputWords.length && i < originalWords.length; i++) {
      if (inputWords[i] == originalWords[i]) matches++;
    }
    setState(() {
      _submitted = true;
      _accuracy = matches / originalWords.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Type the verse from memory (${widget.reference}):',
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: TextField(
            controller: _ctrl,
            enabled: !_submitted,
            maxLines: null,
            expands: true,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Start typing…',
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderBeige),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderBeige),
              ),
              contentPadding: EdgeInsets.all(16.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (_submitted && _accuracy != null) ...[
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: _accuracy! >= 0.9
                  ? AppColors.accentGreen.withOpacity(0.1)
                  : AppColors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _accuracy! >= 0.9
                    ? AppColors.accentGreen
                    : AppColors.amber,
              ),
            ),
            child: Text(
              _accuracy! >= 0.9
                  ? '🎉 ${(_accuracy! * 100).round()}% accuracy — excellent!'
                  : '${(_accuracy! * 100).round()}% accuracy — keep practising!',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _accuracy! >= 0.9
                    ? AppColors.primaryGreen
                    : AppColors.amber,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          AppButton(
            label: 'Try again',
            onPressed: () => setState(() {
              _submitted = false;
              _accuracy = null;
              _ctrl.clear();
            }),
          ),
        ] else
          AppButton(
            label: 'Check my answer',
            onPressed: _ctrl.text.trim().isEmpty ? null : _check,
          ),
      ],
    );
  }
}
