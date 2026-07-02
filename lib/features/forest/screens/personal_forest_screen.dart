import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/forest_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../widgets/forest_dashboard.dart';
import '../widgets/tree_node.dart';
import '../widgets/connection_line.dart';

/// Personal Forest — the user's tree at centre, disciples in first ring,
/// disciples' disciples in second ring, with animated connection lines.
class PersonalForestScreen extends ConsumerWidget {
  const PersonalForestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodesAsync = ref.watch(forestNodesProvider);
    final statsAsync = ref.watch(globalStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF06110D),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Forest',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF4EFE4),
                        ),
                      ),
                      Text(
                        'Your discipleship network',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9FE1CB).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  AppButton(
                    label: 'Global map',
                    onPressed: () => context.go(Routes.globalHeatmap),
                    compact: true,
                    variant: AppButtonVariant.outlined,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ── Stats overlay ─────────────────────────────────────────────
            statsAsync.when(
              data: (stats) => ForestDashboard(stats: stats),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            SizedBox(height: 16.h),

            // ── Network visualisation ─────────────────────────────────────
            Expanded(
              child: nodesAsync.when(
                loading: () => const LoadingSkeleton(),
                error: (e, _) => Center(
                  child: Text('Could not load forest: $e',
                      style: const TextStyle(color: Colors.white70)),
                ),
                data: (nodes) => _PersonalNetworkView(nodes: nodes),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalNetworkView extends StatelessWidget {
  final List<dynamic> nodes;
  const _PersonalNetworkView({required this.nodes});

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌱', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 12.h),
            Text(
              'Your forest starts here',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF4EFE4)),
            ),
            SizedBox(height: 6.h),
            Text(
              'Disciple someone and your network grows.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF9FE1CB).withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    // Radial layout: centre = "you", ring 1 = direct disciples,
    // ring 2 = their disciples. Rendered with a CustomPaint overlay.
    return LayoutBuilder(builder: (context, constraints) {
      final centre = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
      final ring1Radius = constraints.maxWidth * 0.28;
      final ring2Radius = constraints.maxWidth * 0.46;

      // Simple partition: first node = you, rest = disciples
      final you = nodes.isNotEmpty ? nodes.first : null;
      final ring1 = nodes.length > 1 ? nodes.sublist(1, nodes.length.clamp(0, 5)) : [];
      final ring2 = nodes.length > 5 ? nodes.sublist(5) : [];

      return Stack(
        children: [
          // Connection lines layer
          Positioned.fill(
            child: CustomPaint(
              painter: _NetworkLinesPainter(
                centre: centre,
                ring1Count: ring1.length,
                ring1Radius: ring1Radius,
                ring2Count: ring2.length,
                ring2Radius: ring2Radius,
              ),
            ),
          ),
          // Your node
          if (you != null)
            Positioned(
              left: centre.dx - 28.r,
              top: centre.dy - 28.r,
              child: const TreeNode(level: 3, isViewer: true),
            ),
          // Ring 1
          ...ring1.asMap().entries.map((e) {
            final angle = (2 * 3.14159 * e.key) / ring1.length - 3.14159 / 2;
            final x = centre.dx + ring1Radius * _cos(angle) - 20.r;
            final y = centre.dy + ring1Radius * _sin(angle) - 20.r;
            return Positioned(
              left: x,
              top: y,
              child: TreeNode(level: 1),
            );
          }),
          // Ring 2
          ...ring2.take(8).toList().asMap().entries.map((e) {
            final angle = (2 * 3.14159 * e.key) / ring2.length.clamp(1, 8) - 3.14159 / 2;
            final x = centre.dx + ring2Radius * _cos(angle) - 14.r;
            final y = centre.dy + ring2Radius * _sin(angle) - 14.r;
            return Positioned(
              left: x,
              top: y,
              child: TreeNode(level: 0, small: true),
            );
          }),
        ],
      );
    });
  }

  static double _cos(double a) => _approxCos(a);
  static double _sin(double a) => _approxSin(a);

  static double _approxCos(double a) {
    final x = a % (2 * 3.14159);
    return 1 - x * x / 2 + x * x * x * x / 24;
  }

  static double _approxSin(double a) {
    final x = a % (2 * 3.14159);
    return x - x * x * x / 6 + x * x * x * x * x / 120;
  }
}

class _NetworkLinesPainter extends CustomPainter {
  final Offset centre;
  final int ring1Count;
  final double ring1Radius;
  final int ring2Count;
  final double ring2Radius;

  const _NetworkLinesPainter({
    required this.centre,
    required this.ring1Count,
    required this.ring1Radius,
    required this.ring2Count,
    required this.ring2Radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D9E75).withOpacity(0.3)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < ring1Count; i++) {
      final angle = (2 * 3.14159 * i) / ring1Count - 3.14159 / 2;
      final x = centre.dx + ring1Radius * _cos(angle);
      final y = centre.dy + ring1Radius * _sin(angle);
      canvas.drawLine(centre, Offset(x, y), paint);
    }
  }

  static double _cos(double a) => 1 - a * a / 2 + a * a * a * a / 24;
  static double _sin(double a) => a - a * a * a / 6 + a * a * a * a * a / 120;

  @override
  bool shouldRepaint(_NetworkLinesPainter old) =>
      old.ring1Count != ring1Count || old.centre != centre;
}
