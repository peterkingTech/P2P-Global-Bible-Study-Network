import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import 'custom_button.dart';

/// Full-screen error display with optional retry button.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? emoji;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji ?? '⚠️',
              style: TextStyle(fontSize: 48.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.6,
                color: AppColors.textDark,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              AppButton(
                label: 'Try again',
                onPressed: onRetry,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
