import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/lesson_model.dart';

/// A single lesson row inside a module detail.
class LessonListItem extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final VoidCallback onTap;

  const LessonListItem({
    super.key,
    required this.lesson,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Lesson ${index + 1}: ${lesson.title}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderBeige),
          ),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lesson.isCompleted
                      ? AppColors.accentGreen
                      : AppColors.borderBeige,
                ),
                alignment: Alignment.center,
                child: lesson.isCompleted
                    ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMid),
                      ),
              ),

              SizedBox(width: 12.w),

              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (lesson.subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        lesson.subtitle!,
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Duration + type icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TypeIcon(type: lesson.type),
                  SizedBox(height: 2.h),
                  Text(
                    '~${lesson.estimatedMinutes}m',
                    style: TextStyle(
                        fontSize: 10.sp, color: AppColors.textMuted),
                  ),
                ],
              ),

              SizedBox(width: 6.w),
              Icon(Icons.chevron_right,
                  size: 18.sp, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final LessonType type;
  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      LessonType.reading => (Icons.menu_book_outlined, AppColors.textMuted),
      LessonType.video => (Icons.play_circle_outline, AppColors.amber),
      LessonType.discussion => (Icons.forum_outlined, AppColors.accentGreen),
      LessonType.memorisation => (Icons.psychology_outlined, AppColors.primaryGreen),
      LessonType.practicum => (Icons.handshake_outlined, AppColors.amber),
    };
    return Icon(icon, size: 16.sp, color: color);
  }
}
