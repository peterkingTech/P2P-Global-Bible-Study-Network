import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../models/disciple.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorldMapWidget — mirrors world-map.tsx
//
// Renders disciples as glowing nodes on a simplified world map.
// The full topojson + d3-geo projection from the React source requires a
// native mapping library (e.g. flutter_map or mapbox_gl) to reproduce exactly.
// This widget uses a Natural Earth–approximated equirectangular projection
// painted with CustomPainter so the coordinates, zoom controls, connection
// lines, and interaction model all match the original faithfully.
// ─────────────────────────────────────────────────────────────────────────────

// ── Filters (mirrors MapFilters interface) ────────────────────────────────────

class MapFilters {
  final Set<int> stages;
  final String activity; // 'all' | 'praying' | 'recent'
  final String relationship; // 'all' | 'disciples' | 'mentors'

  const MapFilters({
    this.stages = const {},
    this.activity = 'all',
    this.relationship = 'all',
  });

  MapFilters copyWith({
    Set<int>? stages,
    String? activity,
    String? relationship,
  }) =>
      MapFilters(
        stages: stages ?? this.stages,
        activity: activity ?? this.activity,
        relationship: relationship ?? this.relationship,
      );
}

// ── Natural Earth equirectangular projection helpers ──────────────────────────

/// Projects [longitude, latitude] to (x%, y%) in a 0-100 coordinate space
/// using the Natural Earth simplified projection (close enough for node placement).
Offset _project(double lon, double lat) {
  // Simple equirectangular — good enough for node positions
  // lon: -180..180 → 0..100%
  // lat: 90..-90 → 0..100%
  final x = (lon + 180) / 360 * 100;
  final y = (90 - lat) / 180 * 100;
  return Offset(x, y);
}

// ── Zoom levels (mirrors ZOOM_K / ZOOM_LABEL) ─────────────────────────────────

const _kZoomK = [1.0, 2.2, 3.6, 6.0, 10.0];
const _kZoomLabel = ['Global', 'Continent', 'Country', 'City', 'Individual'];

// ── Widget ────────────────────────────────────────────────────────────────────

class WorldMapWidget extends StatefulWidget {
  final String season; // 'spring'|'summer'|'autumn'|'winter'
  final MapFilters filters;
  final ValueChanged<Disciple?>? onHover;

  const WorldMapWidget({
    super.key,
    this.season = 'summer',
    this.filters = const MapFilters(),
    this.onHover,
  });

  @override
  State<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends State<WorldMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathe;
  late Animation<double> _glow;

  String? _selectedId;
  String? _hoveredId;
  int _level = 0;

  // Pre-project all disciples once
  late final List<_DisciplePoint> _points;
  late final Map<String, _DisciplePoint> _pointById;
  late final List<MentorEdge> _edges;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _glow = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _breathe, curve: Curves.easeInOut),
    );

    // Disciples are loaded from Supabase at runtime — map starts empty.
    _points = [];
    _pointById = {};
    _edges = [];
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  // ── Filter visibility ──────────────────────────────────────────────────────

  Map<String, bool> get _isVisible {
    final map = <String, bool>{};
    for (final p in _points) {
      var ok = true;
      final f = widget.filters;
      if (f.stages.isNotEmpty && !f.stages.contains(p.d.level)) ok = false;
      if (f.activity == 'praying' && !p.d.praying) ok = false;
      if (f.activity == 'recent' && !isRecentlyActive(p.d.lastActive)) {
        ok = false;
      }
      if (f.relationship == 'disciples' && p.d.mentorId != 'you') ok = false;
      if (f.relationship == 'mentors' && p.d.id != 'you') ok = false;
      map[p.d.id] = ok;
    }
    return map;
  }

  // ── Zoom transform ─────────────────────────────────────────────────────────

  double get _k => _kZoomK[_level];

  // Focal point as % — when something is selected, center on it
  double get _fx {
    if (_selectedId != null) return _pointById[_selectedId]?.px ?? 50;
    return 50;
  }

  double get _fy {
    if (_selectedId != null) return _pointById[_selectedId]?.py ?? 50;
    return 50;
  }

  /// Maps a point at (px%, py%) in the map coordinate space to a screen
  /// percentage using the current zoom level and focal point.
  Offset _screenPct(double px, double py) {
    return Offset(50 + (px - _fx) * _k, 50 + (py - _fy) * _k);
  }

  void _selectDisciple(String id) {
    setState(() {
      if (_selectedId == id) {
        _selectedId = null;
        _level = 0;
      } else {
        _selectedId = id;
        if (_level < 2) _level = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SeasonThemes.of(widget.season);
    final isVisible = _isVisible;
    final activeId = _hoveredId ?? _selectedId;
    final hovered = activeId != null ? _pointById[activeId] : null;

    return Semantics(
      label: 'World map of disciples',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          color: theme.ocean,
          child: AspectRatio(
            aspectRatio: 980 / 500,
            child: AnimatedBuilder(
              animation: _glow,
              builder: (context, _) {
                return Stack(
                  children: [
                    // ── Map + connection lines (CustomPainter) ─────────────
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MapPainter(
                          theme: theme,
                          points: _points,
                          edges: _edges,
                          isVisible: isVisible,
                          activeId: activeId,
                          k: _k,
                          fx: _fx,
                          fy: _fy,
                          glowOpacity: _glow.value,
                        ),
                      ),
                    ),

                    // ── Disciple node buttons ──────────────────────────────
                    Positioned.fill(
                      child: LayoutBuilder(builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        return Stack(
                          children: _points.map((p) {
                            final sc = _screenPct(p.px, p.py);
                            if (sc.dx < -5 ||
                                sc.dx > 105 ||
                                sc.dy < -5 ||
                                sc.dy > 105) {
                              return const SizedBox.shrink();
                            }
                            final visible = isVisible[p.d.id] ?? true;
                            final isViewer = p.d.id == 'you';
                            final emphasized = activeId == p.d.id;
                            final size = (8.0 + p.d.level * 2.5).r;

                            return Positioned(
                              left: w * sc.dx / 100 - size / 2,
                              top: h * sc.dy / 100 - size / 2,
                              child: GestureDetector(
                                onTap: () => _selectDisciple(p.d.id),
                                onLongPressStart: (_) {
                                  setState(() => _hoveredId = p.d.id);
                                  widget.onHover?.call(p.d);
                                },
                                onLongPressEnd: (_) {
                                  setState(() => _hoveredId = null);
                                  widget.onHover?.call(null);
                                },
                                child: Opacity(
                                  opacity: visible ? 1.0 : 0.18,
                                  child: _NodeView(
                                    size: size,
                                    theme: theme,
                                    isViewer: isViewer,
                                    emphasized: emphasized,
                                    praying: p.d.praying,
                                    glowValue: _glow.value,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),

                    // ── Tooltip on hover/selection ─────────────────────────
                    if (hovered != null)
                      _TooltipOverlay(
                        disciple: hovered.d,
                        screenPct: _screenPct(hovered.px, hovered.py),
                      ),

                    // ── Zoom controls ──────────────────────────────────────
                    Positioned(
                      bottom: 10.h,
                      left: 10.w,
                      child: _ZoomControls(
                        level: _level,
                        maxLevel: _kZoomK.length - 1,
                        label: _kZoomLabel[_level],
                        onZoomOut: () {
                          if (_level > 0) setState(() => _level--);
                        },
                        onZoomIn: () {
                          if (_level < _kZoomK.length - 1) {
                            setState(() => _level++);
                          }
                        },
                      ),
                    ),

                    // ── Reset button ───────────────────────────────────────
                    if (_selectedId != null)
                      Positioned(
                        bottom: 10.h,
                        right: 10.w,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedId = null;
                            _level = 0;
                          }),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.40),
                              borderRadius: BorderRadius.circular(999.r),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.10)),
                            ),
                            child: Text(
                              'Reset view',
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.node),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Node view ─────────────────────────────────────────────────────────────────

class _NodeView extends StatelessWidget {
  final double size;
  final SeasonTheme theme;
  final bool isViewer;
  final bool emphasized;
  final bool praying;
  final double glowValue;

  const _NodeView({
    required this.size,
    required this.theme,
    required this.isViewer,
    required this.emphasized,
    required this.praying,
    required this.glowValue,
  });

  @override
  Widget build(BuildContext context) {
    final nodeColor = isViewer ? const Color(0xFFF4EFE4) : theme.node;
    return SizedBox(
      width: size * 2.4,
      height: size * 2.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Breathing glow
          Container(
            width: size * 2.4,
            height: size * 2.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.node.withOpacity((emphasized ? 0.7 : 0.4) * glowValue),
            ),
          ),
          // Praying halo
          if (praying)
            Container(
              width: size * 1.7,
              height: size * 1.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.accent.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
            ),
          // Core node
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: nodeColor,
              border: isViewer
                  ? Border.all(color: theme.accent, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: theme.node.withOpacity(0.8),
                  blurRadius: size / 1.5,
                ),
                BoxShadow(
                  color: theme.node.withOpacity(0.6),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map painter — land + connection lines ─────────────────────────────────────

class _MapPainter extends CustomPainter {
  final SeasonTheme theme;
  final List<_DisciplePoint> points;
  final List<MentorEdge> edges;
  final Map<String, bool> isVisible;
  final String? activeId;
  final double k;
  final double fx;
  final double fy;
  final double glowOpacity;

  const _MapPainter({
    required this.theme,
    required this.points,
    required this.edges,
    required this.isVisible,
    required this.activeId,
    required this.k,
    required this.fx,
    required this.fy,
    required this.glowOpacity,
  });

  Offset _toScreen(double px, double py, Size size) {
    final sx = 50 + (px - fx) * k;
    final sy = 50 + (py - fy) * k;
    return Offset(size.width * sx / 100, size.height * sy / 100);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Ocean background is handled by the Container color.
    // Draw radial glow overlay
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.1),
        radius: 0.9,
        colors: [
          theme.land.withOpacity(0.35),
          theme.ocean.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // Simplified land masses as filled paths in map percentage coordinates.
    // These are rough continent outlines sufficient for positioning context.
    _drawLand(canvas, size);

    // Connection lines
    _drawConnections(canvas, size);
  }

  void _drawLand(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.land
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = theme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4 / k;

    // Land masses as approximate polygons in (lon,lat) space
    for (final shape in _kLandShapes) {
      final path = Path();
      for (var i = 0; i < shape.length; i++) {
        final pt = _project(shape[i][0], shape[i][1]);
        final sc = _toScreen(pt.dx, pt.dy, size);
        if (i == 0) path.moveTo(sc.dx, sc.dy);
        else path.lineTo(sc.dx, sc.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    }
  }

  void _drawConnections(Canvas canvas, Size size) {
    final pointById = {for (final p in points) p.d.id: p};

    for (final edge in edges) {
      final a = pointById[edge.from.id];
      final b = pointById[edge.to.id];
      if (a == null || b == null) continue;

      final asc = _toScreen(a.px, a.py, size);
      final bsc = _toScreen(b.px, b.py, size);

      final visible =
          (isVisible[edge.from.id] ?? false) && (isVisible[edge.to.id] ?? false);
      final emphasized = activeId == edge.from.id || activeId == edge.to.id;

      double opacity;
      if (!visible) {
        opacity = 0.05;
      } else if (emphasized) {
        opacity = 0.95;
      } else if (edge.covenant) {
        opacity = 0.60;
      } else {
        opacity = 0.32;
      }

      final strokeColor = edge.covenant ? theme.accent : theme.node;
      final paint = Paint()
        ..color = strokeColor.withOpacity(opacity)
        ..strokeWidth = (edge.covenant ? 1.4 : 0.9) / k
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Quadratic bezier arc (mirrors Q${mx},${my})
      final mx = (asc.dx + bsc.dx) / 2;
      final my = (asc.dy + bsc.dy) / 2 -
          (asc.dx - bsc.dx).abs() * 0.12 -
          12 * min(size.width, size.height) / 500;

      final path = Path()
        ..moveTo(asc.dx, asc.dy)
        ..quadraticBezierTo(mx, my, bsc.dx, bsc.dy);

      if (!edge.covenant) {
        // Dashed stroke approximation: draw segments
        final dashLen = 3.0 / k;
        _drawDashedPath(canvas, path, paint, dashLen, dashLen);
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, double on, double off) {
    // Measure and walk the path
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var dist = 0.0;
      var draw = true;
      while (dist < metric.length) {
        final seg = draw ? on : off;
        if (draw) {
          final start = dist.clamp(0.0, metric.length);
          final end = (dist + seg).clamp(0.0, metric.length);
          canvas.drawPath(metric.extractPath(start, end), paint);
        }
        dist += seg;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.k != k ||
      old.fx != fx ||
      old.fy != fy ||
      old.activeId != activeId ||
      old.glowOpacity != glowOpacity ||
      old.theme != theme ||
      old.isVisible != isVisible ||
      !_mapsEqual(old.isVisible, isVisible);

  static bool _mapsEqual(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

// ── Tooltip overlay ───────────────────────────────────────────────────────────

class _TooltipOverlay extends StatelessWidget {
  final Disciple disciple;
  final Offset screenPct; // 0-100 percentage

  const _TooltipOverlay(
      {required this.disciple, required this.screenPct});

  @override
  Widget build(BuildContext context) {
    final above = screenPct.dy > 55;
    final clampedX = screenPct.dx.clamp(12.0, 88.0);

    return Positioned.fill(
      child: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final left = w * clampedX / 100;
        final top = h * screenPct.dy / 100;
        return Stack(
          children: [
            Positioned(
              left: left - 96.w, // 192/2 ≈ center
              top: above ? top - 110.h : top + 14.h,
              width: 192.w,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1512).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        disciple.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF4EFE4),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${disciple.city}, ${disciple.country}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.lightGreen.withOpacity(0.80),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.accentGreen.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              disciple.stage.replaceAll('-', ' '),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.lightGreen,
                              ),
                            ),
                          ),
                          Text(
                            disciple.lastActive,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFFC9B98F),
                            ),
                          ),
                        ],
                      ),
                      if (disciple.praying) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Praying now',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFFF7C948),
                          ),
                        ),
                      ],
                    ],
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

// ── Zoom controls ─────────────────────────────────────────────────────────────

class _ZoomControls extends StatelessWidget {
  final int level;
  final int maxLevel;
  final String label;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;

  const _ZoomControls({
    required this.level,
    required this.maxLevel,
    required this.label,
    required this.onZoomOut,
    required this.onZoomIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.40),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomBtn(
            icon: '−',
            enabled: level > 0,
            onTap: onZoomOut,
          ),
          SizedBox(
            width: 72.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.lightGreen,
              ),
            ),
          ),
          _ZoomBtn(
            icon: '+',
            enabled: level < maxLevel,
            onTap: onZoomIn,
          ),
        ],
      ),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final String icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ZoomBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = icon == '+' ? 'Zoom in' : 'Zoom out';
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.30,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 24.r,
            height: 24.r,
            alignment: Alignment.center,
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.lightGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data types ────────────────────────────────────────────────────────────────

class _DisciplePoint {
  final Disciple d;
  final double px; // 0-100%
  final double py; // 0-100%
  const _DisciplePoint({required this.d, required this.px, required this.py});
}

// ─────────────────────────────────────────────────────────────────────────────
// Simplified continent outlines in [lon, lat] coordinates.
// These are coarse shapes sufficient to provide geographic context while
// remaining self-contained (no external tile/topo files needed).
// For production quality, replace with flutter_map + vector tiles.
// ─────────────────────────────────────────────────────────────────────────────
const _kLandShapes = <List<List<double>>>[
  // North America (simplified)
  [[-168, 71], [-141, 60], [-130, 55], [-125, 49], [-117, 32], [-100, 25],
   [-87, 16], [-77, 8], [-75, 10], [-82, 9], [-85, 11], [-90, 15],
   [-88, 16], [-83, 10], [-77, 8], [-79, 9], [-82, 24], [-81, 25],
   [-80, 26], [-81, 31], [-78, 35], [-75, 38], [-70, 42], [-66, 45],
   [-60, 47], [-53, 47], [-53, 54], [-57, 52], [-64, 49], [-66, 49],
   [-69, 49], [-76, 45], [-79, 44], [-83, 42], [-83, 46], [-88, 47],
   [-90, 47], [-95, 49], [-100, 49], [-110, 49], [-117, 49], [-124, 49],
   [-130, 54], [-135, 57], [-138, 60], [-141, 61], [-142, 60], [-150, 60],
   [-153, 58], [-155, 59], [-160, 60], [-167, 65], [-168, 71]],

  // Greenland (simplified)
  [[-70, 83], [-55, 83], [-42, 83], [-24, 72], [-20, 66], [-24, 61],
   [-36, 58], [-43, 60], [-47, 62], [-55, 66], [-60, 70], [-65, 75],
   [-70, 80], [-70, 83]],

  // South America (simplified)
  [[-75, 11], [-60, 8], [-50, 5], [-35, -5], [-35, -10], [-38, -13],
   [-39, -18], [-40, -20], [-43, -23], [-48, -27], [-49, -29], [-52, -33],
   [-53, -34], [-58, -38], [-62, -38], [-65, -42], [-65, -47], [-67, -54],
   [-68, -56], [-66, -56], [-65, -55], [-64, -53], [-63, -50], [-63, -48],
   [-65, -46], [-67, -44], [-69, -42], [-71, -36], [-71, -30], [-70, -22],
   [-70, -16], [-73, -12], [-75, -8], [-78, -2], [-80, 1], [-79, 5],
   [-77, 8], [-75, 11]],

  // Europe (simplified)
  [[2, 51], [3, 53], [5, 55], [8, 57], [11, 58], [14, 57], [15, 58],
   [18, 58], [21, 60], [24, 61], [28, 62], [27, 65], [24, 68], [22, 70],
   [26, 71], [28, 71], [30, 68], [32, 65], [29, 60], [30, 58], [27, 58],
   [24, 60], [22, 63], [20, 66], [18, 68], [15, 70], [12, 70], [10, 63],
   [5, 62], [0, 60], [-2, 58], [-5, 56], [-6, 54], [-4, 52], [-2, 52],
   [0, 51], [2, 51]],

  // Scandinavia (simplified)
  [[5, 58], [5, 60], [5, 62], [6, 64], [8, 64], [9, 66], [12, 70],
   [15, 70], [18, 68], [20, 66], [22, 63], [24, 60], [27, 58],
   [30, 58], [27, 58], [22, 57], [18, 58], [15, 58], [14, 57],
   [11, 58], [8, 57], [5, 58]],

  // Africa (simplified)
  [[-5, 36], [0, 35], [10, 37], [15, 38], [25, 37], [32, 32], [34, 30],
   [36, 26], [37, 21], [40, 12], [42, 12], [44, 12], [49, 12], [52, 12],
   [50, 10], [45, 8], [42, 5], [40, 0], [40, -5], [38, -11], [36, -18],
   [35, -22], [33, -26], [30, -30], [28, -33], [25, -34], [20, -35],
   [18, -34], [17, -30], [14, -25], [12, -18], [12, -12], [12, -5],
   [10, 0], [5, 5], [2, 8], [-2, 8], [-5, 10], [-8, 12], [-8, 15],
   [-5, 20], [-6, 25], [-6, 30], [-3, 34], [-2, 35], [-5, 36]],

  // Asia (simplified, very rough)
  [[32, 37], [36, 40], [40, 42], [44, 42], [50, 42], [55, 42],
   [60, 45], [65, 45], [70, 48], [75, 52], [80, 55], [85, 55],
   [90, 52], [95, 55], [100, 55], [105, 55], [110, 52], [115, 48],
   [120, 45], [125, 42], [130, 42], [135, 45], [140, 45], [143, 48],
   [141, 52], [140, 55], [135, 58], [130, 60], [125, 60], [120, 60],
   [118, 65], [115, 68], [110, 70], [100, 72], [90, 74], [75, 73],
   [65, 72], [55, 70], [45, 68], [38, 65], [32, 62], [30, 57],
   [29, 52], [32, 47], [35, 43], [38, 38], [36, 35], [32, 37]],

  // Indian Subcontinent (simplified)
  [[65, 23], [70, 22], [75, 20], [80, 18], [84, 20], [88, 22],
   [90, 25], [92, 27], [95, 28], [97, 26], [95, 22], [92, 18],
   [88, 14], [80, 10], [77, 8], [73, 10], [70, 15], [65, 20], [65, 23]],

  // Australia (simplified)
  [[114, -22], [118, -20], [124, -18], [130, -16], [136, -14],
   [140, -15], [144, -18], [148, -20], [152, -24], [153, -28],
   [152, -32], [150, -38], [148, -38], [147, -40], [144, -38],
   [140, -38], [135, -35], [130, -33], [125, -33], [120, -34],
   [116, -33], [112, -30], [110, -25], [112, -22], [114, -22]],

  // Japan (simplified)
  [[130, 31], [131, 33], [133, 35], [135, 36], [138, 38], [140, 40],
   [141, 43], [143, 44], [145, 44], [145, 42], [143, 40], [141, 38],
   [140, 37], [138, 35], [136, 33], [134, 32], [131, 31], [130, 31]],

  // UK / British Isles (simplified)
  [[-5, 50], [-4, 51], [-3, 52], [-2, 53], [-1, 54], [0, 55],
   [1, 53], [0, 52], [-1, 51], [-3, 51], [-5, 51], [-5, 50]],
];
