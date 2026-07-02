import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/unreached_peoples_map.dart';
import '../widgets/dark_nation_card.dart';

/// Missions Hub — overview of unreached peoples, weekly challenge, and
/// the Mega Harvest event countdown.
class MissionsHub extends StatelessWidget {
  const MissionsHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missions',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'The earth will be filled with the knowledge of the glory of the Lord.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '— Habakkuk 2:14',
                      style: TextStyle(
                          fontSize: 11.sp, color: AppColors.textMutedLight),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            // ── Weekly challenge card ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _WeeklyChallengeCard(
                  onOpen: () => context.go(Routes.weeklyChallenge),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            // ── Unreached peoples map ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unreached Peoples',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    const UnreachedPeoplesMap(),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            // ── Dark nation cards ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Stand in the Gap',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 80.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: DarkNationCard(index: i),
                  ),
                  childCount: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChallengeCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _WeeklyChallengeCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.accentGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚡ Weekly Challenge',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Share the gospel with one person this week',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12.h),
                AppButton(
                  label: 'View challenge',
                  onPressed: onOpen,
                  compact: true,
                  variant: AppButtonVariant.outlined,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text('🌍', style: TextStyle(fontSize: 44.sp)),
        ],
      ),
    );
  }
}
