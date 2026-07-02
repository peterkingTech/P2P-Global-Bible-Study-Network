import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/fruit_model.dart';
import '../../../core/providers/fruit_provider.dart';
import '../../../shared/animations/harvest_celebration_overlay.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../widgets/fruit_badge.dart';
import '../widgets/faithfulness_dashboard.dart';

/// The 16-fruit collection grid + faithfulness stats + Hall of Faith.
class FruitCollectionScreen extends ConsumerWidget {
  const FruitCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fruitsAsync = ref.watch(fruitsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: fruitsAsync.when(
          loading: () => const LoadingSkeleton(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (fruits) {
            final earned = fruits.where((f) => f.isEarned).toList();
            final total = fruits.length;

            return CustomScrollView(
              slivers: [
                // ── Header ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🍎 My Fruit',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${earned.length} of $total fruits earned',
                          style: TextStyle(
                              fontSize: 13.sp, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // ── Faithfulness dashboard ────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: const FaithfulnessDashboard(),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // ── Fruit grid ───────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => FruitBadge(
                        fruit: fruits[i],
                        onTap: () => _showDetail(context, fruits[i]),
                      ),
                      childCount: fruits.length,
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.8,
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, FruitModel fruit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => _FruitDetailSheet(fruit: fruit),
    );
  }
}

class _FruitDetailSheet extends StatelessWidget {
  final FruitModel fruit;
  const _FruitDetailSheet({required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(fruit.emoji, style: TextStyle(fontSize: 56.sp)),
          SizedBox(height: 8.h),
          Text(
            fruit.name,
            style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          SizedBox(height: 8.h),
          Text(
            fruit.description,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14.sp, height: 1.55, color: AppColors.textMid),
          ),
          SizedBox(height: 20.h),
          if (fruit.isEarned) ...[
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: AppColors.accentGreen.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text('✅ Earned',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentGreen)),
                  if (fruit.earnedAt != null)
                    Text(
                      'on ${fruit.earnedAt!.day}/${fruit.earnedAt!.month}/${fruit.earnedAt!.year}',
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.textMuted),
                    ),
                  if (fruit.earnedReason != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      fruit.earnedReason!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textMid),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.borderBeige.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text('🔒 Not yet earned',
                      style: TextStyle(
                          fontSize: 13.sp, color: AppColors.textMuted)),
                  SizedBox(height: 6.h),
                  Text(
                    fruit.isSecret ? 'Keep going — this one is a surprise.' : fruit.howToEarn,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp, height: 1.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
