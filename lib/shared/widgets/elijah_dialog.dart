import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';

/// The Elijah Protocol crisis dialog.
///
/// Triggered when the user indicates quit intent or critical keywords are
/// detected. Offers three gentle paths: Prayer, Talk to someone, Rest.
///
/// "Elijah sat under a tree and said it was enough. What do you need?"
class ElijahDialog extends StatelessWidget {
  final VoidCallback onPrayer;
  final VoidCallback onTalkToSomeone;
  final VoidCallback onRest;

  const ElijahDialog({
    super.key,
    required this.onPrayer,
    required this.onTalkToSomeone,
    required this.onRest,
  });

  /// Shows the dialog. Returns the user's choice.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPrayer,
    required VoidCallback onTalkToSomeone,
    required VoidCallback onRest,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.upperRoomBg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => ElijahDialog(
        onPrayer: onPrayer,
        onTalkToSomeone: onTalkToSomeone,
        onRest: onRest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🌿', style: TextStyle(fontSize: 44.sp)),
          SizedBox(height: 16.h),
          Text(
            '"Elijah sat under a tree and said it was enough."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: AppColors.upperRoomWall,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'What do you need right now?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.upperRoomCream,
            ),
          ),
          SizedBox(height: 28.h),
          _Option(
            emoji: '🙏',
            label: 'Prayer',
            sub: 'Let your root network pray for you.',
            onTap: () {
              Navigator.pop(context);
              onPrayer();
            },
          ),
          SizedBox(height: 12.h),
          _Option(
            emoji: '💬',
            label: 'Talk to someone',
            sub: 'Connect with a Watchtower counsellor.',
            onTap: () {
              Navigator.pop(context);
              onTalkToSomeone();
            },
          ),
          SizedBox(height: 12.h),
          _Option(
            emoji: '😴',
            label: 'Rest for a while',
            sub: 'Enter Dormant Seed mode — your tree stays alive.',
            onTap: () {
              Navigator.pop(context);
              onRest();
            },
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _Option(
      {required this.emoji,
      required this.label,
      required this.sub,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.upperRoomBorder),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.upperRoomCream)),
                  Text(sub,
                      style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.4,
                          color: AppColors.upperRoomMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18.sp, color: AppColors.upperRoomMuted),
          ],
        ),
      ),
    );
  }
}
