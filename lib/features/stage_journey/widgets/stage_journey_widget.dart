import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../models/growth_stage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StageJourneyWidget — mirrors stage-journey.tsx
// The full six-stage growth ladder for the P2P Global Bible Study Network.
// ─────────────────────────────────────────────────────────────────────────────

class StageJourneyWidget extends StatelessWidget {
  final GrowthMetrics metrics;

  const StageJourneyWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final growth = computeGrowth(metrics);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section heading
        Column(
          children: [
            Text(
              'The Six Stages of Growth',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.5,
                color: AppColors.amber,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'From a Dormant Seed to a Forest of Nations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
                height: 1.25,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Every disciple walks the same path. Your activity in the network moves you from one stage to the next — and each stage shelters more life than the last.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.6,
                color: AppColors.textMid,
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        // ── Stage list
        ...kGrowthStages.map((stage) {
          final isDone = stage.level < growth.level;
          final isCurrent = stage.level == growth.level;
          final isLocked = stage.level > growth.level;
          final threshold = kStageScoreThresholds[stage.level];

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _StageCard(
              stage: stage,
              growth: growth,
              isDone: isDone,
              isCurrent: isCurrent,
              isLocked: isLocked,
              threshold: threshold,
            ),
          );
        }),
      ],
    );
  }
}

// ── Stage Card ────────────────────────────────────────────────────────────────

class _StageCard extends StatelessWidget {
  final GrowthStage stage;
  final GrowthResult growth;
  final bool isDone;
  final bool isCurrent;
  final bool isLocked;
  final int threshold;

  const _StageCard({
    required this.stage,
    required this.growth,
    required this.isDone,
    required this.isCurrent,
    required this.isLocked,
    required this.threshold,
  });

  Color get _borderColor {
    if (isCurrent) return AppColors.accentGreen;
    if (isDone) return AppColors.borderBeige;
    return const Color(0xFFE7E0D0);
  }

  Color get _bgColor {
    if (isCurrent) return const Color(0xFFEEFAF4);
    if (isDone) return AppColors.lightCream;
    return const Color(0xFFF6F2E8);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.25),
                  blurRadius: 0,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      padding: EdgeInsets.all(14.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage image
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderBeige),
            ),
            clipBehavior: Clip.antiAlias,
            foregroundDecoration: isLocked
                ? BoxDecoration(
                    color: AppColors.stageLockedOverlay,
                    borderRadius: BorderRadius.circular(12.r),
                  )
                : null,
            child: ColorFiltered(
              colorFilter: isLocked
                  ? const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ])
                  : const ColorFilter.mode(
                      Colors.transparent, BlendMode.saturation),
              child: Image.asset(
                stage.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.accentGreen.withOpacity(0.20),
                  child: Center(
                    child: Text(stage.emoji,
                        style: TextStyle(fontSize: 28.sp)),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row
                Wrap(
                  spacing: 6.w,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(stage.emoji, style: TextStyle(fontSize: 16.sp)),
                    Text(
                      stage.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? AppColors.textMuted
                            : AppColors.primaryGreen,
                      ),
                    ),
                    _StageBadge(
                        isDone: isDone,
                        isCurrent: isCurrent,
                        isLocked: isLocked),
                  ],
                ),

                SizedBox(height: 4.h),

                Text(
                  stage.description,
                  style: TextStyle(
                      fontSize: 12.sp, height: 1.55, color: AppColors.textDark),
                ),

                SizedBox(height: 2.h),

                Text(
                  stage.verse,
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontStyle: FontStyle.italic,
                      color: AppColors.amber),
                ),

                // Progress bar for current stage
                if (isCurrent && !growth.isMax) ...[
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999.r),
                    child: LinearProgressIndicator(
                      value: growth.progress,
                      minHeight: 8.h,
                      backgroundColor: const Color(0xFFDFEEE7),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accentGreen),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${growth.toNext} more growth points to reach '
                    '${kGrowthStages[growth.level + 1].emoji} ${kGrowthStages[growth.level + 1].name}',
                    style: TextStyle(
                        fontSize: 10.sp, color: AppColors.textMid),
                  ),
                ],

                if (isLocked) ...[
                  SizedBox(height: 6.h),
                  Text(
                    'Unlocks at $threshold growth points',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stage Badge ───────────────────────────────────────────────────────────────

class _StageBadge extends StatelessWidget {
  final bool isDone;
  final bool isCurrent;
  final bool isLocked;

  const _StageBadge(
      {required this.isDone, required this.isCurrent, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    if (isCurrent) {
      return _Chip(
          label: 'You are here',
          bg: AppColors.accentGreen,
          fg: AppColors.cream);
    }
    if (isDone) {
      return _Chip(
          label: 'Reached',
          bg: AppColors.primaryGreen.withOpacity(0.10),
          fg: AppColors.primaryGreen);
    }
    if (isLocked) {
      return _Chip(
          label: 'Locked',
          bg: const Color(0xFFE7E0D0),
          fg: AppColors.textMuted);
    }
    return const SizedBox.shrink();
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10.sp, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
