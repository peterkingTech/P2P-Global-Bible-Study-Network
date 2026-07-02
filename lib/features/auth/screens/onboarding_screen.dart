import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../shared/widgets/custom_button.dart';

// ── Onboarding slide data ──────────────────────────────────────────────────────

const _kSlides = [
  (
    emoji: '🌱',
    title: 'Grow in the Word',
    body:
        'Work through structured discipleship modules alongside a peer who sharpens and encourages you.',
  ),
  (
    emoji: '🤝',
    title: 'Disciple Across Nations',
    body:
        'Connect with believers in cities you\'ve never visited. One church, many nations.',
  ),
  (
    emoji: '🙏',
    title: 'Pray as One Body',
    body:
        'Join the Upper Room — live prayer rooms, the nation prayer wall, and 24/7 intercession.',
  ),
  (
    emoji: '🌳',
    title: 'Watch Your Tree Grow',
    body:
        'Every study, session, and prayer bears fruit. Your Living Tree reflects the life of Christ in you.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _kSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(Routes.login),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.lightGreen.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _kSlides.length,
                itemBuilder: (_, i) => _Slide(slide: _kSlides[i]),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _kSlides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: i == _page ? 20.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.accentGreen
                        : AppColors.accentGreen.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // CTA
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: AppButton(
                label: _page < _kSlides.length - 1 ? 'Next' : 'Get Started',
                onPressed: _next,
              ),
            ),

            SizedBox(height: 16.h),

            TextButton(
              onPressed: () => context.go(Routes.login),
              child: Text(
                'Already have an account? Sign in',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.lightGreen.withOpacity(0.7),
                ),
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final ({String emoji, String title, String body}) slide;
  const _Slide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(slide.emoji, style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 24.h),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
              height: 1.2,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.6,
              color: AppColors.lightGreen.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}
