import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../shared/widgets/custom_button.dart';

/// Card that nudges the user to start or schedule a peer study session.
class SessionPromptCard extends StatelessWidget {
  final VoidCallback onTap;
  const SessionPromptCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study together',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Find a peer and open the Word together.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.5,
                    color: AppColors.lightGreen.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 14.h),
                AppButton(
                  label: 'Find a partner',
                  onPressed: onTap,
                  compact: true,
                  variant: AppButtonVariant.outlined,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text('🤝', style: TextStyle(fontSize: 40.sp)),
        ],
      ),
    );
  }
}
