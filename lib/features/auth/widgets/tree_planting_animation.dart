import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

/// Full-screen animation shown after a new user completes profile setup.
///
/// The seed grows into a sapling with a scale + fade-in sequence.
/// After [_totalDuration] the [onComplete] callback fires.
///
/// TODO: Replace the placeholder with a Rive animation when the
/// `assets/rive/tree_planting.riv` asset is available.
class TreePlantingAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  const TreePlantingAnimation({super.key, required this.onComplete});

  @override
  State<TreePlantingAnimation> createState() => _TreePlantingAnimationState();
}

class _TreePlantingAnimationState extends State<TreePlantingAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _scale;
  late final AnimationController _glow;
  late final AnimationController _text;

  static const _totalDuration = Duration(milliseconds: 3200);

  @override
  void initState() {
    super.initState();

    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _text = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scale.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _glow.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    _text.forward();
    await Future.delayed(_totalDuration);
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _scale.dispose();
    _glow.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tree emoji grows from seed → sapling
            AnimatedBuilder(
              animation: _scale,
              builder: (_, __) {
                final v = CurvedAnimation(
                  parent: _scale,
                  curve: Curves.elasticOut,
                ).value;
                return Transform.scale(
                  scale: 0.2 + v * 0.8,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow
                      AnimatedBuilder(
                        animation: _glow,
                        builder: (_, __) => Container(
                          width: 140.r,
                          height: 140.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentGreen
                                .withOpacity(0.15 * _glow.value),
                          ),
                        ),
                      ),
                      Text('🌱', style: TextStyle(fontSize: 72.sp)),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 32.h),

            // "Your tree is planted" text fades in
            FadeTransition(
              opacity: _text,
              child: Column(
                children: [
                  Text(
                    'Your tree is planted! 🎉',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Now abide in the vine and bear much fruit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.lightGreen.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '— John 15:5',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.lightGreen.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
