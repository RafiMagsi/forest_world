import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/forest_discovery.dart';
import '../services/ambient_soundscape.dart';
import '../theme/forest_theme.dart';
import '../widgets/firefly_field.dart';
import '../widgets/glass_panel.dart';
import '../widgets/looping_forest_video.dart';
import '../widgets/motion.dart';

/// Screen Three — Discover a Living Tree.
///
/// A cinematic close-up fills the top of the screen and drifts with parallax
/// as the story sheet is scrolled over it. Ambient sound follows the scene
/// (water for the stream, birdsong elsewhere).
class TreeDetailScreen extends StatefulWidget {
  const TreeDetailScreen({super.key, required this.discovery});

  final ForestDiscovery discovery;

  /// The film rises into view as the previous scene dissolves.
  static Future<void> push(BuildContext context, ForestDiscovery discovery) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => TreeDetailScreen(discovery: discovery),
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: ForestTheme.emphasized,
          );
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0, 0.6, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<TreeDetailScreen> createState() => _TreeDetailScreenState();
}

class _TreeDetailScreenState extends State<TreeDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _ms = Duration(milliseconds: 1);

  final ScrollController _scroll = ScrollController();
  late final AnimationController _burst;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // The stream detail swaps the ambience to running water.
    final track = widget.discovery.id == 'hidden_stream'
        ? AmbientSoundscape.streamAsset
        : AmbientSoundscape.birdsAsset;
    AmbientSoundscape.instance.playTrack(track);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _burst.dispose();
    super.dispose();
  }

  void _toggleSave(ForestDiscovery discovery) {
    final nowSaved = SavedForestStore.instance.toggle(discovery);
    if (nowSaved) {
      HapticFeedback.heavyImpact();
      _burst.forward(from: 0);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: ForestTheme.morningGold,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text('${discovery.title} saved to My Forest')),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    } else {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final discovery = widget.discovery;
    final size = MediaQuery.sizeOf(context);
    final heroHeight = (size.height * 0.56).clamp(300.0, 560.0);

    return Scaffold(
      body: Stack(
        children: [
          // --------------------------------------------- parallax film
          AnimatedBuilder(
            animation: _scroll,
            builder: (context, child) {
              final offset = _scroll.hasClients ? _scroll.offset : 0.0;
              // Drift up at 40% of scroll speed; stretch on overscroll.
              final stretch = offset < 0 ? 1 + (-offset / heroHeight) : 1.0;
              return Positioned(
                top: offset > 0 ? -offset * 0.4 : 0,
                left: 0,
                right: 0,
                height: heroHeight,
                child: Transform.scale(
                  scale: stretch,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                LoopingForestVideo(
                  asset: discovery.videoAsset,
                  scrim: ForestTheme.softVideoScrim,
                  kenBurns: true,
                  focusPull: true,
                ),
                const FireflyField(count: 16),
              ],
            ),
          ),

          // ------------------------------------------------ story sheet
          CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: heroHeight - 36)),
              SliverToBoxAdapter(
                child: _StorySheet(
                  discovery: discovery,
                  burst: _burst,
                  onSave: () => _toggleSave(discovery),
                ),
              ),
            ],
          ),

          // ------------------------------------------------ top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GlassIconButton(
                    tooltip: 'Back to the forest',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  ListenableBuilder(
                    listenable: SavedForestStore.instance,
                    builder: (context, _) {
                      final saved = SavedForestStore.instance.isSaved(
                        discovery.id,
                      );
                      return GlassIconButton(
                        tooltip: saved ? 'Remove from My Forest' : 'Save',
                        onPressed: () => _toggleSave(discovery),
                        icon: AnimatedSwitcher(
                          duration: ForestTheme.quick,
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(saved),
                            color: saved
                                ? ForestTheme.morningGold
                                : ForestTheme.mistIvory,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorySheet extends StatelessWidget {
  const _StorySheet({
    required this.discovery,
    required this.burst,
    required this.onSave,
  });

  final ForestDiscovery discovery;
  final Animation<double> burst;
  final VoidCallback onSave;

  static const _ms = _TreeDetailScreenState._ms;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ForestTheme.canopy.withValues(alpha: 0.92),
            ForestTheme.deepForest,
          ],
          stops: const [0, 0.35],
        ),
        border: Border(
          top: BorderSide(color: ForestTheme.mistIvory.withValues(alpha: 0.14)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 14, 24, 28 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grabber
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ForestTheme.mistIvory.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Reveal(
              delay: _ms * 300,
              child: Row(
                children: [
                  Text(discovery.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(discovery.kicker, style: ForestTheme.label(size: 12)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            WordReveal(
              delay: _ms * 400,
              style: ForestTheme.display(size: 50),
              accentStyle: ForestTheme.display(size: 50, italic: true),
              lines: [_titleWords(discovery.title)],
            ),
            const SizedBox(height: 14),
            Reveal(
              delay: _ms * 650,
              child: Text(
                discovery.description,
                style: ForestTheme.ivory(size: 16, opacity: 0.82, height: 1.6),
              ),
            ),
            const SizedBox(height: 24),
            Reveal(
              delay: _ms * 800,
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.spa_rounded,
                      label: 'SPECIES',
                      value: discovery.species,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.favorite_rounded,
                      label: 'STATUS',
                      value: discovery.status,
                      live: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Reveal(
              delay: _ms * 950,
              child: _DidYouKnow(text: discovery.didYouKnow),
            ),
            const SizedBox(height: 26),
            Reveal(
              delay: _ms * 1100,
              child: _SaveButton(
                discovery: discovery,
                burst: burst,
                onPressed: onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gild the last word of the title ("The Ancient *Oak*").
  static List<HeadlineWord> _titleWords(String title) {
    final words = title.split(' ');
    return [
      for (var i = 0; i < words.length; i++)
        (text: words[i], accent: i == words.length - 1),
    ];
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.live = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: ForestTheme.mistIvory.withValues(alpha: 0.05),
        border: Border.all(color: ForestTheme.mistIvory.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ForestTheme.fern.withValues(alpha: 0.16),
                ),
                child: Icon(icon, size: 16, color: ForestTheme.fern),
              ),
              const Spacer(),
              if (live) const LiveDot(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: ForestTheme.label(size: 10, color: ForestTheme.fern),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ForestTheme.ivory(size: 18, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DidYouKnow extends StatelessWidget {
  const _DidYouKnow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // Gradient hairline border: gold fading into moss.
    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ForestTheme.morningGold.withValues(alpha: 0.8),
            ForestTheme.mossGreen.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF233A27), ForestTheme.canopy],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: ForestTheme.goldGradient.createShader,
                  child: const Icon(Icons.auto_awesome_rounded, size: 18),
                ),
                const SizedBox(width: 8),
                Text('DID YOU KNOW?', style: ForestTheme.label(size: 11)),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: ForestTheme.display(size: 22, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.discovery,
    required this.burst,
    required this.onPressed,
  });

  final ForestDiscovery discovery;
  final Animation<double> burst;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SavedForestStore.instance,
      builder: (context, _) {
        final saved = SavedForestStore.instance.isSaved(discovery.id);
        final label = saved ? 'Saved to My Forest' : 'Save Discovery';
        return Semantics(
          button: true,
          toggled: saved,
          label: label,
          excludeSemantics: true,
          child: PressableScale(
            haptic: false,
            onTap: onPressed,
            child: AnimatedContainer(
              duration: ForestTheme.medium,
              curve: Curves.easeOutCubic,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: saved ? null : ForestTheme.ctaGradient,
                color: saved ? ForestTheme.canopy : null,
                border: Border.all(
                  color: ForestTheme.morningGold.withValues(
                    alpha: saved ? 0.9 : 0,
                  ),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (saved ? ForestTheme.morningGold : ForestTheme.fern)
                        .withValues(alpha: 0.35),
                    blurRadius: 26,
                    spreadRadius: -4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CustomPaint(
                      painter: _BurstPainter(burst),
                      child: AnimatedBuilder(
                        animation: burst,
                        builder: (context, child) {
                          // Thump: overshoot, then settle.
                          final t = burst.value;
                          final scale = t == 0
                              ? 1.0
                              : 1 + 0.45 * math.sin(math.pi * t) * (1 - t);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Icon(
                          saved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: saved
                              ? ForestTheme.morningGold
                              : ForestTheme.deepForest,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: ForestTheme.quick,
                    child: Text(
                      label,
                      key: ValueKey(saved),
                      style: TextStyle(
                        fontFamily: ForestTheme.textFamily,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: saved
                            ? ForestTheme.mistIvory
                            : ForestTheme.deepForest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Golden sparks and a ring that burst outward from the heart on save.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    if (v == 0 || v == 1) return;
    final center = size.center(Offset.zero);
    final ease = Curves.easeOutCubic.transform(v);
    final fade = (1 - v).clamp(0.0, 1.0);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * fade
      ..color = ForestTheme.morningGold.withValues(alpha: fade * 0.8);
    canvas.drawCircle(center, 10 + 26 * ease, ring);

    final spark = Paint();
    const count = 10;
    for (var i = 0; i < count; i++) {
      final angle = i / count * 2 * math.pi + 0.3;
      final distance = 14 + 30 * ease;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      spark.color =
          (i.isEven ? ForestTheme.morningGold : ForestTheme.springGlow)
              .withValues(alpha: fade);
      canvas.drawCircle(pos, 2.6 * fade + 0.4, spark);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => false;
}
