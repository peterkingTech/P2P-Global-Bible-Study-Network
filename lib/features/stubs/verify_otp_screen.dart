import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/custom_button.dart';

/// OTP verification screen — shown after email magic-link / OTP sign-up.
/// The user enters the 6-digit code from their email.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _error;

  String get _otp => _ctrls.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // TODO: call authService.verifyOtp(_otp) once implemented
      await Future.delayed(const Duration(seconds: 1)); // placeholder
      if (!mounted) return;
      context.go(Routes.profileSetup);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackButton(
                color: AppColors.textDark,
                onPressed: () => context.go(Routes.register),
              ),
              SizedBox(height: 32.h),
              Text(
                'Check your email',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter the 6-digit code we sent you.',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 40.h),
              // ── OTP boxes ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 46.w,
                    height: 56.h,
                    child: TextFormField(
                      controller: _ctrls[i],
                      focusNode: _nodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.lightCream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: AppColors.borderBeige),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: AppColors.primaryGreen, width: 2),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _nodes[i + 1].requestFocus();
                        }
                        if (_otp.length == 6) _verify();
                      },
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                SizedBox(height: 16.h),
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red, fontSize: 13.sp),
                ),
              ],
              SizedBox(height: 32.h),
              AppButton(
                label: 'Verify',
                onPressed: _otp.length == 6 ? _verify : null,
                isLoading: _loading,
              ),
              SizedBox(height: 16.h),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: resend OTP via authService
                  },
                  child: Text(
                    'Resend code',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
