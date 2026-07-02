import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../core/providers/auth_provider.dart';

/// Animated splash shown while Supabase restores the session.
/// Navigates to [Routes.home] if already authenticated, otherwise [Routes.onboarding].
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeIn);

    // Give Supabase a moment to restore session, then route
    Future.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final isAuth = ref.read(isAuthenticatedProvider);
    context.go(isAuth ? Routes.home : Routes.onboarding);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navBg,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vine logo placeholder — replace with Rive / SVG asset
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen.withOpacity(0.15),
                  border: Border.all(
                    color: AppColors.accentGreen.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text('🌿', style: TextStyle(fontSize: 36.sp)),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Vine & Branches',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Discipleship across nations',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.lightGreen.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 48.h),
              SizedBox(
                width: 24.r,
                height: 24.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentGreen.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
