import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../shared/widgets/custom_button.dart';

/// Session scheduler — lets two peers propose and confirm a meeting slot.
///
/// Flow: guide proposes 3 time slots → learner picks one → both get reminders.
class SessionScheduler extends StatefulWidget {
  const SessionScheduler({super.key});

  @override
  State<SessionScheduler> createState() => _SessionSchedulerState();
}

class _SessionSchedulerState extends State<SessionScheduler> {
  int _step = 0; // 0 = propose slots, 1 = confirm, 2 = done
  final List<DateTime?> _slots = [null, null, null];
  int? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          'Schedule a session',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _step == 0
                ? _ProposeStep(
                    key: const ValueKey(0),
                    slots: _slots,
                    onSlotPicked: (i, dt) =>
                        setState(() => _slots[i] = dt),
                    onContinue: _slots.any((s) => s != null)
                        ? () => setState(() => _step = 1)
                        : null,
                  )
                : _step == 1
                    ? _ConfirmStep(
                        key: const ValueKey(1),
                        slots: _slots
                            .where((s) => s != null)
                            .cast<DateTime>()
                            .toList(),
                        selected: _selectedSlot,
                        onSelect: (i) =>
                            setState(() => _selectedSlot = i),
                        onConfirm: _selectedSlot != null
                            ? () => setState(() => _step = 2)
                            : null,
                      )
                    : _DoneStep(key: const ValueKey(2)),
          ),
        ),
      ),
    );
  }
}

class _ProposeStep extends StatelessWidget {
  final List<DateTime?> slots;
  final void Function(int, DateTime) onSlotPicked;
  final VoidCallback? onContinue;
  const _ProposeStep(
      {super.key,
      required this.slots,
      required this.onSlotPicked,
      this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Propose three time slots',
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        SizedBox(height: 6.h),
        Text(
          'Your peer will confirm one. Try to spread them across different days.',
          style: TextStyle(
              fontSize: 13.sp, height: 1.5, color: AppColors.textMuted),
        ),
        SizedBox(height: 24.h),
        ...List.generate(3, (i) {
          final slot = slots[i];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: now.add(const Duration(days: 1)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 30)),
                );
                if (date == null || !context.mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time == null) return;
                onSlotPicked(
                  i,
                  DateTime(date.year, date.month, date.day,
                      time.hour, time.minute),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: slot != null
                      ? AppColors.accentGreen.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: slot != null
                        ? AppColors.accentGreen
                        : AppColors.borderBeige,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      slot != null ? Icons.check_circle : Icons.add_circle_outline,
                      color: slot != null
                          ? AppColors.accentGreen
                          : AppColors.textMuted,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      slot != null
                          ? '${_weekday(slot.weekday)} ${slot.day}/${slot.month} at ${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}'
                          : 'Slot ${i + 1} — tap to pick a time',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: slot != null
                            ? AppColors.textDark
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        AppButton(
          label: 'Send to peer',
          onPressed: onContinue,
        ),
      ],
    );
  }

  String _weekday(int d) =>
      const ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d];
}

class _ConfirmStep extends StatelessWidget {
  final List<DateTime> slots;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback? onConfirm;
  const _ConfirmStep(
      {super.key,
      required this.slots,
      required this.selected,
      required this.onSelect,
      this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pick your preferred slot',
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        SizedBox(height: 20.h),
        ...slots.asMap().entries.map((e) {
          final isSelected = selected == e.key;
          return GestureDetector(
            onTap: () => onSelect(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentGreen
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGreen
                      : AppColors.borderBeige,
                ),
              ),
              child: Text(
                '${e.value.day}/${e.value.month} at ${e.value.hour.toString().padLeft(2, '0')}:${e.value.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        AppButton(label: 'Confirm session', onPressed: onConfirm),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('✅', style: TextStyle(fontSize: 56.sp)),
        SizedBox(height: 16.h),
        Text('Session confirmed!',
            style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        SizedBox(height: 8.h),
        Text(
            'You\'ll both receive a reminder 24h, 1h, and 15min before.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp, height: 1.5, color: AppColors.textMuted)),
        SizedBox(height: 32.h),
        AppButton(
          label: 'Back to dashboard',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
