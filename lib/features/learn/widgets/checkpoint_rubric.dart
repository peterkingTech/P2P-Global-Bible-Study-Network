import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

/// Displays a peer-checkpoint rubric as a checklist of criteria.
/// [criteria] is a list of strings parsed from the lesson's Markdown rubric.
class CheckpointRubric extends StatefulWidget {
  final List<String> criteria;
  final ValueChanged<bool>? onAllChecked;

  const CheckpointRubric({
    super.key,
    required this.criteria,
    this.onAllChecked,
  });

  @override
  State<CheckpointRubric> createState() => _CheckpointRubricState();
}

class _CheckpointRubricState extends State<CheckpointRubric> {
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List.filled(widget.criteria.length, false);
  }

  void _toggle(int i) {
    setState(() => _checked[i] = !_checked[i]);
    final allDone = _checked.every((c) => c);
    widget.onAllChecked?.call(allDone);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checkpoint criteria',
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        SizedBox(height: 10.h),
        ...widget.criteria.asMap().entries.map((e) {
          final checked = _checked[e.key];
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Semantics(
              toggled: checked,
              label: e.value,
              button: true,
              child: GestureDetector(
                onTap: () => _toggle(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: checked
                        ? AppColors.accentGreen.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: checked
                          ? AppColors.accentGreen
                          : AppColors.borderBeige,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: checked
                              ? AppColors.accentGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: checked
                                ? AppColors.accentGreen
                                : AppColors.borderBeige,
                          ),
                        ),
                        child: checked
                            ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: checked
                                ? AppColors.primaryGreen
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
