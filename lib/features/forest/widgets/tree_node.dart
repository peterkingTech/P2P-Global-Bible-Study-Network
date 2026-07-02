import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/utils/helpers.dart';

/// A single animated tree node for the personal forest / network view.
class TreeNode extends StatefulWidget {
  final int level;
  final bool isViewer;
  final bool small;
  final VoidCallback? onTap;

  const TreeNode({
    super.key,
    this.level = 0,
    this.isViewer = false,
    this.small = false,
    this.onTap,
  });

  @override
  State<TreeNode> createState() => _TreeNodeState();
}

class _TreeNodeState extends State<TreeNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.small ? 28.r : (widget.isViewer ? 56.r : 40.r);
    final color = widget.isViewer
        ? const Color(0xFFF4EFE4)
        : growthLevelColor(widget.level);

    return Semantics(
      button: widget.onTap != null,
      label: widget.isViewer ? 'Your tree' : 'Level ${widget.level} disciple',
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glow,
          builder: (_, __) => SizedBox(
            width: size * 2,
            height: size * 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow ring
                Container(
                  width: size * 1.6,
                  height: size * 1.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(
                        (widget.isViewer ? 0.25 : 0.15) * _glow.value),
                  ),
                ),
                // Core node
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: widget.isViewer
                        ? Border.all(
                            color: AppColors.accentGreen, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: size / 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      growthLevelEmoji(widget.level),
                      style: TextStyle(fontSize: (size * 0.45)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
