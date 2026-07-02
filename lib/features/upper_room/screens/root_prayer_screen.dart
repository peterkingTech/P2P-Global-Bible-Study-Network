import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';

import '../../../features/root_network/widgets/root_network_widget.dart';
import '../../../features/upper_room/widgets/upper_room_widget.dart';

/// Root Prayer Screen — the hub of the Upper Room section.
/// Shows the glowing root network, submission form, and navigation
/// to live prayer rooms and the nation wall.
class RootPrayerScreen extends ConsumerWidget {
  const RootPrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.upperRoomBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Column(
                  children: [
                    Text(
                      'Upper Room',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.upperRoomCream,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Pray as one body across nations',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.upperRoomMuted,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ── Root network visualisation ────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: SizedBox(
                    height: 160.h,
                    child: const RootNetworkWidget(),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ── Quick nav row ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavCard(
                        emoji: '🔴',
                        label: 'Live Rooms',
                        onTap: () => context.go(Routes.liveRooms),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _NavCard(
                        emoji: '🌍',
                        label: 'Nation Wall',
                        onTap: () => context.go(Routes.nationWall),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ── Embedded Upper Room widget (prayer wall + form) ───────
              const UpperRoomWidget(),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _NavCard(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.upperRoomBorder),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.upperRoomCream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
