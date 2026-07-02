import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../features/auth/widgets/tree_planting_animation.dart';
import '../../shared/widgets/custom_button.dart';

/// Tree Ceremony — shown once after profile setup to celebrate the user
/// planting their first tree in the global forest.
class TreeCeremonyScreen extends StatefulWidget {
  const TreeCeremonyScreen({super.key});

  @override
  State<TreeCeremonyScreen> createState() => _TreeCeremonyScreenState();
}

class _TreeCeremonyScreenState extends State<TreeCeremonyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06110D),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 32.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // ── Tree animation ─────────────────────────────────────
                SizedBox(
                  height: 260.h,
                  child: TreePlantingAnimation(onComplete: () {}),
                ),
                SizedBox(height: 40.h),
                // ── Headline ──────────────────────────────────────────
                Text(
                  'Your tree is planted 🌱',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'You\'ve joined the global discipleship forest.\n'
                  'Now invite a peer and watch it grow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                // ── CTA ───────────────────────────────────────────────
                AppButton(
                  label: 'Enter the forest',
                  onPressed: () => context.go(Routes.home),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => context.go(Routes.matchPaths),
                  child: Text(
                    'Invite my first peer →',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
