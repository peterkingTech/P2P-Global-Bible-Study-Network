import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RootNetworkWidget — mirrors root-network.tsx
// A quiet, glowing underground root network painted with CustomPainter.
// Purely atmospheric — represents hidden, connected prayers beneath the surface.
// ─────────────────────────────────────────────────────────────────────────────

class RootNetworkWidget extends StatefulWidget {
  const RootNetworkWidget({super.key});

  @override
  State<RootNetworkWidget> createState() => _RootNetworkWidgetState();
}

class _RootNetworkWidgetState extends State<RootNetworkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glow, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => CustomPaint(
          painter: _RootNetworkPainter(glowOpacity: _pulse.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────────────────────

/// Coordinates are defined in a 600×300 viewBox, scaled to fill the widget.
class _RootNetworkPainter extends CustomPainter {
  final double glowOpacity;
  static const double _vbW = 600;
  static const double _vbH = 300;

  // SVG cubic-bezier path data translated to Dart offset sequences
  // Each root path: list of [startX, startY, cp1x, cp1y, cp2x, cp2y, ex, ey]
  static const _rootPaths = [
    [300, 0, 300, 40, 300, 60, 300, 90, 300, 130, 220, 150, 180, 190, 150, 220, 140, 260, 130, 300],
    [300, 90, 300, 130, 380, 150, 420, 190, 450, 220, 460, 260, 470, 300],
    [300, 120, 300, 150, 260, 170, 250, 210, 242, 245, 250, 275, 250, 300],
    [300, 120, 300, 150, 345, 170, 355, 210, 363, 245, 356, 275, 356, 300],
    [180, 190, 150, 205, 120, 215, 90, 240, 70, 258, 60, 280, 55, 300],
    [420, 190, 450, 205, 480, 215, 510, 240, 530, 258, 540, 280, 545, 300],
    [250, 210, 230, 235, 210, 250, 200, 300],
    [355, 210, 375, 235, 395, 250, 405, 300],
  ];

  static const _nodes = [
    [300.0, 90.0],
    [180.0, 190.0],
    [420.0, 190.0],
    [250.0, 210.0],
    [355.0, 210.0],
    [90.0, 240.0],
    [510.0, 240.0],
    [130.0, 300.0],
    [470.0, 300.0],
    [250.0, 300.0],
    [356.0, 300.0],
  ];

  const _RootNetworkPainter({required this.glowOpacity});

  Path _buildPath(List<num> pts, double sx, double sy) {
    final path = Path();
    // pts: [sx,sy, cp1x,cp1y, cp2x,cp2y, ex,ey, cp1x,cp1y,cp2x,cp2y,ex,ey...]
    path.moveTo(pts[0] * sx, pts[1] * sy);
    int i = 2;
    while (i + 5 < pts.length) {
      path.cubicTo(
        pts[i] * sx, pts[i + 1] * sy,
        pts[i + 2] * sx, pts[i + 3] * sy,
        pts[i + 4] * sx, pts[i + 5] * sy,
      );
      i += 6;
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _vbW;
    final sy = size.height / _vbH;

    // Glow underlay (blurred, amber)
    final glowPaint = Paint()
      ..color = const Color(0xFFE0A441).withOpacity(0.12 * glowOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * min(sx, sy)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final pts in _rootPaths) {
      canvas.drawPath(_buildPath(pts, sx, sy), glowPaint);
    }

    // Crisp root lines with gradient simulation
    final rootPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * min(sx, sy)
      ..strokeCap = StrokeCap.round;

    for (final pts in _rootPaths) {
      // Approximate gradient by drawing with the start colour
      rootPaint.color = const Color(0xFFE0A441).withOpacity(0.55);
      canvas.drawPath(_buildPath(pts, sx, sy), rootPaint);
    }

    // Glowing junction nodes
    for (var idx = 0; idx < _nodes.length; idx++) {
      final cx = _nodes[idx][0] * sx;
      final cy = _nodes[idx][1] * sy;
      final delay = (idx * 0.4).remainder(2 * pi);
      final nodeGlow = (sin(_glow_t(glowOpacity) + delay) + 1) / 2;

      // Radial glow
      final nodePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFF2C463).withOpacity(0.9 * nodeGlow),
            const Color(0xFFE0A441).withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(cx, cy),
          radius: 10 * min(sx, sy),
        ));
      canvas.drawCircle(Offset(cx, cy), 10 * min(sx, sy), nodePaint);

      // Core dot
      canvas.drawCircle(
        Offset(cx, cy),
        1.6 * min(sx, sy),
        Paint()
          ..color = const Color(0xFFF7D98A).withOpacity(0.6 + 0.4 * nodeGlow),
      );
    }
  }

  double _glow_t(double v) => v * pi; // map 0-1 to one half-cycle

  @override
  bool shouldRepaint(_RootNetworkPainter old) =>
      old.glowOpacity != glowOpacity;
}
