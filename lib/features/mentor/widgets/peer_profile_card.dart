import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/helpers.dart';
import '../../../features/living_tree/widgets/living_tree_widget.dart';
import '../../../shared/widgets/custom_button.dart';

/// Card shown in the discovery/matching flow for a potential peer.
class PeerProfileCard extends StatelessWidget {
  final UserModel peer;
  final double? compatibilityScore; // 0-1
  final VoidCallback? onRequest;
  final VoidCallback? onView;

  const PeerProfileCard({
    super.key,
    required this.peer,
    this.compatibilityScore,
    this.onRequest,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderBeige),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini tree
          LivingTreeWidget(level: peer.growthLevel, mini: true),
          SizedBox(width: 14.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        peer.displayName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (compatibilityScore != null)
                      _CompatibilityBadge(score: compatibilityScore!),
                  ],
                ),
                SizedBox(height: 2.h),
                if (peer.city != null || peer.country != null)
                  Text(
                    [peer.city, peer.country]
                        .whereType<String>()
                        .join(', '),
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.textMuted),
                  ),
                SizedBox(height: 6.h),
                // Gifts
                if (peer.gifts.isNotEmpty)
                  Wrap(
                    spacing: 5.w,
                    runSpacing: 4.h,
                    children: peer.gifts.take(3).map((g) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          g.name,
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primaryGreen),
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 10.h),
                // Level indicator
                Row(
                  children: [
                    Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: growthLevelColor(peer.growthLevel),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Level ${peer.growthLevel}',
                      style: TextStyle(
                          fontSize: 11.sp, color: AppColors.textMuted),
                    ),
                    if (peer.isPraying) ...[
                      SizedBox(width: 10.w),
                      Text('🙏',
                          style: TextStyle(fontSize: 12.sp)),
                      Text(
                        ' Praying now',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.accentGreen),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    if (onRequest != null)
                      Expanded(
                        child: AppButton(
                          label: 'Request',
                          onPressed: onRequest,
                          compact: true,
                        ),
                      ),
                    if (onView != null) ...[
                      if (onRequest != null) SizedBox(width: 8.w),
                      Expanded(
                        child: AppButton(
                          label: 'View',
                          onPressed: onView,
                          compact: true,
                          variant: AppButtonVariant.outlined,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  final double score;
  const _CompatibilityBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: pct >= 80
            ? AppColors.accentGreen.withOpacity(0.15)
            : AppColors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        '$pct% match',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: pct >= 80 ? AppColors.primaryGreen : AppColors.amber,
        ),
      ),
    );
  }
}
