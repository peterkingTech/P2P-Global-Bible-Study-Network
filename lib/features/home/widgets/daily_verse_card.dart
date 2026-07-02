import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

// ── Static verse data (replace with Supabase fetch in production) ─────────────

const _kVerses = [
  (
    text:
        'I am the vine; you are the branches. Whoever abides in me and I in him, he it is that bears much fruit.',
    ref: 'John 15:5',
  ),
  (
    text:
        'And let us consider how to stir up one another to love and good works.',
    ref: 'Hebrews 10:24',
  ),
  (
    text:
        'Go therefore and make disciples of all nations, baptising them in the name of the Father and of the Son and of the Holy Spirit.',
    ref: 'Matthew 28:19',
  ),
];

/// Displays the verse of the day in a warm card.
class DailyVerseCard extends StatelessWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Pick verse by day-of-year so it rotates daily
    final dayOfYear = DateTime.now().difference(
          DateTime(DateTime.now().year, 1, 1),
        ).inDays;
    final verse = _kVerses[dayOfYear % _kVerses.length];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderBeige),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Verse of the day',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '"${verse.text}"',
            style: TextStyle(
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              height: 1.65,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${verse.ref}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
