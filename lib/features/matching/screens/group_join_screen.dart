import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/providers/group_provider.dart';
import '../../../shared/widgets/custom_button.dart';

/// Group Join — enter a 6-char code or create a new group.
class GroupJoinScreen extends ConsumerStatefulWidget {
  const GroupJoinScreen({super.key});

  @override
  ConsumerState<GroupJoinScreen> createState() => _GroupJoinScreenState();
}

class _GroupJoinScreenState extends ConsumerState<GroupJoinScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _codeCtrl = TextEditingController();
  final _groupNameCtrl = TextEditingController();
  String? _errorText;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _codeCtrl.dispose();
    _groupNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _errorText = 'Please enter a 6-character code.');
      return;
    }
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await ref.read(groupNotifierProvider.notifier).joinGroup(code);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createGroup() async {
    final name = _groupNameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter a group name.');
      return;
    }
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await ref.read(groupNotifierProvider.notifier).createGroup(name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          'Group',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [Tab(text: 'Join'), Tab(text: 'Create')],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: TabBarView(
          controller: _tabs,
          children: [
            // ── Join tab ───────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Enter group code',
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Ask your church leader or group admin for the 6-character code.',
                  style: TextStyle(
                      fontSize: 13.sp, height: 1.5, color: AppColors.textMuted),
                ),
                SizedBox(height: 28.h),
                TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: AppColors.primaryGreen,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'ABC123',
                    hintStyle: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 8,
                        color: AppColors.borderBeige),
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
                    contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                  ),
                  onChanged: (_) => setState(() => _errorText = null),
                ),
                if (_errorText != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    _errorText!,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.redAccent),
                  ),
                ],
                const Spacer(),
                AppButton(
                  label: _loading ? 'Joining…' : 'Join group',
                  onPressed: _loading ? null : _joinGroup,
                ),
              ],
            ),

            // ── Create tab ─────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Create a group',
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Give your church or organisation a name. A 6-character code will be generated for members to join.',
                  style: TextStyle(
                      fontSize: 13.sp, height: 1.5, color: AppColors.textMuted),
                ),
                SizedBox(height: 28.h),
                TextField(
                  controller: _groupNameCtrl,
                  style: TextStyle(
                      fontSize: 16.sp, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'e.g. City Church Nairobi',
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
                    contentPadding: EdgeInsets.all(14.r),
                  ),
                  onChanged: (_) => setState(() => _errorText = null),
                ),
                if (_errorText != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    _errorText!,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.redAccent),
                  ),
                ],
                const Spacer(),
                AppButton(
                  label: _loading ? 'Creating…' : 'Create group',
                  onPressed: _loading ? null : _createGroup,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
