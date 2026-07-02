import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/gift_selection_grid.dart';
import '../widgets/tree_planting_animation.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _step = 0; // 0=city, 1=language, 2=gifts, 3=animation
  final _cityCtrl = TextEditingController();
  String _country = '';
  String _language = 'en';
  final Set<SpiritualGift> _gifts = {};

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    await ref.read(authServiceProvider).updateProfile(uid, {
      'city': _cityCtrl.text.trim(),
      'country': _country,
      'language_code': _language,
      'gifts': _gifts.map((g) => g.name).toList(),
    });

    // Show tree planting animation, then go home
    setState(() => _step = 3);
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 3) {
      return TreePlantingAnimation(
        onComplete: () => context.go(Routes.home),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step indicator
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      height: 3.h,
                      margin: EdgeInsets.only(right: i < 2 ? 4.w : 0),
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? AppColors.accentGreen
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 32.h),

              if (_step == 0) _LocationStep(ctrl: _cityCtrl),
              if (_step == 1) _LanguageStep(
                selected: _language,
                onSelect: (l) => setState(() => _language = l),
              ),
              if (_step == 2) GiftSelectionGrid(
                selected: _gifts,
                onToggle: (g) => setState(() {
                  if (_gifts.contains(g)) {
                    _gifts.remove(g);
                  } else {
                    _gifts.add(g);
                  }
                }),
              ),

              const Spacer(),

              AppButton(
                label: _step < 2 ? 'Continue' : 'Plant my tree 🌱',
                onPressed: () {
                  if (_step < 2) {
                    setState(() => _step++);
                  } else {
                    _finish();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  final TextEditingController ctrl;
  const _LocationStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where are you planted?',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.cream,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Your city helps connect you with believers nearby and places your tree on the Global Forest map.',
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.5,
            color: AppColors.lightGreen.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 24.h),
        TextField(
          controller: ctrl,
          style: TextStyle(fontSize: 14.sp, color: AppColors.cream),
          decoration: InputDecoration(
            labelText: 'City',
            labelStyle: TextStyle(
                color: AppColors.lightGreen.withOpacity(0.6), fontSize: 13.sp),
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
                  const BorderSide(color: AppColors.accentGreen, width: 1.5),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ],
    );
  }
}

class _LanguageStep extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _LanguageStep({required this.selected, required this.onSelect});

  static const _langs = [
    ('en', '🇬🇧', 'English'),
    ('de', '🇩🇪', 'Deutsch'),
    ('fr', '🇫🇷', 'Français'),
    ('es', '🇪🇸', 'Español'),
    ('pt', '🇧🇷', 'Português'),
    ('zh', '🇨🇳', '中文'),
    ('ar', '🇸🇦', 'العربية'),
    ('hi', '🇮🇳', 'हिन्दी'),
    ('sw', '🇰🇪', 'Kiswahili'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What language do you study in?',
          style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.cream),
        ),
        SizedBox(height: 20.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _langs.map((l) {
            final isSelected = l.$1 == selected;
            return GestureDetector(
              onTap: () => onSelect(l.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGreen
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentGreen
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  '${l.$2} ${l.$3}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? const Color(0xFF06110D) : AppColors.cream,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
