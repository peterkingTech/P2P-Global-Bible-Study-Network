import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/tree_provider.dart';
import '../../../features/navigation/widgets/site_nav.dart';
import '../../../features/living_tree/widgets/living_tree_widget.dart';
import '../widgets/daily_verse_card.dart';
import '../widgets/session_prompt_card.dart';
import '../widgets/prayer_pulse_indicator.dart';

/// The main home screen — shows the Living Tree, daily verse,
/// session prompt, and prayer pulse.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final tree = ref.watch(myTreeProvider);

    return VineBranchesShell(
      pages: const [
        _HomeTab(),
        // Remaining tabs are placeholders — wire to real screens
        Center(child: Text('Learn')),
        Center(child: Text('Forest')),
        Center(child: Text('Upper Room')),
      ],
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final tree = ref.watch(myTreeProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        profile.when(
                          data: (u) => Text(
                            'Good day, ${u?.displayName.split(' ').first ?? 'Friend'} 👋',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        Text(
                          'Continue your growth',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    // Prayer pulse dot
                    const PrayerPulseIndicator(),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            // ── Living Tree ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: tree.when(
                  data: (t) => LivingTreeWidget(level: t?.level ?? 0),
                  loading: () => const SizedBox(height: 200),
                  error: (_, __) => LivingTreeWidget(level: 0),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            // ── Daily verse ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: const DailyVerseCard(),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            // ── Session prompt ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SessionPromptCard(
                  onTap: () => context.go(Routes.learn),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 80.h)),
          ],
        ),
      ),
    );
  }
}
