import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import '../../core/services/supabase_service.dart';

// ── Supabase leaderboard provider ──────────────────────────────────────────────

class _Leader {
  final String displayName;
  final String? avatarUrl;
  final String? city;
  final String? country;
  final int fruitCount;
  final int servantScore;
  final int faithfulnessXp;

  const _Leader({
    required this.displayName,
    this.avatarUrl,
    this.city,
    this.country,
    required this.fruitCount,
    required this.servantScore,
    required this.faithfulnessXp,
  });

  String get location {
    final parts = [city, country].where((s) => s != null && s.isNotEmpty).toList();
    return parts.join(', ');
  }
}

final _hallOfFaithProvider = FutureProvider<List<_Leader>>((ref) async {
  // Query top disciples who have earned the most fruits, ordered by servant score
  final rows = await SupabaseService.client
      .from('hall_of_faith')
      .select('display_name, avatar_url, city, country, fruit_count, servant_score, faithfulness_xp')
      .order('fruit_count', ascending: false)
      .order('servant_score', ascending: false)
      .limit(50);

  return (rows as List).map((r) => _Leader(
        displayName: (r['display_name'] as String?) ?? 'Disciple',
        avatarUrl: r['avatar_url'] as String?,
        city: r['city'] as String?,
        country: r['country'] as String?,
        fruitCount: (r['fruit_count'] ?? 0) as int,
        servantScore: (r['servant_score'] ?? 0) as int,
        faithfulnessXp: (r['faithfulness_xp'] ?? 0) as int,
      )).toList();
});

/// Hall of Faith — leaderboard of disciples who have completed all 12 modules
/// and earned all 16 fruits. Ordered by fruit count, servant score, and XP.
class HallOfFaithScreen extends ConsumerWidget {
  const HallOfFaithScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_hallOfFaithProvider);

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

          // ── Leaderboard rows ───────────────────────────────────────────
          async.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_outlined,
                          size: 48.sp, color: AppColors.textMuted),
                      SizedBox(height: 12.h),
                      Text(
                        'Could not load leaderboard.\nCheck your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.sp, color: AppColors.textMuted),
                      ),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () => ref.invalidate(_hallOfFaithProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (leaders) => leaders.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🌱', style: TextStyle(fontSize: 48.sp)),
                            SizedBox(height: 12.h),
                            Text(
                              'No disciples have completed the full journey yet.\nBe the first to enter the Hall of Faith.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.sp, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _LeaderRow(rank: i + 1, leader: leaders[i]),
                      childCount: leaders.length,
                    ),
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
  final _Leader leader;
  const _LeaderRow({required this.rank, required this.leader});

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
            backgroundImage: leader.avatarUrl != null
                ? NetworkImage(leader.avatarUrl!)
                : null,
            child: leader.avatarUrl == null
                ? Text(
                    leader.displayName.isNotEmpty
                        ? leader.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGreen),
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leader.displayName,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark),
                ),
                if (leader.location.isNotEmpty)
                  Text(
                    leader.location,
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${leader.fruitCount} 🍎',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen),
              ),
              Text(
                '${leader.servantScore} pts',
                style: TextStyle(
                    fontSize: 10.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
