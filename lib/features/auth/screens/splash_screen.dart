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
              // P2P Official Logo
              ClipOval(
                child: Image.network(
                  'https://omkqkasniakcnmfcwrvs.supabase.co/storage/v1/object/public/P2P%20Official%20Logo/P2P%20Official%20Logo.png',
                  width: 96.r,
                  height: 96.r,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 96.r,
                    height: 96.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentGreen.withOpacity(0.15),
                      border: Border.all(
                        color: AppColors.accentGreen.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.menu_book_outlined,
                        color: AppColors.lightGreen, size: 40.sp),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Peer-to-Peer Global\nBible Study Network',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                  letterSpacing: 0.3,
                  height: 1.3,
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
