import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/tree_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../widgets/mentee_tree_list.dart';
import '../widgets/watchtower_button.dart';

/// Guide/Mentor home — shows mentee trees, upcoming sessions, and the
/// Watchtower quick-action button.
class MentorDashboard extends ConsumerWidget {
  const MentorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final discipleTrees = ref.watch(discipleTreesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guide Dashboard',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        profile.when(
                          data: (u) => Text(
                            u?.displayName ?? '',
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColors.textMuted),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const WatchtowerButton(),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            // ── Quick actions ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: '+ Schedule session',
                        onPressed: () =>
                            context.go(Routes.sessionScheduler),
                        compact: true,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: AppButton(
                        label: 'Find new mentee',
                        onPressed: () => context.go(Routes.mentor),
                        compact: true,
                        variant: AppButtonVariant.outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            // ── Mentee trees ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Your Disciples',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 10.h)),

            discipleTrees.when(
              loading: () => const SliverToBoxAdapter(child: LoadingSkeleton()),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Text('Error loading disciples: $e'),
                ),
              ),
              data: (trees) => SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: trees.isEmpty
                    ? SliverToBoxAdapter(
                        child: _EmptyDisciples(
                          onFindMentee: () => context.go(Routes.mentor),
                        ),
                      )
                    : SliverToBoxAdapter(child: MenteeTreeList(trees: trees)),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 80.h)),
          ],
        ),
      ),
    );
  }
}

class _EmptyDisciples extends StatelessWidget {
  final VoidCallback onFindMentee;
  const _EmptyDisciples({required this.onFindMentee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderBeige),
      ),
      child: Column(
        children: [
          Text('🌱', style: TextStyle(fontSize: 40.sp)),
          SizedBox(height: 12.h),
          Text(
            'No disciples yet',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark),
          ),
          SizedBox(height: 6.h),
          Text(
            'Invite someone you know, or let the system match you with a learner.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp, height: 1.5, color: AppColors.textMuted),
          ),
          SizedBox(height: 16.h),
          AppButton(label: 'Find a mentee', onPressed: onFindMentee),
        ],
      ),
    );
  }
}
