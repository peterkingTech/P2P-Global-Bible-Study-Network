import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/user_model.dart';

const _kGifts = <(SpiritualGift, String, String)>[
  (SpiritualGift.teaching, '📖', 'Teaching'),
  (SpiritualGift.evangelism, '📢', 'Evangelism'),
  (SpiritualGift.mercy, '💚', 'Mercy'),
  (SpiritualGift.leadership, '🏔️', 'Leadership'),
  (SpiritualGift.intercession, '🙏', 'Intercession'),
  (SpiritualGift.hospitality, '🏠', 'Hospitality'),
  (SpiritualGift.giving, '🎁', 'Giving'),
  (SpiritualGift.prophecy, '🔥', 'Prophecy'),
];

/// Grid letting the user choose 1-3 spiritual gifts.
class GiftSelectionGrid extends StatelessWidget {
  final Set<SpiritualGift> selected;
  final ValueChanged<SpiritualGift> onToggle;

  const GiftSelectionGrid({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What gifts has God given you?',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.cream,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Choose up to 3 gifts. These help us match you with believers you can serve.',
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.5,
            color: AppColors.lightGreen.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 20.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 2.2,
          children: _kGifts.map((g) {
            final (gift, emoji, label) = g;
            final isSelected = selected.contains(gift);
            final atMax = selected.length >= 3 && !isSelected;

            return Semantics(
              toggled: isSelected,
              label: label,
              button: true,
              child: GestureDetector(
                onTap: atMax ? null : () => onToggle(gift),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentGreen.withOpacity(0.15)
                        : Colors.white.withOpacity(atMax ? 0.02 : 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentGreen
                          : Colors.white.withOpacity(atMax ? 0.06 : 0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: TextStyle(fontSize: 20.sp)),
                      SizedBox(width: 8.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.lightGreen
                              : AppColors.cream.withOpacity(atMax ? 0.3 : 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
