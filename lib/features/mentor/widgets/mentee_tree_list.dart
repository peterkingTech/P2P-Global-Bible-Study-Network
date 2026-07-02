import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/tree_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/living_tree/widgets/living_tree_widget.dart';

/// Vertical list of mini trees for all of a mentor's disciples.
class MenteeTreeList extends StatelessWidget {
  final List<TreeModel> trees;
  const MenteeTreeList({super.key, required this.trees});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: trees
          .map((t) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _MenteeRow(tree: t),
              ))
          .toList(),
    );
  }
}

class _MenteeRow extends StatelessWidget {
  final TreeModel tree;
  const _MenteeRow({required this.tree});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderBeige),
      ),
      child: Row(
        children: [
          LivingTreeWidget(level: tree.level, mini: true),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${tree.level} tree',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${tree.studiesCompleted} studies · ${tree.streakDays}d streak',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.textMuted),
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: tree.progressToNext,
                    minHeight: 4.h,
                    backgroundColor: AppColors.borderBeige,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.accentGreen),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          if (tree.lastStudyAt != null)
            Text(
              Formatters.relativeDate(tree.lastStudyAt!),
              style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
