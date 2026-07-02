import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';

/// Four large cards letting the user pick how they want to find a peer.
class MatchPathSelector extends StatelessWidget {
  const MatchPathSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          'Find a Peer',
          style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How would you like to connect?',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Choose the path that fits your situation.',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
              ),
              SizedBox(height: 24.h),
              _PathCard(
                emoji: '💌',
                title: 'Invite someone I know',
                description:
                    'Generate a personal link and share it with a specific friend, family member, or colleague.',
                tag: 'Best for existing relationships',
                tagColor: AppColors.amber,
                onTap: () => context.go(Routes.invitePeer),
              ),
              SizedBox(height: 14.h),
              _PathCard(
                emoji: '🔍',
                title: 'Browse available peers',
                description:
                    'Filter by language, timezone, tree stage, gifts, and availability to find someone compatible.',
                tag: 'Browse & request',
                tagColor: AppColors.accentGreen,
                onTap: () => context.go(Routes.discoverySearch),
              ),
              SizedBox(height: 14.h),
              _PathCard(
                emoji: '🤖',
                title: 'Smart match me',
                description:
                    'Answer a few quick questions and we\'ll find your top 3 matches using our pairing algorithm.',
                tag: 'Recommended for new users',
                tagColor: AppColors.primaryGreen,
                onTap: () => context.go(Routes.smartMatch),
              ),
              SizedBox(height: 14.h),
              _PathCard(
                emoji: '⛪',
                title: 'Join a group',
                description:
                    'Enter a 6-character code from your church or organisation to connect with members from your community.',
                tag: 'Churches & organisations',
                tagColor: AppColors.textMid,
                onTap: () => context.go(Routes.groupJoin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final VoidCallback onTap;

  const _PathCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.borderBeige),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: TextStyle(fontSize: 32.sp)),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.55,
                        color: AppColors.textMid,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.chevron_right,
                  size: 20.sp, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
