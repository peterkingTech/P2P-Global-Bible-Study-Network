import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

/// An animated pulsing green dot that indicates live prayer activity.
/// Tapping it navigates to the Upper Room.
class PrayerPulseIndicator extends StatefulWidget {
  final VoidCallback? onTap;
  const PrayerPulseIndicator({super.key, this.onTap});

  @override
  State<PrayerPulseIndicator> createState() => _PrayerPulseIndicatorState();
}

class _PrayerPulseIndicatorState extends State<PrayerPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _ring = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open Upper Room — prayer activity live',
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 36.r,
          height: 36.r,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding ring
              AnimatedBuilder(
                animation: _ring,
                builder: (_, __) => Container(
                  width: 36.r * _ring.value,
                  height: 36.r * _ring.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGreen
                        .withOpacity(0.35 * (1 - _ring.value)),
                  ),
                ),
              ),
              // Core dot
              Container(
                width: 12.r,
                height: 12.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
