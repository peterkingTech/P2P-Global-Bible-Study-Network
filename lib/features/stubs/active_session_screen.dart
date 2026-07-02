import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../features/peer_session/widgets/peer_session_widget.dart';

/// Active Session Screen — the live collaborative Bible study session.
///
/// Shows the 5-step session checklist, countdown timer, and peer presence
/// indicators. Uses Supabase realtime to sync state between both peers.
///
/// TODO (Step 13): Wire up Supabase realtime channel, countdown timer,
/// and per-step completion sync. The [PeerSessionWidget] handles the UI shell.
class ActiveSessionScreen extends ConsumerWidget {
  const ActiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textDark),
                    onPressed: () => _confirmLeave(context),
                  ),
                  const Spacer(),
                  Text(
                    'Session in Progress',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 48.w), // balance the close button
                ],
              ),
            ),
            // ── Session content ──────────────────────────────────────────
            const Expanded(
              child: PeerSessionWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave session?'),
        content: const Text(
          'Your progress will be saved, but your peer will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) {
      context.pop();
    }
  }
}
