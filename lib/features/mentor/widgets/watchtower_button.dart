import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

/// The Watchtower quick-action button — a pulsing eye icon that opens a
/// crisis / welfare check overlay for the mentor's disciples.
///
/// Corresponds to the Elijah Protocol: mentor can flag a disciple as needing
/// care and trigger the three-path intervention flow.
class WatchtowerButton extends StatefulWidget {
  final VoidCallback? onTap;
  const WatchtowerButton({super.key, this.onTap});

  @override
  State<WatchtowerButton> createState() => _WatchtowerButtonState();
}

class _WatchtowerButtonState extends State<WatchtowerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open Watchtower — welfare check for disciples',
      child: GestureDetector(
        onTap: widget.onTap ?? () => _showWatchtower(context),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primaryGreen
                    .withOpacity(0.3 + 0.3 * _pulse.value),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.remove_red_eye_outlined,
              size: 20.sp,
              color: AppColors.primaryGreen
                  .withOpacity(0.6 + 0.4 * _pulse.value),
            ),
          ),
        ),
      ),
    );
  }

  void _showWatchtower(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🏰 Watchtower',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check on the welfare of your disciples. If anyone shows signs of struggle, you can trigger a gentle Elijah Protocol check-in.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp, height: 1.5, color: AppColors.textMid),
            ),
            SizedBox(height: 24.h),
            // TODO: list disciples with last-active status
            Text(
              'All disciples active in the last 7 days ✓',
              style: TextStyle(
                  fontSize: 14.sp, color: AppColors.accentGreen),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
