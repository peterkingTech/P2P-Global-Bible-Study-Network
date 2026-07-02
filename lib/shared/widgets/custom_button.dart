import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';

enum AppButtonVariant { filled, outlined, ghost }

/// The primary button for the entire app.
///
/// [variant] controls filled / outlined / ghost appearance.
/// [compact] reduces vertical padding.
/// [isLoading] shows a spinner instead of the label.
/// Pass [null] to [onPressed] to disable (greyed out, no feedback).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool compact;
  final bool isLoading;
  final IconData? leadingIcon;
  final Color? customColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.compact = false,
    this.isLoading = false,
    this.leadingIcon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final baseColor = customColor ?? AppColors.primaryGreen;

    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case AppButtonVariant.filled:
        bg = disabled ? baseColor.withAlpha(90) : baseColor;
        fg = Colors.white;
        border = Colors.transparent;
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = disabled ? baseColor.withAlpha(90) : baseColor;
        border = disabled ? baseColor.withAlpha(64) : baseColor;
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = disabled ? AppColors.textMuted : baseColor;
        border = Colors.transparent;
        break;
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: compact ? 10.h : 14.h,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingIcon != null) ...[
                        Icon(leadingIcon, size: 16.sp, color: fg),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: compact ? 13.sp : 15.sp,
                          fontWeight: FontWeight.w600,
                          color: fg,
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
