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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authNotifierProvider.notifier).signUp(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _nameCtrl.text.trim(),
        );
    if (ok && mounted) context.go(Routes.contactForm);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightGreen),
          onPressed: () => context.go(Routes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Plant your tree',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Create your P2P Global Bible Study account',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.lightGreen.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: 32.h),

                if (auth.error != null) ...[
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB91C1C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: const Color(0xFFB91C1C).withOpacity(0.4)),
                    ),
                    child: Text(auth.error!,
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFFFCA5A5))),
                  ),
                  SizedBox(height: 16.h),
                ],

                AuthField(
                  controller: _nameCtrl,
                  label: 'Display name',
                  validator: Validators.displayName,
                ),
                SizedBox(height: 12.h),
                AuthField(
                  controller: _emailCtrl,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                SizedBox(height: 12.h),
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
                SizedBox(height: 12.h),
                AuthField(
                  controller: _confirmCtrl,
                  label: 'Confirm password',
                  obscure: _obscure,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordCtrl.text),
                ),

                SizedBox(height: 24.h),

                AppButton(
                  label: 'Create account',
                  isLoading: auth.isLoading,
                  onPressed: _submit,
                ),

                SizedBox(height: 16.h),

                Text(
                  'By creating an account you agree to our Terms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.lightGreen.withOpacity(0.4),
                    height: 1.5,
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
