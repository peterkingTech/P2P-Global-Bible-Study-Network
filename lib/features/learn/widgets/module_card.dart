import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/module_model.dart';
import '../../../shared/widgets/custom_button.dart';

/// Full or compact module card used in the journey list.
class ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final VoidCallback onOpen;
  final bool compact;

  const ModuleCard({
    super.key,
    required this.module,
    required this.onOpen,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !module.isUnlocked;

    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: Container(
        padding: EdgeInsets.all(compact ? 12.r : 16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderBeige),
        ),
        child: compact ? _CompactContent(module: module) : _FullContent(module: module, onOpen: onOpen),
      ),
    );
  }
}

class _CompactContent extends StatelessWidget {
  final ModuleModel module;
  const _CompactContent({required this.module});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusDot(module: module),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                module.title,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              SizedBox(height: 2.h),
              Text(
                '${module.completedLessons}/${module.totalLessons} lessons',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        // Progress pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            '${(module.progress * 100).round()}%',
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }
}

class _FullContent extends StatelessWidget {
  final ModuleModel module;
  final VoidCallback onOpen;
  const _FullContent({required this.module, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatusDot(module: module),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                module.title,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          module.description,
          style: TextStyle(
              fontSize: 13.sp, height: 1.55, color: AppColors.textMid),
        ),
        SizedBox(height: 12.h),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            value: module.progress,
            minHeight: 6.h,
            backgroundColor: AppColors.borderBeige,
            valueColor:
                const AlwaysStoppedAnimation(AppColors.accentGreen),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '${module.completedLessons} of ${module.totalLessons} lessons complete',
          style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
        ),
        SizedBox(height: 14.h),
        AppButton(
          label: module.isComplete ? 'Review module' : 'Continue',
          onPressed: module.isUnlocked ? onOpen : null,
          compact: true,
        ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  final ModuleModel module;
  const _StatusDot({required this.module});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    if (module.isComplete) {
      color = AppColors.accentGreen;
      icon = Icons.check_circle;
    } else if (!module.isUnlocked) {
      color = AppColors.borderBeige;
      icon = Icons.lock;
    } else {
      color = AppColors.amber;
      icon = Icons.radio_button_checked;
    }
    return Icon(icon, size: 18.sp, color: color);
  }
}
