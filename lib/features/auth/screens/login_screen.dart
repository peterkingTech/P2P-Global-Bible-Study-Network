import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/auth_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authNotifierProvider.notifier).signIn(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (ok && mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.h),

                // P2P Official Logo
                Center(
                  child: ClipOval(
                    child: Image.network(
                      'https://omkqkasniakcnmfcwrvs.supabase.co/storage/v1/object/public/P2P%20Official%20Logo/P2P%20Official%20Logo.png',
                      width: 72.r,
                      height: 72.r,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentGreen.withOpacity(0.15),
                          border: Border.all(
                            color: AppColors.accentGreen.withOpacity(0.4),
                          ),
                        ),
                        child: Icon(Icons.menu_book_outlined,
                            color: AppColors.lightGreen, size: 32.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Continue your discipleship journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.lightGreen.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: 40.h),

                // Error banner
                if (auth.error != null) ...[
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB91C1C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: const Color(0xFFB91C1C).withOpacity(0.4)),
                    ),
                    child: Text(
                      auth.error!,
                      style: TextStyle(
                          fontSize: 13.sp, color: const Color(0xFFFCA5A5)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Email
                AuthField(
                  controller: _emailCtrl,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                SizedBox(height: 12.h),

                // Password
                AuthField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  obscure: _obscure,
                  validator: Validators.password,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 18.sp,
                      color: AppColors.lightGreen.withAlpha(153),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: navigate to password reset flow
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.lightGreen.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                AppButton(
                  label: 'Sign in',
                  isLoading: auth.isLoading,
                  onPressed: _submit,
                ),

                SizedBox(height: 24.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New here? ',
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.lightGreen.withOpacity(0.6)),
                    ),
                    GestureDetector(
                      onTap: () => context.go(Routes.register),
                      child: Text(
                        'Create an account',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element — AuthField is now in auth_field.dart
class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14.sp, color: AppColors.cream),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontSize: 13.sp, color: AppColors.lightGreen.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: AppColors.accentGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFB91C1C)),
        ),
        suffixIcon: suffix,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}
