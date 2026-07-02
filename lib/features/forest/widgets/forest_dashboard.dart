import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/providers/forest_provider.dart';
import '../../../core/utils/formatters.dart';

/// Four stat cards overlaid at the top of the forest views.
class ForestDashboard extends StatelessWidget {
  final GlobalForestStats stats;
  const ForestDashboard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        label: 'Fruit borne',
        value: Formatters.compact(stats.totalBelievers),
        emoji: '🍎',
      ),
      (
        label: 'Cities',
        value: '${stats.citiesReached}',
        emoji: '🌆',
      ),
      (
        label: 'Praying now',
        value: Formatters.compact(stats.prayingNow),
        emoji: '🙏',
      ),
      (
        label: 'Covenant bonds',
        value: Formatters.compact(stats.covenantBonds),
        emoji: '🤝',
      ),
    ];

    return SizedBox(
      height: 64.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) => _StatCard(item: items[i]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ({String label, String value, String emoji}) item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.emoji, style: TextStyle(fontSize: 12.sp)),
              SizedBox(width: 4.w),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF7C948),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 9.sp,
              color: const Color(0xFF9FE1CB).withOpacity(0.7),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
