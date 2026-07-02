import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/providers/fruit_provider.dart';
import '../../../core/utils/formatters.dart';

/// Four faithfulness-point categories shown as animated stat cards.
class FaithfulnessDashboard extends ConsumerWidget {
  const FaithfulnessDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(faithfulnessStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (s) {
        final items = [
          (label: 'Wisdom WP', value: s.wisdomPoints, color: AppColors.primaryGreen, emoji: '📖'),
          (label: 'Faithfulness', value: s.faithfulnessXp, color: AppColors.amber, emoji: '🕯️'),
          (label: 'Fruit Points', value: s.fruitPoints, color: AppColors.accentGreen, emoji: '🍎'),
          (label: 'Servant Score', value: s.servantScore, color: const Color(0xFF7B61FF), emoji: '🤲'),
        ];

        return SizedBox(
          height: 80.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, i) => _StatCard(item: items[i]),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final ({String label, int value, Color color, String emoji}) item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: item.color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(item.emoji, style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 3.w),
              Text(
                Formatters.compact(item.value),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 9.sp,
              color: item.color.withOpacity(0.7),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
