import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/fruit_model.dart';

/// A single fruit badge in the collection grid.
/// Secret fruits show a question mark. Uneearned fruits are desaturated.
class FruitBadge extends StatefulWidget {
  final FruitModel fruit;
  final VoidCallback onTap;

  const FruitBadge({super.key, required this.fruit, required this.onTap});

  @override
  State<FruitBadge> createState() => _FruitBadgeState();
}

class _FruitBadgeState extends State<FruitBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _appear;

  @override
  void initState() {
    super.initState();
    _appear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.fruit.isEarned) {
      _appear.forward();
    }
  }

  @override
  void dispose() {
    _appear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fruit;
    final earned = f.isEarned;
    final secret = f.isSecret && !earned;

    return Semantics(
      button: true,
      label: secret ? 'Secret fruit — keep going!' : '${f.name}: ${earned ? "earned" : "not yet earned"}',
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _appear,
          builder: (_, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge circle
                Transform.scale(
                  scale: earned ? 1.0 : 0.9,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 54.r,
                    height: 54.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: earned
                          ? f.color.withOpacity(0.15)
                          : AppColors.borderBeige.withOpacity(0.3),
                      border: Border.all(
                        color: earned ? f.color : AppColors.borderBeige,
                        width: earned ? 2 : 1,
                      ),
                      boxShadow: earned
                          ? [
                              BoxShadow(
                                color: f.color.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: ColorFiltered(
                      colorFilter: earned
                          ? const ColorFilter.mode(Colors.transparent, BlendMode.saturation)
                          : const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                      child: Text(
                        secret ? '❓' : f.emoji,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Label
                Text(
                  secret ? '???' : f.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight:
                        earned ? FontWeight.w600 : FontWeight.w400,
                    color: earned
                        ? AppColors.textDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
