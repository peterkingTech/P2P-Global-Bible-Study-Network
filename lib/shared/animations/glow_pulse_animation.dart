import 'package:flutter/material.dart';

/// Wraps [child] in an oscillating glow / brightness animation.
/// Useful for active trees, live prayer dots, and harvest events.
class GlowPulseAnimation extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minRadius;
  final double maxRadius;
  final Duration period;

  const GlowPulseAnimation({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF1D9E75),
    this.minRadius = 0,
    this.maxRadius = 16,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  State<GlowPulseAnimation> createState() => _GlowPulseAnimationState();
}

class _GlowPulseAnimationState extends State<GlowPulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, child) {
        final radius = widget.minRadius +
            (widget.maxRadius - widget.minRadius) * _glow.value;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor
                    .withOpacity(0.2 + 0.4 * _glow.value),
                blurRadius: radius,
                spreadRadius: radius * 0.3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
