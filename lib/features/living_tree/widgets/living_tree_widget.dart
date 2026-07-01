import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../models/growth_stage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LivingTreeWidget — mirrors living-tree.tsx
// ─────────────────────────────────────────────────────────────────────────────

class LivingTreeWidget extends StatelessWidget {
  final int? level;           // explicit stage level 0-5
  final GrowthMetrics? metrics; // when provided, stage is derived
  final bool mini;
  final ValueChanged<ZoneId>? onZoneSelect;

  const LivingTreeWidget({
    super.key,
    this.level,
    this.metrics,
    this.mini = false,
    this.onZoneSelect,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLevel = _resolveLevel();
    if (mini) return _MiniTree(level: resolvedLevel);
    return _FullTree(
      level: resolvedLevel,
      metrics: metrics,
      growth: metrics != null ? computeGrowth(metrics!) : null,
      onZoneSelect: onZoneSelect,
    );
  }

  int _resolveLevel() {
    if (metrics != null) return computeGrowth(metrics!).level;
    return (level ?? 0).clamp(0, kGrowthStages.length - 1).toInt();
  }
}

// ── Mini Variant ─────────────────────────────────────────────────────────────

class _MiniTree extends StatefulWidget {
  final int level;
  const _MiniTree({required this.level});

  @override
  State<_MiniTree> createState() => _MiniTreeState();
}

class _MiniTreeState extends State<_MiniTree>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathe;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathe, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = getStage(widget.level);
    return Semantics(
      label: 'Growth stage: ${stage.name}',
      child: Container(
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderBeige, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Stage image (breathe animation)
            ScaleTransition(
              scale: _scale,
              child: Image.asset(
                stage.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderTreeImage(
                  emoji: stage.emoji,
                  color: AppColors.accentGreen.withOpacity(0.3),
                ),
              ),
            ),
            // Soft living sheen
            _GlowOverlay(breathe: _breathe),
            // Emoji badge
            Positioned(
              bottom: 2,
              right: 2,
              child: Text(
                stage.emoji,
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full Variant ──────────────────────────────────────────────────────────────

class _FullTree extends StatefulWidget {
  final int level;
  final GrowthMetrics? metrics;
  final GrowthResult? growth;
  final ValueChanged<ZoneId>? onZoneSelect;

  const _FullTree({
    required this.level,
    this.metrics,
    this.growth,
    this.onZoneSelect,
  });

  @override
  State<_FullTree> createState() => _FullTreeState();
}

class _FullTreeState extends State<_FullTree>
    with SingleTickerProviderStateMixin {
  ZoneId? _activeZone;
  late AnimationController _breathe;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _breathe, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  void _selectZone(ZoneId id) {
    setState(() => _activeZone = _activeZone == id ? null : id);
    widget.onZoneSelect?.call(id);
  }

  @override
  Widget build(BuildContext context) {
    final stage = getStage(widget.level);
    final growth = widget.growth;
    final nextStage = (growth != null && !growth.isMax)
        ? kGrowthStages[growth.level + 1]
        : null;
    final active = kTapZones.cast<TapZone?>().firstWhere(
          (z) => z?.id == _activeZone,
          orElse: () => null,
        );

    return Semantics(
      label: 'Living Tree — ${stage.name}',
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.veryLightBeige, AppColors.cardBeige],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.borderBeige),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Stage header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stage ${stage.level + 1} of ${kGrowthStages.length}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.8,
                          color: AppColors.amber,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text(stage.emoji, style: TextStyle(fontSize: 22.sp)),
                          SizedBox(width: 6.w),
                          Text(
                            stage.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _StageDots(currentLevel: stage.level),
                ],
              ),
            ),

            // ── Progress bar (when driven by metrics)
            if (growth != null)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
                child: _GrowthProgress(
                  growth: growth,
                  nextStage: nextStage,
                ),
              ),

            // ── Tree image with tap zones
            Padding(
              padding: EdgeInsets.fromLTRB(0, 14.h, 0, 0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.borderBeige),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Breathe animation on image
                      ScaleTransition(
                        scale: _scale,
                        child: Image.asset(
                          stage.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _PlaceholderTreeImage(
                            emoji: stage.emoji,
                            color: AppColors.accentGreen.withOpacity(0.2),
                          ),
                        ),
                      ),
                      // Sunlit glow
                      _GlowOverlay(breathe: _breathe),
                      // Vignette
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF1A2E10).withOpacity(0.25),
                            ],
                          ),
                        ),
                      ),
                      // Tap zones
                      ...kTapZones.map((zone) => _TapZoneButton(
                            zone: zone,
                            isActive: _activeZone == zone.id,
                            onTap: () => _selectZone(zone.id),
                          )),
                      // Stage caption chip
                      Positioned(
                        bottom: 10.h,
                        left: 10.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(stage.emoji,
                                  style: TextStyle(fontSize: 10.sp)),
                              SizedBox(width: 4.w),
                              Text(
                                stage.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Info panel
            Container(
              constraints: BoxConstraints(minHeight: 120.h),
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF7EE).withOpacity(0.70),
                border: const Border(
                    top: BorderSide(color: AppColors.borderBeige)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: active != null
                    ? _ZoneDetail(
                        key: ValueKey(active.id),
                        zone: active,
                        metrics: widget.metrics,
                        onBack: () => setState(() => _activeZone = null),
                      )
                    : _StageDescription(
                        key: ValueKey('stage-${stage.id}'),
                        stage: stage,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StageDots extends StatelessWidget {
  final int currentLevel;
  const _StageDots({required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: kGrowthStages.map((s) {
        Color color;
        BoxDecoration decoration;
        if (s.level < currentLevel) {
          color = AppColors.stageDotDone;
          decoration = BoxDecoration(color: color, shape: BoxShape.circle);
        } else if (s.level == currentLevel) {
          color = AppColors.stageDotCurrent;
          decoration = BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.stageDotCurrent.withOpacity(0.25),
                  blurRadius: 4,
                  spreadRadius: 2)
            ],
          );
        } else {
          color = AppColors.stageDotLocked;
          decoration = BoxDecoration(color: color, shape: BoxShape.circle);
        }
        return Padding(
          padding: EdgeInsets.only(left: s.level == 0 ? 0 : 5.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8.r,
            height: 8.r,
            decoration: decoration,
          ),
        );
      }).toList(),
    );
  }
}

class _GrowthProgress extends StatelessWidget {
  final GrowthResult growth;
  final GrowthStage? nextStage;
  const _GrowthProgress({required this.growth, this.nextStage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nextStage != null
                  ? 'Growing toward ${nextStage!.emoji} ${nextStage!.name}'
                  : 'Fully grown — a forest of nations',
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMid),
            ),
            Text(
              '${(growth.progress * 100).round()}%',
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            value: growth.progress.clamp(0.04, 1.0),
            minHeight: 8.h,
            backgroundColor: AppColors.progressTrack,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
          ),
        ),
        if (nextStage != null) ...[
          SizedBox(height: 5.h),
          Text(
            '${growth.toNext} more points of shared study, prayer, and mentoring to grow again.',
            style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

class _TapZoneButton extends StatefulWidget {
  final TapZone zone;
  final bool isActive;
  final VoidCallback onTap;
  const _TapZoneButton(
      {required this.zone, required this.isActive, required this.onTap});

  @override
  State<_TapZoneButton> createState() => _TapZoneButtonState();
}

class _TapZoneButtonState extends State<_TapZoneButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ring;
  late Animation<double> _ringScale;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringScale = Tween(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ring, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_TapZoneButton old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ring.repeat();
    } else if (!widget.isActive) {
      _ring.stop();
      _ring.reset();
    }
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cx = w * (widget.zone.cx / 100);
        final cy = h * (widget.zone.cy / 100);
        final r = w * (widget.zone.r / 100);

        return Stack(
          children: [
            Positioned(
              left: cx - r,
              top: cy - r,
              width: r * 2,
              height: r * 2,
              child: Semantics(
                button: true,
                label: '${widget.zone.label}: ${widget.zone.theme}',
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isActive
                          ? const Color(0xFFFFE9B0).withOpacity(0.35)
                          : Colors.transparent,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing ring
                        if (widget.isActive)
                          ScaleTransition(
                            scale: _ringScale,
                            child: FadeTransition(
                              opacity: Tween(begin: 0.8, end: 0.0)
                                  .animate(_ring),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFE9B0),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Dot marker
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 10.r,
                          height: 10.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isActive
                                ? const Color(0xFFFFE9B0)
                                : Colors.white.withOpacity(0.70),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ZoneDetail extends StatelessWidget {
  final TapZone zone;
  final GrowthMetrics? metrics;
  final VoidCallback onBack;

  const _ZoneDetail({
    super.key,
    required this.zone,
    this.metrics,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              zone.label,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen),
            ),
            SizedBox(width: 6.w),
            Text(
              zone.theme,
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.amber),
            ),
          ],
        ),
        if (metrics != null) ...[
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${metrics!.metricValue(zone.metric)}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                zone.unit,
                style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
        SizedBox(height: 8.h),
        Text(
          zone.description,
          style: TextStyle(
              fontSize: 13.sp, height: 1.6, color: AppColors.textDark),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: onBack,
          child: Text(
            'Back to reflection',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryGreen,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _StageDescription extends StatelessWidget {
  final GrowthStage stage;
  const _StageDescription({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stage.description,
          style: TextStyle(
              fontSize: 13.sp, height: 1.6, color: AppColors.textDark),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.only(left: 10.w),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.amber, width: 2),
            ),
          ),
          child: Text(
            stage.verse,
            style: TextStyle(
                fontSize: 13.sp,
                fontStyle: FontStyle.italic,
                height: 1.6,
                color: AppColors.darkAmber),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Tap the roots, trunk, branches, canopy, or fruit to see the activity feeding your growth.',
          style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _GlowOverlay extends StatelessWidget {
  final AnimationController breathe;
  const _GlowOverlay({required this.breathe});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breathe,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.5),
            radius: 0.8,
            colors: [
              const Color(0xFFFFF4D6).withOpacity(0.50 * breathe.value),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTreeImage extends StatelessWidget {
  final String emoji;
  final Color color;
  const _PlaceholderTreeImage({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: 36.sp)),
      ),
    );
  }
}
