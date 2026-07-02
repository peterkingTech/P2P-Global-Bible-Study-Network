import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/providers/forest_provider.dart';
import '../../../features/global_forest/widgets/global_forest_page.dart';
import '../widgets/forest_dashboard.dart';

/// Global Heatmap — the full-screen world map view of the discipleship
/// network. Embeds [GlobalForestPage] and overlays the stats dashboard.
class GlobalHeatmapScreen extends ConsumerWidget {
  const GlobalHeatmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(globalStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF06110D),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  const BackButton(color: Color(0xFF9FE1CB)),
                  Expanded(
                    child: Text(
                      'Global Forest',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF4EFE4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // ── Stats ─────────────────────────────────────────────────
            statsAsync.when(
              data: (s) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ForestDashboard(stats: s),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── Full GlobalForestPage (filters + map + legend) ─────────
            const Expanded(child: GlobalForestPage()),
          ],
        ),
      ),
    );
  }
}
