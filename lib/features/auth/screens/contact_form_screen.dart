import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../shared/widgets/custom_button.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Contact Form Screen — Peer-to-Peer Global Bible Study Network
// 4-section intake form shown after account creation.
// ──────────────────────────────────────────────────────────────────────────────

class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({super.key});

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  int _section = 0; // 0–3 = four sections
  bool _submitting = false;
  bool _submitted = false;

  // ── Section 1: Basic Information ────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String _primaryLanguage = '';
  final Set<String> _otherLanguages = {};

  // ── Section 2: Spiritual Background ────────────────────────────────────────
  double _faithJourney = 3;
  String _bornAgain = '';
  String _walkingDuration = '';
  String _churchInvolvement = '';

  // ── Section 3: Spiritual Practices ─────────────────────────────────────────
  String _prayerFrequency = '';
  String _bibleFrequency = '';
  final Set<String> _studyHabits = {};

  // ── Section 4: Goals & Preferences ─────────────────────────────────────────
  final _goalsCtrl = TextEditingController();
  String _timeCommitment = '';
  String _learningFormat = '';
  final Set<String> _availability = {};
  String _communicationMethod = '';
  final _timezoneCtrl = TextEditingController();
  final _prevCoursesCtrl = TextEditingController();
  final _specialNeedsCtrl = TextEditingController();
  String _hearAbout = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill email field label with user's auth email
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.userMetadata?['display_name'] != null) {
      _nameCtrl.text = user!.userMetadata!['display_name'] as String;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _goalsCtrl.dispose();
    _timezoneCtrl.dispose();
    _prevCoursesCtrl.dispose();
    _specialNeedsCtrl.dispose();
    super.dispose();
  }

  // ── Validation per section ──────────────────────────────────────────────────

  String? _validateSection() {
    switch (_section) {
      case 0:
        if (_nameCtrl.text.trim().isEmpty) return 'Please enter your full name.';
        if (_locationCtrl.text.trim().isEmpty) return 'Please enter your city & country.';
        if (_primaryLanguage.isEmpty) return 'Please select your primary language.';
        return null;
      case 1:
        if (_bornAgain.isEmpty) return 'Please answer the born-again question.';
        if (_walkingDuration.isEmpty) return 'Please select how long you\'ve been walking with Christ.';
        return null;
      case 2:
        if (_prayerFrequency.isEmpty) return 'Please select your prayer frequency.';
        if (_bibleFrequency.isEmpty) return 'Please select your Bible reading frequency.';
        return null;
      case 3:
        if (_goalsCtrl.text.trim().isEmpty) return 'Please share what you hope to achieve.';
        if (_timeCommitment.isEmpty) return 'Please select your weekly time commitment.';
        if (_learningFormat.isEmpty) return 'Please select your preferred learning format.';
        if (_availability.isEmpty) return 'Please select at least one availability slot.';
        if (_communicationMethod.isEmpty) return 'Please select a communication method.';
        if (_timezoneCtrl.text.trim().isEmpty) return 'Please enter your time zone.';
        return null;
    }
    return null;
  }

  Future<void> _next() async {
    final error = _validateSection();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_section < 3) {
      setState(() => _section++);
    } else {
      await _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    final user = Supabase.instance.client.auth.currentUser;

    final payload = {
      'user_id': user?.id,
      'responses': {
        // Section 1
        'full_name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'contact': _contactCtrl.text.trim(),
        'primary_language': _primaryLanguage,
        'other_languages': _otherLanguages.toList(),
        // Section 2
        'faith_journey_level': _faithJourney.round(),
        'born_again': _bornAgain,
        'walking_duration': _walkingDuration,
        'church_involvement': _churchInvolvement,
        // Section 3
        'prayer_frequency': _prayerFrequency,
        'bible_frequency': _bibleFrequency,
        'study_habits': _studyHabits.toList(),
        // Section 4
        'goals': _goalsCtrl.text.trim(),
        'time_commitment': _timeCommitment,
        'learning_format': _learningFormat,
        'availability': _availability.toList(),
        'communication_method': _communicationMethod,
        'timezone': _timezoneCtrl.text.trim(),
        'previous_courses': _prevCoursesCtrl.text.trim(),
        'special_needs': _specialNeedsCtrl.text.trim(),
        'hear_about': _hearAbout,
      },
    };

    try {
      await Supabase.instance.client
          .from('contact_form_responses')
          .insert(payload);
    } on PostgrestException catch (e) {
      // Gracefully skip if the table has not been created yet (code 42P01).
      // Any other DB error (RLS, network, etc.) surfaces to the user for retry.
      if (e.code != '42P01') {
        if (mounted) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not save your responses: ${e.message}. Please try again.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFB91C1C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: AppColors.lightGreen,
                onPressed: _submit,
              ),
            ),
          );
        }
        return;
      }
    } catch (_) {
      // Non-Supabase error (e.g. no connectivity) — surface and allow retry.
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Network error. Please check your connection and try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFB91C1C),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.lightGreen,
              onPressed: _submit,
            ),
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _submitting = false;
        _submitted = true;
      });
    }
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) context.go(Routes.profileSetup);
  }

  void _skip() => context.go(Routes.profileSetup);

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _SuccessScreen();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(section: _section, onSkip: _skip),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_section),
                    child: _buildSection(),
                  ),
                ),
              ),
            ),
            _Footer(
              section: _section,
              submitting: _submitting,
              onBack: _section > 0 ? () => setState(() => _section--) : null,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection() {
    return switch (_section) {
      0 => _Section1(
          nameCtrl: _nameCtrl,
          locationCtrl: _locationCtrl,
          contactCtrl: _contactCtrl,
          primaryLanguage: _primaryLanguage,
          otherLanguages: _otherLanguages,
          onPrimaryLanguage: (v) => setState(() => _primaryLanguage = v),
          onToggleOther: (v) => setState(() {
            if (_otherLanguages.contains(v)) {
              _otherLanguages.remove(v);
            } else {
              _otherLanguages.add(v);
            }
          }),
        ),
      1 => _Section2(
          faithJourney: _faithJourney,
          bornAgain: _bornAgain,
          walkingDuration: _walkingDuration,
          churchInvolvement: _churchInvolvement,
          onFaithJourney: (v) => setState(() => _faithJourney = v),
          onBornAgain: (v) => setState(() => _bornAgain = v),
          onWalkingDuration: (v) => setState(() => _walkingDuration = v),
          onChurchInvolvement: (v) => setState(() => _churchInvolvement = v),
        ),
      2 => _Section3(
          prayerFrequency: _prayerFrequency,
          bibleFrequency: _bibleFrequency,
          studyHabits: _studyHabits,
          onPrayer: (v) => setState(() => _prayerFrequency = v),
          onBible: (v) => setState(() => _bibleFrequency = v),
          onToggleHabit: (v) => setState(() {
            if (_studyHabits.contains(v)) {
              _studyHabits.remove(v);
            } else {
              _studyHabits.add(v);
            }
          }),
        ),
      _ => _Section4(
          goalsCtrl: _goalsCtrl,
          timeCommitment: _timeCommitment,
          learningFormat: _learningFormat,
          availability: _availability,
          communicationMethod: _communicationMethod,
          timezoneCtrl: _timezoneCtrl,
          prevCoursesCtrl: _prevCoursesCtrl,
          specialNeedsCtrl: _specialNeedsCtrl,
          hearAbout: _hearAbout,
          onTimeCommitment: (v) => setState(() => _timeCommitment = v),
          onLearningFormat: (v) => setState(() => _learningFormat = v),
          onToggleAvailability: (v) => setState(() {
            if (_availability.contains(v)) {
              _availability.remove(v);
            } else {
              _availability.add(v);
            }
          }),
          onCommunicationMethod: (v) => setState(() => _communicationMethod = v),
          onHearAbout: (v) => setState(() => _hearAbout = v),
        ),
    };
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header / progress bar
// ──────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int section;
  final VoidCallback onSkip;
  const _Header({required this.section, required this.onSkip});

  static const _sectionTitles = [
    'Basic Information',
    'Your Faith Journey',
    'Spiritual Practices',
    'Goals & Preferences',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peer-to-Peer Global Bible Study Network',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentGreen,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Contact Form',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.lightGreen.withOpacity(0.6),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Skip', style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Progress bar
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  height: 3.h,
                  margin: EdgeInsets.only(right: i < 3 ? 4.w : 0),
                  decoration: BoxDecoration(
                    color: i <= section
                        ? AppColors.accentGreen
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Section ${section + 1} of 4',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.lightGreen.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              Text(
                _sectionTitles[section],
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightGreen.withOpacity(0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.accentGreen.withOpacity(0.2)),
            ),
            child: Text(
              'Welcome! This form helps us understand your background and goals so we can match you with the best learning experience. All information is kept confidential.',
              style: TextStyle(
                fontSize: 11.5.sp,
                color: AppColors.lightGreen.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Footer nav buttons
// ──────────────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final int section;
  final bool submitting;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  const _Footer({
    required this.section,
    required this.submitting,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            Expanded(
              child: AppButton(
                label: 'Back',
                variant: AppButtonVariant.outlined,
                onPressed: onBack,
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            flex: onBack != null ? 2 : 1,
            child: AppButton(
              label: section < 3 ? 'Continue' : 'Submit',
              isLoading: submitting,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Success screen (brief, then auto-navigates)
// ──────────────────────────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentGreen, width: 2),
              ),
              child: Icon(Icons.check_rounded,
                  color: AppColors.accentGreen, size: 36.sp),
            ),
            SizedBox(height: 20.h),
            Text(
              'Form Submitted!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.cream,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Thank you. Setting up your profile…',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.lightGreen.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ──────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            )),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(subtitle!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.lightGreen.withOpacity(0.6),
                height: 1.4,
              )),
        ],
        SizedBox(height: 20.h),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.cream.withOpacity(0.85),
              fontWeight: FontWeight.w500),
          children: required
              ? [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                        color: AppColors.accentGreen, fontSize: 13.sp),
                  )
                ]
              : [],
        ),
      ),
    );
  }
}

InputDecoration _darkInput(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.25), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );

class _RadioGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _RadioGroup({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentGreen.withOpacity(0.12)
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGreen
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.accentGreen
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentGreen
                          : Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.black, size: 12.sp)
                      : null,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(opt,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isSelected ? AppColors.cream : AppColors.cream.withOpacity(0.7),
                      )),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onToggle(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentGreen
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(99.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGreen
                    : Colors.white.withOpacity(0.12),
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF06110D) : AppColors.cream.withOpacity(0.75),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Section 1: Basic Information
// ──────────────────────────────────────────────────────────────────────────────

class _Section1 extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController contactCtrl;
  final String primaryLanguage;
  final Set<String> otherLanguages;
  final ValueChanged<String> onPrimaryLanguage;
  final ValueChanged<String> onToggleOther;

  const _Section1({
    required this.nameCtrl,
    required this.locationCtrl,
    required this.contactCtrl,
    required this.primaryLanguage,
    required this.otherLanguages,
    required this.onPrimaryLanguage,
    required this.onToggleOther,
  });

  static const _langs = [
    'English', 'German', 'Spanish', 'Portuguese',
    'French', 'Arabic', 'Ukrainian/Russian', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Basic Information',
          subtitle: 'Tell us a bit about yourself.',
        ),

        const _FieldLabel('Full Name'),
        TextField(
          controller: nameCtrl,
          style: TextStyle(fontSize: 14, color: AppColors.cream),
          decoration: _darkInput('Your full name'),
        ),
        SizedBox(height: 14.h),

        const _FieldLabel('Location (City & Country)'),
        TextField(
          controller: locationCtrl,
          style: TextStyle(fontSize: 14, color: AppColors.cream),
          decoration: _darkInput('e.g. Lagos, Nigeria'),
        ),
        SizedBox(height: 14.h),

        const _FieldLabel('Contact / Phone', required: false),
        TextField(
          controller: contactCtrl,
          keyboardType: TextInputType.phone,
          style: TextStyle(fontSize: 14, color: AppColors.cream),
          decoration: _darkInput('Optional — WhatsApp or phone number'),
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('Primary Language'),
        _RadioGroup(
          options: _langs,
          selected: primaryLanguage,
          onSelect: onPrimaryLanguage,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('Other Languages You Speak', required: false),
        _ChipGroup(
          options: _langs,
          selected: otherLanguages,
          onToggle: onToggleOther,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Section 2: Spiritual Background
// ──────────────────────────────────────────────────────────────────────────────

class _Section2 extends StatelessWidget {
  final double faithJourney;
  final String bornAgain;
  final String walkingDuration;
  final String churchInvolvement;
  final ValueChanged<double> onFaithJourney;
  final ValueChanged<String> onBornAgain;
  final ValueChanged<String> onWalkingDuration;
  final ValueChanged<String> onChurchInvolvement;

  const _Section2({
    required this.faithJourney,
    required this.bornAgain,
    required this.walkingDuration,
    required this.churchInvolvement,
    required this.onFaithJourney,
    required this.onBornAgain,
    required this.onWalkingDuration,
    required this.onChurchInvolvement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Your Faith Journey',
          subtitle: 'Help us understand where you are spiritually.',
        ),

        // Faith journey slider
        const _FieldLabel('Where are you on your faith journey?'),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text('Just exploring',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.lightGreen.withOpacity(0.55))),
                  ),
                  Flexible(
                    child: Text('Mature believer,\nleading others',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.lightGreen.withOpacity(0.55))),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accentGreen,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  thumbColor: AppColors.accentGreen,
                  overlayColor: AppColors.accentGreen.withOpacity(0.15),
                  valueIndicatorColor: AppColors.accentGreen,
                  valueIndicatorTextStyle:
                      const TextStyle(color: Colors.black),
                ),
                child: Slider(
                  value: faithJourney,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: faithJourney.round().toString(),
                  onChanged: onFaithJourney,
                ),
              ),
              Text(
                'Level ${faithJourney.round()} of 5',
                style: TextStyle(
                    fontSize: 12.sp, color: AppColors.accentGreen),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('Have you been born again (accepted Jesus as your Savior)?'),
        _RadioGroup(
          options: const [
            'Yes, I have been born again',
            'I\'m not sure what this means',
            'I prefer not to say',
            'Other',
          ],
          selected: bornAgain,
          onSelect: onBornAgain,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('How long have you been walking with Christ?'),
        _RadioGroup(
          options: const [
            'I\'m still exploring faith',
            'Less than 1 year',
            '3–5 years',
            '5–10 years',
            'More than 10 years',
          ],
          selected: walkingDuration,
          onSelect: onWalkingDuration,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('Current Church Involvement', required: false),
        _RadioGroup(
          options: const [
            'I don\'t currently attend church',
            'I\'m a regular member',
            'I\'m in a small group / home fellowship',
            'I serve in ministry / leadership',
            'I\'m a pastor / ministry leader',
          ],
          selected: churchInvolvement,
          onSelect: onChurchInvolvement,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Section 3: Current Spiritual Practices
// ──────────────────────────────────────────────────────────────────────────────

class _Section3 extends StatelessWidget {
  final String prayerFrequency;
  final String bibleFrequency;
  final Set<String> studyHabits;
  final ValueChanged<String> onPrayer;
  final ValueChanged<String> onBible;
  final ValueChanged<String> onToggleHabit;

  const _Section3({
    required this.prayerFrequency,
    required this.bibleFrequency,
    required this.studyHabits,
    required this.onPrayer,
    required this.onBible,
    required this.onToggleHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Your Current Spiritual Rhythm',
          subtitle: 'No right or wrong answers — be honest!',
        ),

        const _FieldLabel('How often do you pray?'),
        _RadioGroup(
          options: const [
            'Multiple times a day',
            'Most days',
            'A few times a week',
            'Once a week or less',
            'Rarely / Never',
          ],
          selected: prayerFrequency,
          onSelect: onPrayer,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('How often do you read the Bible?'),
        _RadioGroup(
          options: const [
            'Daily devotional / study',
            'Most days',
            'A few times a week',
            'Once a week (church service)',
            'Rarely / Never',
          ],
          selected: bibleFrequency,
          onSelect: onBible,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('What Bible study habits do you currently have?', required: false),
        _ChipGroup(
          options: const [
            'Personal quiet time / devotionals',
            'Family Bible time',
            'Church small group',
            'Online Bible studies',
            'Bible study apps (YouVersion, etc.)',
            'None yet',
          ],
          selected: studyHabits,
          onToggle: onToggleHabit,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Section 4: Course Goals & Preferences
// ──────────────────────────────────────────────────────────────────────────────

class _Section4 extends StatelessWidget {
  final TextEditingController goalsCtrl;
  final String timeCommitment;
  final String learningFormat;
  final Set<String> availability;
  final String communicationMethod;
  final TextEditingController timezoneCtrl;
  final TextEditingController prevCoursesCtrl;
  final TextEditingController specialNeedsCtrl;
  final String hearAbout;
  final ValueChanged<String> onTimeCommitment;
  final ValueChanged<String> onLearningFormat;
  final ValueChanged<String> onToggleAvailability;
  final ValueChanged<String> onCommunicationMethod;
  final ValueChanged<String> onHearAbout;

  const _Section4({
    required this.goalsCtrl,
    required this.timeCommitment,
    required this.learningFormat,
    required this.availability,
    required this.communicationMethod,
    required this.timezoneCtrl,
    required this.prevCoursesCtrl,
    required this.specialNeedsCtrl,
    required this.hearAbout,
    required this.onTimeCommitment,
    required this.onLearningFormat,
    required this.onToggleAvailability,
    required this.onCommunicationMethod,
    required this.onHearAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Almost Done!',
          subtitle: 'Your learning goals & preferences.',
        ),

        const _FieldLabel('What do you hope to achieve through this course?'),
        TextField(
          controller: goalsCtrl,
          minLines: 3,
          maxLines: 5,
          style: TextStyle(fontSize: 13.sp, color: AppColors.cream),
          decoration: _darkInput('Share your goals, expectations, or anything on your heart…'),
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('How much time can you commit per week?'),
        _RadioGroup(
          options: const [
            '1–2 hours (light track)',
            '3–5 hours (standard track)',
            '5–10 hours (intensive track)',
            '10+ hours (immersion track)',
          ],
          selected: timeCommitment,
          onSelect: onTimeCommitment,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('What learning format do you prefer?'),
        _RadioGroup(
          options: const [
            'One-on-one mentorship (most personalized)',
            'Small group (3–5 people)',
            'Medium group (6–12 people)',
            'Large group (13+ people)',
            'No preference — I\'m flexible',
          ],
          selected: learningFormat,
          onSelect: onLearningFormat,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('When are you usually available? (Select all that apply)'),
        _ChipGroup(
          options: const [
            'Weekday mornings',
            'Weekday afternoons',
            'Weekday evenings',
            'Saturday',
            'Sunday',
            'My schedule varies',
          ],
          selected: availability,
          onToggle: onToggleAvailability,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('Preferred communication method'),
        _RadioGroup(
          options: const [
            'Video calls (Zoom / Google Meet)',
            'Voice calls only',
            'In-person (if available in my area)',
          ],
          selected: communicationMethod,
          onSelect: onCommunicationMethod,
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('What time zone are you in?'),
        TextField(
          controller: timezoneCtrl,
          style: TextStyle(fontSize: 14, color: AppColors.cream),
          decoration: _darkInput('e.g. EST (New York), GMT (London), WAT (Lagos)'),
        ),
        SizedBox(height: 14.h),

        const _FieldLabel('Previous Bible courses or training', required: false),
        TextField(
          controller: prevCoursesCtrl,
          minLines: 2,
          maxLines: 3,
          style: TextStyle(fontSize: 13.sp, color: AppColors.cream),
          decoration: _darkInput('List any relevant courses, certifications, or training (optional)'),
        ),
        SizedBox(height: 14.h),

        const _FieldLabel('Any special needs or accommodations?', required: false),
        TextField(
          controller: specialNeedsCtrl,
          minLines: 2,
          maxLines: 3,
          style: TextStyle(fontSize: 13.sp, color: AppColors.cream),
          decoration: _darkInput('Learning preferences, accessibility needs, or anything that would help us serve you better'),
        ),
        SizedBox(height: 20.h),

        const _FieldLabel('How did you hear about this course?', required: false),
        _RadioGroup(
          options: const [
            'Church / Pastor recommendation',
            'Friend / Family member',
            'Social media (Facebook, Instagram, etc.)',
            'Google search',
            'Other',
          ],
          selected: hearAbout,
          onSelect: onHearAbout,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
