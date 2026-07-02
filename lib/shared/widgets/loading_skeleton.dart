import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';

/// Animated shimmer skeleton used as a loading placeholder across the app.
class LoadingSkeleton extends StatefulWidget {
  final int lines;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    this.lines = 4,
    this.height = 14,
    this.borderRadius = 8,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.lines * 2 - 1, (i) {
          if (i.isOdd) return SizedBox(height: 10.h);
          final isNarrow = i == widget.lines * 2 - 2;
          return AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              height: widget.height.h,
              width: isNarrow ? 180.w : double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius.r),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.borderBeige.withOpacity(0.4 + 0.3 * _anim.value),
                    AppColors.borderBeige.withOpacity(0.15 + 0.1 * _anim.value),
                    AppColors.borderBeige.withOpacity(0.4 + 0.3 * _anim.value),
                  ],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A single skeleton bone (inline use).
class SkeletonBone extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBone({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        color: AppColors.borderBeige.withOpacity(0.5),
      ),
    );
  }
}
