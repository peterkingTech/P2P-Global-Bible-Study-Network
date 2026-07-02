import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../../config/theme.dart';
import '../../../core/providers/invite_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_skeleton.dart';

/// Invite Peer — generates a unique link, shows QR code, and share sheet.
class InvitePeerScreen extends ConsumerStatefulWidget {
  const InvitePeerScreen({super.key});

  @override
  ConsumerState<InvitePeerScreen> createState() => _InvitePeerScreenState();
}

class _InvitePeerScreenState extends ConsumerState<InvitePeerScreen> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final inviteAsync = ref.watch(inviteLinkProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          'Invite a friend',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: inviteAsync.when(
            loading: () => const LoadingSkeleton(),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Could not generate link: $e',
                      textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  AppButton(
                    label: 'Try again',
                    onPressed: () => ref.invalidate(inviteLinkProvider),
                  ),
                ],
              ),
            ),
            data: (link) => _InviteContent(
              link: link,
              copied: _copied,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: link));
                setState(() => _copied = true);
                Future.delayed(const Duration(seconds: 2),
                    () => mounted ? setState(() => _copied = false) : null);
              },
              onShare: () => Share.share(
                '🌱 Join me on P2P Global Bible Study!\n\n'
                'I\'ve been growing in my faith with a peer guide and want to study with you.\n\n'
                'Start here: $link\n\n'
                '(Link expires in 7 days)',
                subject: 'Study the Bible with me',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteContent extends StatelessWidget {
  final String link;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _InviteContent({
    required this.link,
    required this.copied,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Share your personal invite link',
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        SizedBox(height: 8.h),
        Text(
          'When they sign up through your link, you\'ll be automatically matched as guide and learner. Link expires in 7 days.',
          style: TextStyle(
              fontSize: 13.sp, height: 1.55, color: AppColors.textMuted),
        ),
        SizedBox(height: 28.h),

        // Link box
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderBeige),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  link,
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primaryGreen,
                      fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Semantics(
                button: true,
                label: copied ? 'Copied!' : 'Copy link',
                child: GestureDetector(
                  onTap: onCopy,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: copied
                          ? AppColors.accentGreen
                          : AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      copied ? 'Copied!' : 'Copy',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            copied ? Colors.white : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        // QR code placeholder (integrate qr_flutter package for real QR)
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderBeige),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_2,
                  size: 80.sp, color: AppColors.primaryGreen),
              SizedBox(height: 6.h),
              Text(
                'QR Code',
                style: TextStyle(
                    fontSize: 12.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        // Share options
        AppButton(
          label: '📤 Share via WhatsApp / SMS / Email',
          onPressed: onShare,
        ),

        SizedBox(height: 12.h),

        // Rate-limit note
        Center(
          child: Text(
            'You can send up to 5 invites per day.',
            style: TextStyle(fontSize: 11.sp, color: AppColors.textMutedLight),
          ),
        ),
      ],
    );
  }
}
