import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../theme/forest_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/discovery_marker.dart';
import '../widgets/forest_bottom_nav.dart';
import '../widgets/glass_panel.dart';
import '../widgets/motion.dart';
import 'forest_tabs.dart';
import 'tree_detail_screen.dart';

/// The Living Map — a stylised topographic chart of the Whispering Woods.
///
/// Contour lines slowly breathe, a radar sweep circles from "you are here"
/// and each discovery pin opens its story. Real terrain data is a future
/// step; the chart is drawn procedurally so no map engine is required.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _ms = Duration(milliseconds: 1);
  static const _you = Offset(0.52, 0.86);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GlassIconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Reveal(
                      delay: _ms * 300,
                      offset: -10,
                      child: GlassPanel(
                        radius: 999,
                        tint: 0.2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        child: Text(
                          'TERRAIN · PREVIEW',
                          style: ForestTheme.label(
                            size: 10.5,
                            color: ForestTheme.mistIvory,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Reveal(
                      delay: _ms * 200,
                      child: Text('MAP', style: ForestTheme.label(size: 12)),
                    ),
                    const SizedBox(height: 6),
                    WordReveal(
                      delay: _ms * 300,
                      style: ForestTheme.display(size: 46),
                      accentStyle: ForestTheme.display(size: 46, italic: true),
                      lines: const [
                        [
                          (text: 'The', accent: false),
                          (text: 'living', accent: true),
                          (text: 'map', accent: false),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Reveal(
                      delay: _ms * 600,
                      child: Text(
                        'Ridges, streams and clearings of the Whispering '
                        'Woods.',
                        style: ForestTheme.ivory(size: 15, opacity: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------- chart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Reveal(
                    delay: _ms * 500,
                    offset: 40,
                    child: GlassPanel(
                      radius: 32,
                      tint: 0.35,
                      child: LayoutBuilder(
                        builder: (context, box) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Positioned.fill(child: _LivingTopography()),
                            for (final d in ForestDiscovery.all)
                              Positioned(
                                left:
                                    d.markerPosition.dx * box.maxWidth -
                                    DiscoveryMarker.pinExtent / 2,
                                top:
                                    d.markerPosition.dy * box.maxHeight * 0.9 -
                                    DiscoveryMarker.pinExtent / 2,
                                width: DiscoveryMarker.pinExtent,
                                height: DiscoveryMarker.pinExtent,
                                child: DiscoveryMarker(
                                  label: d.title,
                                  selected: false,
                                  icon: switch (d.id) {
                                    'ancient_oak' => Icons.park_rounded,
                                    'hidden_stream' => Icons.water_drop_rounded,
                                    _ => Icons.flutter_dash_rounded,
                                  },
                                  onTap: () =>
                                      TreeDetailScreen.push(context, d),
                                ),
                              ),
                            Positioned(
                              left: _you.dx * box.maxWidth - 9,
                              top: _you.dy * box.maxHeight - 9,
                              child: const _YouAreHere(),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 14,
                              child: Text(
                                'YOU ARE HERE',
                                style: ForestTheme.label(
                                  size: 9.5,
                                  color: ForestTheme.springGlow,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 12,
                              child: Text(
                                '1 km',
                                style: ForestTheme.ivory(
                                  size: 11,
                                  weight: FontWeight.w700,
                                  opacity: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ForestBottomNav(
                  currentIndex: ForestBottomNav.mapIndex,
                  onSelect: (i) => openForestTab(
                    context,
                    i,
                    current: ForestBottomNav.mapIndex,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Procedural contour lines around three summits plus a radar sweep.
class _LivingTopography extends StatefulWidget {
  const _LivingTopography();

  @override
  State<_LivingTopography> createState() => _LivingTopographyState();
}

class _LivingTopographyState extends State<_LivingTopography>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _TopoPainter(
            _clock,
            still: MediaQuery.disableAnimationsOf(context),
          ),
        ),
      ),
    );
  }
}

class _TopoPainter extends CustomPainter {
  _TopoPainter(this.clock, {required this.still}) : super(repaint: clock);

  final Animation<double> clock;
  final bool still;

  static const _peaks = [
    (c: Offset(0.28, 0.28), r: 0.42, rings: 9, phase: 0.0),
    (c: Offset(0.78, 0.48), r: 0.36, rings: 8, phase: 1.7),
    (c: Offset(0.38, 0.74), r: 0.28, rings: 6, phase: 3.1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = still ? 0.0 : clock.value * 2 * math.pi;
    final unit = size.shortestSide;
    canvas.clipRect(Offset.zero & size);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final peak in _peaks) {
      final center = Offset(peak.c.dx * size.width, peak.c.dy * size.height);
      for (var k = 1; k <= peak.rings; k++) {
        final level = k / peak.rings;
        final path = Path();
        const steps = 96;
        for (var i = 0; i <= steps; i++) {
          final a = i / steps * 2 * math.pi;
          final wobble =
              1 +
              0.16 * math.sin(3 * a + peak.phase + t * 0.5) +
              0.07 * math.sin(5 * a - peak.phase + level * 4);
          final r = level * peak.r * unit * wobble;
          final p = center + Offset(math.cos(a), math.sin(a) * 0.85) * r;
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        // Summits glow gold; lower slopes fade into fern.
        line
          ..color = Color.lerp(
            ForestTheme.morningGold,
            ForestTheme.fern,
            level,
          )!.withValues(alpha: 0.55 - 0.35 * level)
          ..strokeWidth = k % 4 == 0 ? 1.6 : 0.9;
        canvas.drawPath(path, line);
      }
    }

    // A winding stream from the top-right summit down toward the bottom.
    final stream = Path()
      ..moveTo(size.width * 0.72, 0)
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.3,
        size.width * 0.95,
        size.height * 0.55,
        size.width * 0.62,
        size.height,
      );
    canvas.drawPath(
      stream,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF7FC8D8).withValues(alpha: 0.45),
    );

    // Radar sweep from "you are here".
    if (!still) {
      final origin = Offset(
        MapScreen._you.dx * size.width,
        MapScreen._you.dy * size.height,
      );
      final radius = size.longestSide;
      final sweep = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0,
          endAngle: math.pi / 3,
          transform: GradientRotation(t),
          colors: [
            ForestTheme.springGlow.withValues(alpha: 0),
            ForestTheme.springGlow.withValues(alpha: 0.18),
          ],
        ).createShader(Rect.fromCircle(center: origin, radius: radius));
      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: radius),
        t,
        math.pi / 3,
        true,
        sweep,
      );
    }
  }

  @override
  bool shouldRepaint(_TopoPainter old) => old.still != still;
}

class _YouAreHere extends StatelessWidget {
  const _YouAreHere();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ForestTheme.springGlow,
        border: Border.all(color: ForestTheme.deepForest, width: 3),
        boxShadow: [
          BoxShadow(
            color: ForestTheme.springGlow.withValues(alpha: 0.8),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
