import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// Animated bezier connection line between two forest nodes.
class ConnectionLine extends StatefulWidget {
  final Offset from;
  final Offset to;
  final bool covenant; // Paul-Timothy solid line vs dashed mentoring link
  final bool active;

  const ConnectionLine({
    super.key,
    required this.from,
    required this.to,
    this.covenant = false,
    this.active = false,
  });

  @override
  State<ConnectionLine> createState() => _ConnectionLineState();
}

class _ConnectionLineState extends State<ConnectionLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow;

  @override
  void initState() {
    super.initState();
    _flow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flow,
      builder: (_, __) => CustomPaint(
        painter: _LinePainter(
          from: widget.from,
          to: widget.to,
          covenant: widget.covenant,
          active: widget.active,
          flowValue: _flow.value,
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final bool covenant;
  final bool active;
  final double flowValue;

  const _LinePainter({
    required this.from,
    required this.to,
    required this.covenant,
    required this.active,
    required this.flowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = covenant ? AppColors.amber : AppColors.accentGreen;
    final opacity = active ? 0.9 : (covenant ? 0.5 : 0.3);

    final paint = Paint()
      ..color = baseColor.withOpacity(opacity)
      ..strokeWidth = covenant ? 1.8 : 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mid = Offset(
      (from.dx + to.dx) / 2,
      (from.dy + to.dy) / 2 - 20,
    );

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);

    if (covenant) {
      canvas.drawPath(path, paint);
      // Animated flow dot
      final metric = path.computeMetrics().first;
      final pos = metric.getTangentForOffset(metric.length * flowValue);
      if (pos != null) {
        canvas.drawCircle(
          pos.position,
          2.5,
          Paint()..color = AppColors.amber.withOpacity(0.9),
        );
      }
    } else {
      _drawDashed(canvas, path, paint);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 5.0;
    const gap = 4.0;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      var dist = 0.0;
      var drawing = true;
      while (dist < m.length) {
        final len = drawing ? dash : gap;
        if (drawing) {
          canvas.drawPath(
            m.extractPath(dist, (dist + len).clamp(0, m.length)),
            paint,
          );
        }
        dist += len;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.flowValue != flowValue || old.active != active;
}
