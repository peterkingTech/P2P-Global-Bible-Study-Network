import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../models/disciple.dart';
import '../../../models/growth_stage.dart';
import '../../world_map/widgets/world_map_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GlobalForestPage — mirrors /forest/page.tsx
//
// The full-screen map view of the discipleship network.
// Filter controls let the user drill into season, growth stage, activity
// status, and relationship type. The WorldMapWidget renders beneath.
// ─────────────────────────────────────────────────────────────────────────────

// ── Data constants (mirrors the TypeScript const arrays) ──────────────────────

const _kSeasons = <String>['spring', 'summer', 'autumn', 'winter'];

const _kSeasonLabels = <String, String>{
  'spring': 'Spring',
  'summer': 'Summer',
  'autumn': 'Autumn',
  'winter': 'Winter',
};

const _kActivity = <({String id, String label})>[
  (id: 'all', label: 'All'),
  (id: 'praying', label: 'Praying now'),
  (id: 'recent', label: 'Recently active'),
];

const _kRelationship = <({String id, String label})>[
  (id: 'all', label: 'Everyone'),
  (id: 'disciples', label: 'My disciples'),
  (id: 'mentors', label: 'Just me'),
];

// ── Colors for this page (dark forest palette, distinct from Living Tree) ─────

abstract final class _FC {
  static const bg = Color(0xFF06110D);
  static const text = Color(0xFFE8EFE9);
  static const accent = Color(0xFF1D9E75);
  static const heading = Color(0xFFF4EFE4);
  static const statValue = Color(0xFFF7C948);

  static const lightGreen = Color(0xFF9FE1CB);
  static Color get labelMuted => lightGreen.withOpacity(0.50);
  static Color get bodyMuted => lightGreen.withOpacity(0.70);
  static Color get statLabelMuted => lightGreen.withOpacity(0.60);

  static Color get panelBg => Colors.white.withOpacity(0.02);
  static Color get panelBorder => Colors.white.withOpacity(0.10);

  static Color get chipActiveBg => accent;
  static const chipActiveFg = Color(0xFF06110D);
  static Color get chipInactiveBg => Colors.white.withOpacity(0.05);
  static Color get chipInactiveFg => lightGreen.withOpacity(0.80);
}

// ─────────────────────────────────────────────────────────────────────────────

class GlobalForestPage extends StatefulWidget {
  const GlobalForestPage({super.key});

  @override
  State<GlobalForestPage> createState() => _GlobalForestPageState();
}

class _GlobalForestPageState extends State<GlobalForestPage> {
  String _season = 'summer';
  final Set<int> _stages = {};
  String _activity = 'all';
  String _relationship = 'all';

  void _toggleStage(int level) {
    setState(() {
      if (_stages.contains(level)) {
        _stages.remove(level);
      } else {
        _stages.add(level);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SeasonThemes.of(_season);
    final filters = MapFilters(
      stages: Set.from(_stages),
      activity: _activity,
      relationship: _relationship,
    );

    return Container(
      color: _FC.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ─────────────────────────────────────────────────────
              _Header(caption: theme.caption),

              SizedBox(height: 28.h),

              // ── Global stats ────────────────────────────────────────────────
              _StatsGrid(),

              SizedBox(height: 24.h),

              // ── Filter controls ─────────────────────────────────────────────
              _FilterPanel(
                season: _season,
                stages: _stages,
                activity: _activity,
                relationship: _relationship,
                onSeasonChanged: (s) => setState(() => _season = s),
                onStageToggled: _toggleStage,
                onActivityChanged: (a) => setState(() => _activity = a),
                onRelationshipChanged: (r) => setState(() => _relationship = r),
              ),

              SizedBox(height: 18.h),

              // ── World map ───────────────────────────────────────────────────
              WorldMapWidget(
                season: _season,
                filters: filters,
              ),

              SizedBox(height: 14.h),

              // ── Legend ──────────────────────────────────────────────────────
              _Legend(theme: theme),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String caption;
  const _Header({required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'The Global Forest',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.8,
            color: _FC.accent,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          'One Church, Many Nations',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w600,
            color: _FC.heading,
            height: 1.2,
          ),
        ),
        SizedBox(height: 10.h),
        // Season caption — animated crossfade when season changes
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            caption,
            key: ValueKey(caption),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.6,
              color: _FC.bodyMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stats grid ─────────────────────────────────────────────────────────────────

/// 2-column on narrow screens, 4-column on wide. Mirrors `sm:grid-cols-4`.
class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // kGlobalStats defined below — mirrors GLOBAL_STATS from forest-data.ts
    const stats = kGlobalStats;
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > 480;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: wide ? 4 : 2,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: wide ? 1.45 : 1.8,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => _StatCard(stat: stats[i]),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final ({String label, String value}) stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: _FC.statValue,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            stat.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5.sp,
              letterSpacing: 0.8,
              color: _FC.statLabelMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Filter panel ──────────────────────────────────────────────────────────────

class _FilterPanel extends StatelessWidget {
  final String season;
  final Set<int> stages;
  final String activity;
  final String relationship;
  final ValueChanged<String> onSeasonChanged;
  final ValueChanged<int> onStageToggled;
  final ValueChanged<String> onActivityChanged;
  final ValueChanged<String> onRelationshipChanged;

  const _FilterPanel({
    required this.season,
    required this.stages,
    required this.activity,
    required this.relationship,
    required this.onSeasonChanged,
    required this.onStageToggled,
    required this.onActivityChanged,
    required this.onRelationshipChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _FC.panelBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _FC.panelBorder),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;
        if (wide) {
          return Wrap(
            spacing: 20.w,
            runSpacing: 14.h,
            alignment: WrapAlignment.spaceBetween,
            children: _filterGroups(context),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _filterGroups(context)
              .expand((w) => [w, SizedBox(height: 14.h)])
              .toList()
            ..removeLast(),
        );
      }),
    );
  }

  List<Widget> _filterGroups(BuildContext context) {
    return [
      // Season
      _FilterGroup(
        label: 'Season',
        children: _kSeasons.map((s) {
          return _Chip(
            label: _kSeasonLabels[s]!,
            active: season == s,
            onTap: () => onSeasonChanged(s),
          );
        }).toList(),
      ),

      // Growth stage
      _FilterGroup(
        label: 'Growth stage',
        children: kGrowthStages.map((s) {
          return _Chip(
            label: s.name,
            active: stages.contains(s.level),
            onTap: () => onStageToggled(s.level),
          );
        }).toList(),
      ),

      // Activity
      _FilterGroup(
        label: 'Activity',
        children: _kActivity.map((a) {
          return _Chip(
            label: a.label,
            active: activity == a.id,
            onTap: () => onActivityChanged(a.id),
          );
        }).toList(),
      ),

      // Relationship
      _FilterGroup(
        label: 'Relationship',
        children: _kRelationship.map((r) {
          return _Chip(
            label: r.label,
            active: relationship == r.id,
            onTap: () => onRelationshipChanged(r.id),
          );
        }).toList(),
      ),
    ];
  }
}

// ── Filter group ──────────────────────────────────────────────────────────────

class _FilterGroup extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _FilterGroup({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
            color: _FC.labelMuted,
          ),
        ),
        SizedBox(height: 7.h),
        Wrap(
          spacing: 5.w,
          runSpacing: 5.h,
          children: children,
        ),
      ],
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: active,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: active ? _FC.chipActiveBg : _FC.chipInactiveBg,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: active ? _FC.chipActiveFg : _FC.chipInactiveFg,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  final SeasonTheme theme;
  const _Legend({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20.w,
      runSpacing: 8.h,
      children: [
        _LegendItem(
          indicator: _CircleDot(color: theme.node),
          label: 'Disciple tree',
        ),
        _LegendItem(
          indicator: _HRule(color: theme.accent, dashed: false),
          label: 'Paul–Timothy covenant',
        ),
        _LegendItem(
          indicator: _HRule(color: theme.node, dashed: true),
          label: 'Mentoring link',
        ),
        _LegendItem(
          indicator: _PrayingDot(accentColor: theme.accent),
          label: 'Praying now',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Widget indicator;
  final String label;
  const _LegendItem({required this.indicator, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: _FC.bodyMuted),
        ),
      ],
    );
  }
}

// Solid colour dot
class _CircleDot extends StatelessWidget {
  final Color color;
  const _CircleDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9.r,
      height: 9.r,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// Solid or dashed horizontal rule
class _HRule extends StatelessWidget {
  final Color color;
  final bool dashed;
  const _HRule({required this.color, required this.dashed});

  @override
  Widget build(BuildContext context) {
    if (!dashed) {
      return Container(
        width: 22.w,
        height: 2.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999.r),
        ),
      );
    }
    // Dashed rule via CustomPainter
    return SizedBox(
      width: 22.w,
      height: 2.h,
      child: CustomPaint(
        painter: _DashPainter(color: color),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;
    const dashW = 3.0;
    const gapW = 3.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset((x + dashW).clamp(0.0, size.width).toDouble(), y), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

// Ring dot for "Praying now"
class _PrayingDot extends StatelessWidget {
  final Color accentColor;
  const _PrayingDot({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9.r,
      height: 9.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accentColor, width: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Global stats data (mirrors GLOBAL_STATS from forest-data.ts)
// ─────────────────────────────────────────────────────────────────────────────

const kGlobalStats = <({String label, String value})>[
  (value: '24,817', label: 'fruit borne globally'),
  (value: '156', label: 'cities reached'),
  (value: '847', label: 'praying right now'),
  (value: '5,204', label: 'covenant bonds'),
];
