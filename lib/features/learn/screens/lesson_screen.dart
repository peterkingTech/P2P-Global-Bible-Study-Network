import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/models/lesson_model.dart';
import '../../../core/providers/lesson_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import 'memory_verse_trainer.dart';

/// Five-tab lesson view: Verse · Content · Questions · Assignment · Checkpoint
class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  double _readProgress = 0.0;
  final _reflectionCtrl = TextEditingController();
  final List<TextEditingController> _questionCtrls =
      List.generate(5, (_) => TextEditingController());
  bool _assignmentChecked = false;

  static const _kTabLabels = [
    'Verse',
    'Content',
    'Questions',
    'Assignment',
    'Checkpoint',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    AnalyticsService.lessonStarted(widget.lessonId);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _reflectionCtrl.dispose();
    for (final c in _questionCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonProvider(widget.lessonId));

    return lessonAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.cream,
        body: LoadingSkeleton(),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (lesson) {
        if (lesson == null) {
          return const Scaffold(
              body: Center(child: Text('Lesson not found')));
        }
        return _LessonBody(
          lesson: lesson,
          tabs: _tabs,
          readProgress: _readProgress,
          onReadProgress: (p) => setState(() => _readProgress = p),
          reflectionCtrl: _reflectionCtrl,
          questionCtrls: _questionCtrls,
          assignmentChecked: _assignmentChecked,
          onAssignmentToggled: (v) => setState(() => _assignmentChecked = v),
          tabLabels: _kTabLabels,
          onComplete: () async {
            await ref.read(lessonProgressNotifierProvider.notifier)
                .markComplete(lesson.id, lesson.moduleId);
            if (context.mounted) context.pop();
          },
        );
      },
    );
  }
}

class _LessonBody extends StatelessWidget {
  final LessonModel lesson;
  final TabController tabs;
  final double readProgress;
  final ValueChanged<double> onReadProgress;
  final TextEditingController reflectionCtrl;
  final List<TextEditingController> questionCtrls;
  final bool assignmentChecked;
  final ValueChanged<bool> onAssignmentToggled;
  final List<String> tabLabels;
  final VoidCallback onComplete;

  const _LessonBody({
    required this.lesson,
    required this.tabs,
    required this.readProgress,
    required this.onReadProgress,
    required this.reflectionCtrl,
    required this.questionCtrls,
    required this.assignmentChecked,
    required this.onAssignmentToggled,
    required this.tabLabels,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(58.h),
          child: Column(
            children: [
              // Read-progress bar
              LinearProgressIndicator(
                value: readProgress,
                backgroundColor: AppColors.borderBeige,
                valueColor: const AlwaysStoppedAnimation(AppColors.accentGreen),
                minHeight: 2,
              ),
              TabBar(
                controller: tabs,
                isScrollable: true,
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primaryGreen,
                labelStyle: TextStyle(
                    fontSize: 12.sp, fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(fontSize: 12.sp),
                tabs: tabLabels
                    .map((l) => Tab(text: l))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabs,
        children: [
          // ── Tab 1: Memory Verse ────────────────────────────────────────
          _VerseTab(
            verse: lesson.memoryVerse ?? '',
            reference: lesson.memoryVerseRef ?? '',
          ),

          // ── Tab 2: Content ─────────────────────────────────────────────
          _ContentTab(
            content: lesson.content,
            onProgress: onReadProgress,
          ),

          // ── Tab 3: Discussion questions ────────────────────────────────
          _QuestionsTab(controllers: questionCtrls),

          // ── Tab 4: Assignment ──────────────────────────────────────────
          _AssignmentTab(
            checked: assignmentChecked,
            onToggle: onAssignmentToggled,
            reflectionCtrl: reflectionCtrl,
          ),

          // ── Tab 5: Checkpoint ──────────────────────────────────────────
          _CheckpointTab(
            rubric: lesson.checkpointRubric ?? '',
            onComplete: onComplete,
          ),
        ],
      ),
    );
  }
}

// ── Tab views ─────────────────────────────────────────────────────────────────

class _VerseTab extends StatelessWidget {
  final String verse;
  final String reference;
  const _VerseTab({required this.verse, required this.reference});

  @override
  Widget build(BuildContext context) {
    if (verse.isEmpty) {
      return Center(
        child: Text('No memory verse for this lesson.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted)),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          // Flip card trainer
          VerseFlipCard(verse: verse, reference: reference),
          SizedBox(height: 24.h),
          Text(
            'Practice: hide the text and try to recite from memory.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ContentTab extends StatefulWidget {
  final String content;
  final ValueChanged<double> onProgress;
  const _ContentTab({required this.content, required this.onProgress});
  @override
  State<_ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<_ContentTab> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollCtrl.position.maxScrollExtent;
    if (max <= 0) return;
    widget.onProgress((_scrollCtrl.offset / max).clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: EdgeInsets.all(24.r),
      child: Text(
        widget.content,
        style: TextStyle(
          fontSize: 15.sp,
          height: 1.75,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _QuestionsTab extends StatelessWidget {
  final List<TextEditingController> controllers;
  const _QuestionsTab({required this.controllers});

  static const _kQuestions = [
    'What stood out most to you in this lesson?',
    'How does this truth apply to your daily life?',
    'What questions does this raise for you?',
    'Share an example from your own story that relates.',
    'What is one thing you want to put into practice this week?',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(20.r),
      itemCount: _kQuestions.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (_, i) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${i + 1}. ${_kQuestions[i]}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controllers[i],
            maxLines: 3,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Write your thoughts…',
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
              contentPadding: EdgeInsets.all(12.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentTab extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onToggle;
  final TextEditingController reflectionCtrl;
  const _AssignmentTab({
    required this.checked,
    required this.onToggle,
    required this.reflectionCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Life Assignment',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          SizedBox(height: 8.h),
          Text(
            'This week, share what you have learned with someone outside this app. Document your experience below.',
            style: TextStyle(
                fontSize: 14.sp, height: 1.6, color: AppColors.textMid),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: () => onToggle(!checked),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    color: checked
                        ? AppColors.accentGreen
                        : Colors.transparent,
                    border: Border.all(
                      color: checked
                          ? AppColors.accentGreen
                          : AppColors.borderBeige,
                    ),
                  ),
                  child: checked
                      ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'I completed this assignment honestly',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Reflection (optional)',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMid),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: reflectionCtrl,
            maxLines: 5,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'What happened? What did you learn?',
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
              contentPadding: EdgeInsets.all(12.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckpointTab extends StatelessWidget {
  final String rubric;
  final VoidCallback onComplete;
  const _CheckpointTab({required this.rubric, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peer Checkpoint',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your peer guide will verify these criteria with you during your session.',
            style: TextStyle(
                fontSize: 13.sp, height: 1.6, color: AppColors.textMid),
          ),
          SizedBox(height: 20.h),
          if (rubric.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: const Border(
                  left: BorderSide(color: AppColors.accentGreen, width: 3),
                ),
              ),
              child: Text(
                rubric,
                style: TextStyle(
                    fontSize: 14.sp, height: 1.65, color: AppColors.textDark),
              ),
            ),
          SizedBox(height: 32.h),
          AppButton(
            label: 'Mark lesson complete ✓',
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }
}
