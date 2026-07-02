import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Idle leaf-sway animation drawn with CustomPainter.
/// Renders [count] leaves around a centre point, gently oscillating
/// on a 3-second infinite cycle.
class LeafSwayAnimation extends StatefulWidget {
  final int count;
  final double radius;
  final Color? color;

  const LeafSwayAnimation({
    super.key,
    this.count = 8,
    this.radius = 40,
    this.color,
  });

  @override
  State<LeafSwayAnimation> createState() => _LeafSwayAnimationState();
}

class _LeafSwayAnimationState extends State<LeafSwayAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _LeafPainter(
          count: widget.count,
          radius: widget.radius,
          swayValue: _ctrl.value,
          color: widget.color ?? AppColors.accentGreen,
        ),
        size: Size(widget.radius * 3, widget.radius * 3),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final int count;
  final double radius;
  final double swayValue;
  final Color color;

  const _LeafPainter({
    required this.count,
    required this.radius,
    required this.swayValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final baseAngle = (2 * pi * i) / count;
      final sway = sin(swayValue * pi + i * 0.8) * 0.15;
      final angle = baseAngle + sway;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);

      final leafPath = Path();
      leafPath.moveTo(x, y);
      leafPath.quadraticBezierTo(
        x + cos(angle + pi / 2) * 8,
        y + sin(angle + pi / 2) * 8,
        x + cos(angle) * 14,
        y + sin(angle) * 14,
      );
      leafPath.quadraticBezierTo(
        x + cos(angle - pi / 2) * 8,
        y + sin(angle - pi / 2) * 8,
        x,
        y,
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + sway);
      canvas.translate(-x, -y);
      canvas.drawPath(leafPath, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.swayValue != swayValue;
}
