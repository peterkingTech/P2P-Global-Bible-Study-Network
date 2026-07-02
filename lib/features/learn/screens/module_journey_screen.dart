import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../core/models/module_model.dart';
import '../../../core/providers/lesson_provider.dart';
import '../widgets/module_card.dart';

/// Horizontal scrollable path of 12 module nodes — the "learning map".
///
/// Completed modules show a green check, the current module pulses gold,
/// locked modules are grey. Tapping a node expands its detail card.
class ModuleJourneyScreen extends ConsumerStatefulWidget {
  const ModuleJourneyScreen({super.key});

  @override
  ConsumerState<ModuleJourneyScreen> createState() =>
      _ModuleJourneyScreenState();
}

class _ModuleJourneyScreenState extends ConsumerState<ModuleJourneyScreen> {
  int? _expandedIndex;
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Journey',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '12 modules · structured discipleship',
                    style: TextStyle(
                        fontSize: 13.sp, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ── Module path (horizontal scroll) ──────────────────────────
            modulesAsync.when(
              loading: () => const _JourneyShimmer(),
              error: (e, _) => Center(
                child: Text('Could not load modules: $e',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              data: (modules) => Expanded(
                child: Column(
                  children: [
                    // The path nodes
                    SizedBox(
                      height: 120.h,
                      child: ListView.separated(
                        controller: _scrollCtrl,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: modules.length,
                        separatorBuilder: (_, __) => _PathLine(),
                        itemBuilder: (_, i) => _ModuleNode(
                          module: modules[i],
                          index: i,
                          isExpanded: _expandedIndex == i,
                          onTap: () {
                            setState(() {
                              _expandedIndex =
                                  _expandedIndex == i ? null : i;
                            });
                          },
                        ),
                      ),
                    ),

                    // Expanded detail card
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: _expandedIndex != null
                          ? Padding(
                              key: ValueKey(_expandedIndex),
                              padding: EdgeInsets.fromLTRB(
                                  20.w, 16.h, 20.w, 0),
                              child: ModuleCard(
                                module: modules[_expandedIndex!],
                                onOpen: () => context.go(Routes.learn),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Module list beneath
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 80.h),
                        itemCount: modules.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (_, i) => ModuleCard(
                          module: modules[i],
                          compact: true,
                          onOpen: () => context.go(Routes.learn),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Path node ─────────────────────────────────────────────────────────────────

class _ModuleNode extends StatefulWidget {
  final ModuleModel module;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;
  const _ModuleNode({
    required this.module,
    required this.index,
    required this.isExpanded,
    required this.onTap,
  });
  @override
  State<_ModuleNode> createState() => _ModuleNodeState();
}

class _ModuleNodeState extends State<_ModuleNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!widget.module.isComplete && widget.module.completedLessons > 0) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    final isComplete = m.isComplete;
    final isCurrent = !isComplete && m.completedLessons > 0;
    final isLocked = !m.isUnlocked;

    Color ringColor;
    if (isComplete) {
      ringColor = AppColors.accentGreen;
    } else if (isCurrent) {
      ringColor = AppColors.amber;
    } else if (isLocked) {
      ringColor = AppColors.borderBeige;
    } else {
      ringColor = AppColors.lightGreen;
    }

    return GestureDetector(
      onTap: isLocked ? null : widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              return Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isExpanded
                      ? ringColor
                      : ringColor.withOpacity(0.12),
                  border: Border.all(
                    color: ringColor,
                    width: isCurrent ? 2.0 + _pulse.value : 2.0,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.amber
                                .withOpacity(0.25 + 0.2 * _pulse.value),
                            blurRadius: 10,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: isComplete
                    ? Icon(Icons.check, size: 22.sp, color: AppColors.accentGreen)
                    : isLocked
                        ? Icon(Icons.lock_outline,
                            size: 18.sp, color: AppColors.borderBeige)
                        : Text(
                            '${widget.index + 1}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: widget.isExpanded
                                  ? Colors.white
                                  : ringColor,
                            ),
                          ),
              );
            },
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: 64.w,
            child: Text(
              m.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                color: isLocked ? AppColors.textMutedLight : AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.w,
      height: 56.h,
      child: Center(
        child: Container(
          width: 20.w,
          height: 2.h,
          color: AppColors.borderBeige,
        ),
      ),
    );
  }
}

class _JourneyShimmer extends StatelessWidget {
  const _JourneyShimmer();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(
          5,
          (i) => Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.borderBeige.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
