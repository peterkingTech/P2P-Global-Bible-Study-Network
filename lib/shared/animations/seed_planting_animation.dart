import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';

/// The Tree Planting Ceremony animation:
///   seed drops into soil → water ripple → sprout emerges.
///
/// Three phases:
///   Phase 0 (0–0.33): seed falls from top.
///   Phase 1 (0.33–0.66): water ripple.
///   Phase 2 (0.66–1.0): sprout grows out of ground.
class SeedPlantingAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const SeedPlantingAnimation({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<SeedPlantingAnimation> createState() => _SeedPlantingAnimationState();
}

class _SeedPlantingAnimationState extends State<SeedPlantingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) {
        final t = _progress.value;
        return SizedBox(
          height: 260.h,
          child: CustomPaint(
            painter: _CeremonyPainter(t: t),
            size: Size(double.infinity, 260.h),
          ),
        );
      },
    );
  }
}

class _CeremonyPainter extends CustomPainter {
  final double t;
  const _CeremonyPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height * 0.68;

    // ── Soil strip ────────────────────────────────────────────────────
    final soilPaint = Paint()..color = const Color(0xFF6B4423);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
        const Radius.circular(16),
      ),
      soilPaint,
    );

    // ── Phase 0: seed drop ────────────────────────────────────────────
    if (t < 0.4) {
      final seedProgress = (t / 0.4).clamp(0.0, 1.0);
      final seedY = size.height * 0.1 + (groundY - size.height * 0.1) * seedProgress;
      _drawSeed(canvas, Offset(cx, seedY));
    }

    // ── Phase 1: water ripple ─────────────────────────────────────────
    if (t >= 0.38 && t < 0.65) {
      final rippleT = ((t - 0.38) / 0.27).clamp(0.0, 1.0);
      _drawRipple(canvas, Offset(cx, groundY), rippleT, size.width * 0.25);
    }

    // ── Phase 2: sprout emerge ────────────────────────────────────────
    if (t >= 0.58) {
      final sproutT = ((t - 0.58) / 0.42).clamp(0.0, 1.0);
      _drawSprout(canvas, Offset(cx, groundY), sproutT);
    }
  }

  void _drawSeed(Canvas canvas, Offset pos) {
    final paint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 18, height: 22),
      paint,
    );
    // Sprout nub
    final nubPaint = Paint()..color = AppColors.accentGreen;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 11), width: 5, height: 8),
      nubPaint,
    );
  }

  void _drawRipple(Canvas canvas, Offset pos, double t, double maxRadius) {
    for (var i = 0; i < 3; i++) {
      final delay = i * 0.18;
      final rippleT = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (rippleT <= 0) continue;
      final paint = Paint()
        ..color = const Color(0xFF4FC3F7).withOpacity((1 - rippleT) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(pos, maxRadius * rippleT, paint);
    }
  }

  void _drawSprout(Canvas canvas, Offset ground, double t) {
    final maxHeight = ground.dy - 40;
    final tipY = ground.dy - maxHeight * t;

    // Stem
    final stemPaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(ground.dx, ground.dy), Offset(ground.dx, tipY), stemPaint);

    // Leaves (appear when t > 0.5)
    if (t > 0.5) {
      final leafT = ((t - 0.5) / 0.5).clamp(0.0, 1.0);
      final leafPaint = Paint()
        ..color = AppColors.accentGreen.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      final leafY = tipY + 8;
      final leafW = 20 * leafT;

      // Left leaf
      final leftPath = Path()
        ..moveTo(ground.dx, leafY)
        ..quadraticBezierTo(ground.dx - leafW, leafY - 12, ground.dx - leafW * 0.5, leafY - 20)
        ..quadraticBezierTo(ground.dx, leafY - 8, ground.dx, leafY);
      canvas.drawPath(leftPath, leafPaint);

      // Right leaf
      final rightPath = Path()
        ..moveTo(ground.dx, leafY - 12)
        ..quadraticBezierTo(ground.dx + leafW, leafY - 22, ground.dx + leafW * 0.5, leafY - 30)
        ..quadraticBezierTo(ground.dx, leafY - 14, ground.dx, leafY - 12);
      canvas.drawPath(rightPath, leafPaint);
    }
  }

  @override
  bool shouldRepaint(_CeremonyPainter old) => old.t != t;
}
