import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/providers/smart_match_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../mentor/widgets/peer_profile_card.dart';

// ── Quiz questions ─────────────────────────────────────────────────────────────

const _kQuestions = [
  (
    question: 'When do you prefer to study?',
    options: ['Morning (6–9am)', 'Midday (11am–1pm)', 'Evening (6–8pm)', 'Night (8–10pm)', 'Flexible'],
  ),
  (
    question: 'What matters most to you in a peer?',
    options: ['Same language', 'Same timezone', 'Similar background', 'Complementary gifts', 'Just anyone available'],
  ),
  (
    question: 'How comfortable are you with video calls?',
    options: ['Prefer video', 'Audio only is fine', 'Text / chat only', 'Mix is fine'],
  ),
];

/// Smart Match — 3-question wizard, then top-3 results.
class SmartMatchScreen extends ConsumerStatefulWidget {
  const SmartMatchScreen({super.key});

  @override
  ConsumerState<SmartMatchScreen> createState() => _SmartMatchScreenState();
}

class _SmartMatchScreenState extends ConsumerState<SmartMatchScreen> {
  final List<String?> _answers = List.filled(_kQuestions.length, null);
  int _step = 0; // 0.._kQuestions.length-1 = quiz; _kQuestions.length = results

  bool get _quizComplete =>
      _answers.every((a) => a != null) && _step >= _kQuestions.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          'Smart Match',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: _step < _kQuestions.length
              ? _QuizStep(
                  questionIndex: _step,
                  total: _kQuestions.length,
                  selected: _answers[_step],
                  onSelect: (opt) => setState(() => _answers[_step] = opt),
                  onNext: _answers[_step] != null
                      ? () => setState(() => _step++)
                      : null,
                )
              : _ResultsStep(answers: _answers.cast<String>()),
        ),
      ),
    );
  }
}

class _QuizStep extends StatelessWidget {
  final int questionIndex;
  final int total;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback? onNext;

  const _QuizStep({
    required this.questionIndex,
    required this.total,
    required this.selected,
    required this.onSelect,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final q = _kQuestions[questionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress
        Row(
          children: [
            Text(
              'Question ${questionIndex + 1} of $total',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999.r),
                child: LinearProgressIndicator(
                  value: (questionIndex + 1) / total,
                  minHeight: 4.h,
                  backgroundColor: AppColors.borderBeige,
                  valueColor: const AlwaysStoppedAnimation(
                      AppColors.primaryGreen),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 28.h),

        Text(
          q.question,
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),

        SizedBox(height: 20.h),

        Expanded(
          child: ListView(
            children: q.options.map((opt) {
              final active = selected == opt;
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: GestureDetector(
                  onTap: () => onSelect(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryGreen
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: active
                            ? AppColors.primaryGreen
                            : AppColors.borderBeige,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: active
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                        if (active)
                          Icon(Icons.check_circle,
                              size: 18.sp, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 12.h),
        AppButton(
          label: questionIndex < _kQuestions.length - 1 ? 'Next →' : 'Find my matches',
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _ResultsStep extends ConsumerWidget {
  final List<String> answers;
  const _ResultsStep({required this.answers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(smartMatchResultsProvider(answers));

    return matchesAsync.when(
      loading: () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔍', style: TextStyle(fontSize: 40.sp)),
          SizedBox(height: 16.h),
          Text('Finding your best matches…',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          SizedBox(height: 20.h),
          const LoadingSkeleton(),
        ],
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No matches yet — check back soon!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.sp, color: AppColors.textDark)),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your top ${matches.length} matches',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            SizedBox(height: 8.h),
            Text('Select someone to send a request.',
                style: TextStyle(
                    fontSize: 13.sp, color: AppColors.textMuted)),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.separated(
                itemCount: matches.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, i) => PeerProfileCard(
                  peer: matches[i].user,
                  compatibilityScore: matches[i].score,
                  onRequest: () {
                    // TODO: send match request
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
