import 'package:flutter/material.dart';

/// Scale + rotate entrance animation for a newly earned fruit.
///
/// Wrap the fruit widget in [FruitAppearAnimation] at the moment of award.
class FruitAppearAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final VoidCallback? onDone;

  const FruitAppearAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.onDone,
  });

  @override
  State<FruitAppearAnimation> createState() => _FruitAppearAnimationState();
}

class _FruitAppearAnimationState extends State<FruitAppearAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _rotation = Tween(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _ctrl.forward().then((_) => widget.onDone?.call());
      }
    });
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
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: Transform.rotate(
          angle: _rotation.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
