import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';
import '../../core/models/tree_model.dart';
import '../../core/utils/helpers.dart';

/// Smooth morphing animation when a tree levels up.
///
/// Shows: old stage → 2s grow animation → new stage.
/// Uses easeInOutCubic as specified.
class TreeGrowthAnimation extends StatefulWidget {
  final TreeStage from;
  final TreeStage to;
  final VoidCallback? onComplete;

  const TreeGrowthAnimation({
    super.key,
    required this.from,
    required this.to,
    this.onComplete,
  });

  @override
  State<TreeGrowthAnimation> createState() => _TreeGrowthAnimationState();
}

class _TreeGrowthAnimationState extends State<TreeGrowthAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
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
        final fromLevel = widget.from.index;
        final toLevel = widget.to.index;
        final lerpLevel = fromLevel + (toLevel - fromLevel) * t;

        final fromColor = growthLevelColor(fromLevel);
        final toColor = growthLevelColor(toLevel);
        final currentColor = Color.lerp(fromColor, toColor, t) ?? fromColor;

        return SizedBox(
          width: 200.r,
          height: 280.r,
          child: CustomPaint(
            painter: _GrowingTreePainter(
              progress: t,
              color: currentColor,
              trunkHeight: 60 + lerpLevel * 20,
              branchSpread: 30 + lerpLevel * 15,
              canopyRadius: 40 + lerpLevel * 12,
            ),
          ),
        );
      },
    );
  }
}

class _GrowingTreePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double trunkHeight;
  final double branchSpread;
  final double canopyRadius;

  const _GrowingTreePainter({
    required this.progress,
    required this.color,
    required this.trunkHeight,
    required this.branchSpread,
    required this.canopyRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 8 + progress * 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final canopyPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final bottom = size.height * 0.9;

    // Trunk
    canvas.drawLine(
      Offset(cx, bottom),
      Offset(cx, bottom - trunkHeight * progress),
      trunkPaint,
    );

    // Canopy (drawn when trunk is >50% complete)
    if (progress > 0.4) {
      final canopyProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
      final canopyY = bottom - trunkHeight * progress;
      canvas.drawCircle(
        Offset(cx, canopyY - canopyRadius * 0.5),
        canopyRadius * canopyProgress,
        canopyPaint,
      );
    }

    // Branches (appear at >70% progress)
    if (progress > 0.7) {
      final branchProgress = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
      final branchY = bottom - trunkHeight * progress * 0.65;
      final branchPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Left branch
      canvas.drawLine(
        Offset(cx, branchY),
        Offset(cx - branchSpread * branchProgress, branchY - 20),
        branchPaint,
      );
      // Right branch
      canvas.drawLine(
        Offset(cx, branchY),
        Offset(cx + branchSpread * branchProgress, branchY - 20),
        branchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GrowingTreePainter old) =>
      old.progress != progress || old.color != color;
}
