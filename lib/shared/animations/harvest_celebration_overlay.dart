import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';

/// Full-screen confetti + animated fruit reveal shown on milestone achievements.
///
/// Usage:
/// ```dart
/// HarvestCelebrationOverlay.show(context, milestone: 'First fruit borne');
/// ```
class HarvestCelebrationOverlay extends StatelessWidget {
  final String milestone;
  final String emoji;
  final VoidCallback onDismiss;

  const HarvestCelebrationOverlay({
    super.key,
    required this.milestone,
    required this.emoji,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String milestone,
    String emoji = '🍎',
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: CurvedAnimation(
                parent: anim, curve: Curves.elasticOut),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, _, __) => HarvestCelebrationOverlay(
        milestone: milestone,
        emoji: emoji,
        onDismiss: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti layer
          const _ConfettiLayer(),

          // Centre card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Container(
              padding: EdgeInsets.all(28.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: TextStyle(fontSize: 64.sp)),
                  SizedBox(height: 14.h),
                  Text(
                    'Milestone reached!',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    milestone,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Continue 🌱',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confetti layer ────────────────────────────────────────────────────────────

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer();

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random();
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      60,
      (_) => _Particle(
        x: _rng.nextDouble(),
        y: -0.1 - _rng.nextDouble() * 0.5,
        vx: (_rng.nextDouble() - 0.5) * 0.004,
        vy: 0.003 + _rng.nextDouble() * 0.005,
        size: 5 + _rng.nextDouble() * 8,
        color: _kColors[_rng.nextInt(_kColors.length)],
        rotation: _rng.nextDouble() * 360,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 4,
      ),
    );
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  static const _kColors = [
    AppColors.amber,
    AppColors.accentGreen,
    AppColors.primaryGreen,
    Color(0xFFF7C948),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        for (final p in _particles) {
          p.x += p.vx;
          p.y += p.vy;
          p.rotation += p.rotationSpeed;
          if (p.y > 1.1) {
            p.y = -0.05;
            p.x = _rng.nextDouble();
          }
        }
        return CustomPaint(
          painter: _ConfettiPainter(_particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x, y, vx, vy, size, rotation, rotationSpeed;
  Color color;
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  const _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color;
      final px = p.x * size.width;
      final py = p.y * size.height;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation * 3.14159 / 180);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}
