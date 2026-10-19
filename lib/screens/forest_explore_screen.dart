import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../services/ambient_soundscape.dart';
import '../theme/forest_theme.dart';
import '../widgets/discovery_marker.dart';
import '../widgets/firefly_field.dart';
import '../widgets/forest_bottom_nav.dart';
import '../widgets/glass_panel.dart';
import '../widgets/looping_forest_video.dart';
import '../widgets/motion.dart';
import 'forest_tabs.dart';
import 'tree_detail_screen.dart';

/// Screen Two — Explore the Living Forest.
///
/// The aerial film fills the screen; glowing discovery pins float over it,
/// joined by a softly flowing trail. A glass carousel below is kept in sync
/// with the pins: tap a pin to bring its story forward, or swipe the stories
/// to fly between pins.
class ForestExploreScreen extends StatefulWidget {
  const ForestExploreScreen({super.key});

  /// Pushes the explore screen with the "Enter the Forest" transition: the
  /// home scene dissolves as the aerial view settles in from a gentle zoom.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const ForestExploreScreen(),
        transitionDuration: const Duration(milliseconds: 950),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.6, curve: Curves.easeOut),
          );
          final scale = Tween<double>(begin: 1.12, end: 1).animate(
            CurvedAnimation(parent: animation, curve: ForestTheme.emphasized),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      ),
    );
  }

  @override
  State<ForestExploreScreen> createState() => _ForestExploreScreenState();
}

class _ForestExploreScreenState extends State<ForestExploreScreen> {
  static const _discoveries = ForestDiscovery.all;
  static const _ms = Duration(milliseconds: 1);

  final PageController _pages = PageController(viewportFraction: 0.84);
  int? _selected;

  @override
  void initState() {
    super.initState();
    AmbientSoundscape.instance.playTrack(AmbientSoundscape.birdsAsset);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _selectMarker(int index) {
    setState(() => _selected = index);
    if (_pages.hasClients && _pages.page?.round() != index) {
      _pages.animateToPage(
        index,
        duration: ForestTheme.slow,
        curve: ForestTheme.emphasized,
      );
    }
  }

  IconData _iconFor(ForestDiscovery d) => switch (d.id) {
    'ancient_oak' => Icons.park_rounded,
    'hidden_stream' => Icons.water_drop_rounded,
    _ => Icons.flutter_dash_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LoopingForestVideo(
            asset: 'assets/videos/forest_aerial.mp4',
            scrim: ForestTheme.videoScrim,
            kenBurns: true,
          ),
          const FireflyField(count: 18, color: ForestTheme.springGlow),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------- header
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const LiveDot(),
                              const SizedBox(width: 6),
                              Text(
                                '${_discoveries.length} DISCOVERIES NEARBY',
                                style: ForestTheme.label(
                                  size: 10.5,
                                  color: ForestTheme.mistIvory,
                                ),
                              ),
                            ],
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
                        delay: _ms * 250,
                        child: Text(
                          'EXPLORE',
                          style: ForestTheme.label(size: 12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      WordReveal(
                        delay: _ms * 350,
                        style: ForestTheme.display(size: 46),
                        accentStyle: ForestTheme.display(
                          size: 46,
                          italic: true,
                        ),
                        lines: const [
                          [
                            (text: 'Whispering', accent: false),
                            (text: 'Woods', accent: true),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Reveal(
                        delay: _ms * 650,
                        child: Text(
                          'A forest full of stories.',
                          style: ForestTheme.ivory(size: 15, opacity: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // -------------------------------------------- marker field
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Reveal(
                            delay: _ms * 700,
                            blur: 0,
                            offset: 0,
                            duration: const Duration(milliseconds: 1600),
                            child: _Trail(
                              points: [
                                for (final d in _discoveries) d.markerPosition,
                              ],
                            ),
                          ),
                        ),
                        for (var i = 0; i < _discoveries.length; i++)
                          Positioned(
                            // Centre the pin's 76px ripple box on the point.
                            left:
                                _discoveries[i].markerPosition.dx *
                                    box.maxWidth -
                                DiscoveryMarker.pinExtent / 2,
                            top:
                                _discoveries[i].markerPosition.dy *
                                    box.maxHeight -
                                DiscoveryMarker.pinExtent / 2,
                            width: DiscoveryMarker.pinExtent,
                            height: DiscoveryMarker.pinExtent,
                            // The name chip hangs below the pin.
                            child: OverflowBox(
                              maxWidth: 220,
                              maxHeight: 160,
                              alignment: Alignment.topCenter,
                              child: Reveal(
                                delay: _ms * (800 + 160 * i),
                                child: DiscoveryMarker(
                                  label: _discoveries[i].title,
                                  selected: _selected == i,
                                  icon: _iconFor(_discoveries[i]),
                                  onTap: () => _selectMarker(i),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ----------------------------------------------- carousel
                Reveal(
                  delay: _ms * 1000,
                  child: SizedBox(
                    height: 152,
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: _discoveries.length,
                      onPageChanged: (i) => setState(() => _selected = i),
                      itemBuilder: (context, i) => AnimatedBuilder(
                        animation: _pages,
                        builder: (context, child) {
                          final page =
                              _pages.positions.length == 1 &&
                                  _pages.position.haveDimensions
                              ? _pages.page!
                              : (_selected ?? 0).toDouble();
                          final distance = (page - i).abs().clamp(0.0, 1.0);
                          return Transform.scale(
                            scale: 1 - 0.07 * distance,
                            child: Opacity(
                              opacity: 1 - 0.35 * distance,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _DiscoveryCard(
                            discovery: _discoveries[i],
                            highlighted: _selected == i,
                            onOpen: () =>
                                TreeDetailScreen.push(context, _discoveries[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ---------------------------------------------------- nav
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ForestBottomNav(
                    currentIndex: ForestBottomNav.exploreIndex,
                    onSelect: (i) => openForestTab(
                      context,
                      i,
                      current: ForestBottomNav.exploreIndex,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass story card in the discovery carousel.
class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.discovery,
    required this.highlighted,
    required this.onOpen,
  });

  final ForestDiscovery discovery;
  final bool highlighted;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${discovery.title}. ${discovery.shortDescription}',
      child: PressableScale(
        onTap: onOpen,
        child: GlassPanel(
          radius: 28,
          tint: 0.4,
          highlight: highlighted ? ForestTheme.morningGold : null,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Static gradient medallion — deliberately not a second video
              // controller (performance rule: one video at a time).
              Container(
                width: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2F5A43), ForestTheme.mossGreen],
                  ),
                  border: Border.all(
                    color: ForestTheme.mistIvory.withValues(alpha: 0.15),
                  ),
                ),
                alignment: Alignment.center,
                child: ExcludeSemantics(
                  child: Text(
                    discovery.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      discovery.kicker,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ForestTheme.label(size: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      discovery.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ForestTheme.display(size: 25, height: 1.05),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      discovery.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ForestTheme.ivory(
                        size: 12.5,
                        opacity: 0.75,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: ForestTheme.medium,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: highlighted ? ForestTheme.goldGradient : null,
                  border: Border.all(
                    color: ForestTheme.morningGold.withValues(alpha: 0.6),
                  ),
                ),
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 18,
                  color: highlighted
                      ? ForestTheme.deepForest
                      : ForestTheme.morningGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dotted trail that flows between the discoveries, like footsteps.
class _Trail extends StatefulWidget {
  const _Trail({required this.points});

  /// Relative (0..1) positions, matching the markers' [Alignment]s.
  final List<Offset> points;

  @override
  State<_Trail> createState() => _TrailState();
}

class _TrailState extends State<_Trail> with SingleTickerProviderStateMixin {
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _TrailPainter(widget.points, _flow)),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  _TrailPainter(this.points, this.flow) : super(repaint: flow);

  final List<Offset> points;
  final Animation<double> flow;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    Offset at(Offset p) => Offset(p.dx * size.width, p.dy * size.height);

    final path = Path()..moveTo(at(points.first).dx, at(points.first).dy);
    for (var i = 1; i < points.length; i++) {
      final a = at(points[i - 1]);
      final b = at(points[i]);
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final control = mid + Offset(-(b.dy - a.dy), b.dx - a.dx) * 0.25;
      path.quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);
    }

    final dot = Paint()..color = ForestTheme.mistIvory.withValues(alpha: 0.75);
    const gap = 12.0;
    final shift = flow.value * gap;
    final pins = [for (final p in points) at(p)];
    for (final PathMetric metric in path.computeMetrics()) {
      for (var d = shift; d < metric.length; d += gap) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;
        // Leave a clearing around each pin so the dots end at its ripple.
        final clearance = pins
            .map((p) => (p - tangent.position).distance)
            .reduce((a, b) => a < b ? a : b);
        if (clearance < 28) continue;
        canvas.drawCircle(tangent.position, 1.6, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => old.points != points;
}
