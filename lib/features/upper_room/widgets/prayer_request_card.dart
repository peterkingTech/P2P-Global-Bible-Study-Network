import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/prayer_model.dart';
import '../../../core/utils/formatters.dart';

/// A single prayer request card on the Nation Prayer Wall.
class PrayerRequestCard extends StatefulWidget {
  final PrayerModel prayer;
  final VoidCallback onPrayed;

  const PrayerRequestCard({
    super.key,
    required this.prayer,
    required this.onPrayed,
  });

  @override
  State<PrayerRequestCard> createState() => _PrayerRequestCardState();
}

class _PrayerRequestCardState extends State<PrayerRequestCard> {
  bool _prayed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.prayer;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.upperRoomCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _prayed
              ? AppColors.accentGreen.withOpacity(0.4)
              : AppColors.upperRoomBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Requester info ─────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.upperRoomAmber.withOpacity(0.2),
                ),
                alignment: Alignment.center,
                child: Text(
                  p.isAnonymous
                      ? '🙏'
                      : (p.displayName?.isNotEmpty == true
                          ? p.displayName![0].toUpperCase()
                          : '?'),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.isAnonymous ? 'Anonymous' : (p.displayName ?? 'A brother or sister'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.upperRoomCream,
                      ),
                    ),
                    if (p.city != null || p.country != null)
                      Text(
                        [p.city, p.country].whereType<String>().join(', '),
                        style: TextStyle(
                            fontSize: 10.sp, color: AppColors.upperRoomMuted),
                      ),
                  ],
                ),
              ),
              // Category pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.upperRoomAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  p.category.name,
                  style: TextStyle(
                      fontSize: 9.sp, color: AppColors.upperRoomAmber),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ── Request text ───────────────────────────────────────────
          Text(
            p.request,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.6,
              color: AppColors.upperRoomWall,
            ),
          ),

          SizedBox(height: 12.h),

          // ── Footer ─────────────────────────────────────────────────
          Row(
            children: [
              Text(
                Formatters.relativeDate(p.createdAt),
                style: TextStyle(
                    fontSize: 10.sp, color: AppColors.upperRoomMuted),
              ),
              if (p.prayedCount > 0) ...[
                SizedBox(width: 8.w),
                Text(
                  '· ${p.prayedCount} ${p.prayedCount == 1 ? 'person' : 'people'} prayed',
                  style: TextStyle(
                      fontSize: 10.sp, color: AppColors.upperRoomMuted),
                ),
              ],
              const Spacer(),
              Semantics(
                button: true,
                toggled: _prayed,
                label: 'I prayed for this',
                child: GestureDetector(
                  onTap: _prayed
                      ? null
                      : () {
                          setState(() => _prayed = true);
                          widget.onPrayed();
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _prayed
                          ? AppColors.accentGreen.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: _prayed
                            ? AppColors.accentGreen
                            : AppColors.upperRoomBorder,
                      ),
                    ),
                    child: Text(
                      _prayed ? '🙏 Prayed' : 'I prayed this',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _prayed
                            ? AppColors.accentGreen
                            : AppColors.upperRoomMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
