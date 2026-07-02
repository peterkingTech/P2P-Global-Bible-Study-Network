import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../shared/widgets/custom_button.dart';

/// Weekly Challenge — a step-by-step evangelism / action challenge.
class WeeklyChallenge extends StatefulWidget {
  const WeeklyChallenge({super.key});

  @override
  State<WeeklyChallenge> createState() => _WeeklyChallengeState();
}

class _WeeklyChallengeState extends State<WeeklyChallenge> {
  bool _committed = false;
  bool _completed = false;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          'Weekly Challenge',
          style: TextStyle(
              fontSize: 16.sp,
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
              // Challenge card
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.accentGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 40.sp)),
                    SizedBox(height: 12.h),
                    Text(
                      'Share Your Story',
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cream),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'This week, share what God has done in your life with one person who doesn\'t yet know Him.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.6,
                          color: AppColors.lightGreen.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Step by step guide
              _Step(number: 1, title: 'Pray first', body: 'Ask God for an open door and the right words.'),
              _Step(number: 2, title: 'Choose someone', body: 'Think of one person — a friend, family member, or colleague.'),
              _Step(number: 3, title: 'Share naturally', body: 'Tell them what God has done in your life. Keep it personal and brief.'),
              _Step(number: 4, title: 'Listen', body: 'Let them respond. Ask questions. Don\'t rush.'),
              _Step(number: 5, title: 'Follow up', body: 'Invite them to hear more or offer to pray together.'),

              SizedBox(height: 24.h),

              // Commitment
              if (!_committed)
                AppButton(
                  label: 'I commit to this challenge ✓',
                  onPressed: () => setState(() => _committed = true),
                )
              else if (!_completed) ...[
                Text(
                  'Report back',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'What happened? How did it go?',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.borderBeige),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.borderBeige),
                    ),
                    contentPadding: EdgeInsets.all(12.r),
                  ),
                ),
                SizedBox(height: 14.h),
                AppButton(
                  label: 'Submit report 🌱',
                  onPressed: _notesCtrl.text.trim().isNotEmpty
                      ? () => setState(() => _completed = true)
                      : null,
                ),
              ] else
                _CompletedBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String body;
  const _Step({required this.number, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen,
            ),
            alignment: Alignment.center,
            child: Text('$number',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                SizedBox(height: 2.h),
                Text(body,
                    style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.5,
                        color: AppColors.textMid)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.accentGreen.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text('🍎', style: TextStyle(fontSize: 36.sp)),
          SizedBox(height: 8.h),
          Text(
            'Challenge complete!',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen),
          ),
          SizedBox(height: 6.h),
          Text(
            'A fruit has appeared on your tree.',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
