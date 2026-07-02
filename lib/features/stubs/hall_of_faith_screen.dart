import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

/// Hall of Faith — leaderboard of disciples who have completed all 12 modules
/// and earned all 16 fruits. Ordered by fruit count, servant score, and XP.
///
/// TODO: Implement Supabase query + real leaderboard rows.
class HallOfFaithScreen extends ConsumerWidget {
  const HallOfFaithScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.cream,
            elevation: 0,
            pinned: true,
            leading: BackButton(color: AppColors.textDark),
            title: Text(
              'Hall of Faith',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),

          // ── Crown banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Column(
                children: [
                  Text('🏛️', style: TextStyle(fontSize: 56.sp)),
                  SizedBox(height: 12.h),
                  Text(
                    'Hebrews 11 — the faithful cloud of witnesses',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Placeholder rows ──────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _LeaderRow(rank: i + 1),
              childCount: 10,
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  const _LeaderRow({required this.rank});

  static const _kNames = [
    'Emmanuel K. · Lagos',
    'Sofia M. · São Paulo',
    'Priya R. · Chennai',
    'David O. · Nairobi',
    'Ana L. · Madrid',
    'James P. · London',
    'Mei L. · Singapore',
    'Olga V. · Kyiv',
    'Samuel T. · Accra',
    'Hannah B. · Seoul',
  ];

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];
    final label = rank <= 3 ? medals[rank - 1] : '#$rank';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: rank == 1
            ? AppColors.brightYellow.withOpacity(0.12)
            : AppColors.lightCream,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderBeige),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 18.sp),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 12.w),
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.accentGreen.withOpacity(0.2),
            child: Text(
              _kNames[rank - 1][0],
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kNames[rank - 1],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '16 fruits · ${200 - rank * 10} XP · ${12 - (rank ~/ 4)} disciples',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text('🌳', style: TextStyle(fontSize: 20.sp)),
        ],
      ),
    );
  }
}
