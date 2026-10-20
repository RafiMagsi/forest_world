import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/forest_discovery.dart';
import '../services/ambient_soundscape.dart';
import '../theme/forest_theme.dart';
import '../widgets/firefly_field.dart';
import '../widgets/forest_bottom_nav.dart';
import '../widgets/forest_pulse_card.dart';
import '../widgets/glass_panel.dart';
import '../widgets/looping_forest_video.dart';
import '../widgets/motion.dart';
import 'forest_explore_screen.dart';
import 'forest_tabs.dart';

const _heroVideo = 'assets/videos/483301.mp4';

/// Screen One — The Living Forest Home.
///
/// The film plays exactly as shot, opening slightly soft and racking into
/// focus while drifting motes of light rise through the frame; the title then rises word by word and the
/// interface settles in beneath it like mist.
class ForestHomeScreen extends StatefulWidget {
  const ForestHomeScreen({super.key});

  @override
  State<ForestHomeScreen> createState() => _ForestHomeScreenState();
}

class _ForestHomeScreenState extends State<ForestHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Greet the visitor with birdsong.
    AmbientSoundscape.instance.playTrack(AmbientSoundscape.birdsAsset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm the next scenes so every transition lands on a real frame.
    LoopingForestVideo.precachePosters(context, [
      _heroVideo,
      'assets/videos/forest_aerial.mp4',
      for (final d in ForestDiscovery.all) d.videoAsset,
    ]);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Quiet night in the woods';
    if (hour < 12) return 'Good morning, wanderer';
    if (hour < 17) return 'Good afternoon, wanderer';
    if (hour < 21) return 'Golden hour awaits';
    return 'Quiet night in the woods';
  }

  static const _ms = Duration(milliseconds: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Shown exactly as filmed: real-time speed, no camera drift.
          const LoopingForestVideo(
            asset: _heroVideo,
            scrim: ForestTheme.videoScrim,
            focusPull: true,
          ),
          const _SunGlow(),
          const FireflyField(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ------------------------------------------------ top bar
                  Reveal(
                    delay: _ms * 200,
                    offset: -12,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(child: _BrandMark()),
                          SizedBox(width: 12),
                          _SoundToggle(),
                        ],
                      ),
                    ),
                  ),

                  // --------------------------------------------- content
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Reveal(
                                delay: _ms * 500,
                                child: const _LocationChip(),
                              ),
                              const SizedBox(height: 18),
                              Reveal(
                                delay: _ms * 650,
                                child: Text(
                                  _greeting.toUpperCase(),
                                  style: ForestTheme.label(size: 12),
                                ),
                              ),
                              const SizedBox(height: 10),
                              WordReveal(
                                delay: _ms * 750,
                                style: ForestTheme.display(size: 62, height: 1),
                                accentStyle: ForestTheme.display(
                                  size: 62,
                                  height: 1,
                                  italic: true,
                                ),
                                lines: const [
                                  [
                                    (text: 'A', accent: false),
                                    (text: 'quieter', accent: false),
                                  ],
                                  [
                                    (text: 'world', accent: true),
                                    (text: 'awaits.', accent: false),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 14),
                              Reveal(
                                delay: _ms * 1150,
                                child: Text(
                                  'Step inside a living forest — sunlight, '
                                  'mist and birdsong all around you.',
                                  style: ForestTheme.ivory(
                                    size: 16,
                                    opacity: 0.85,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              Reveal(
                                delay: _ms * 1300,
                                child: ShimmerButton(
                                  label: 'Enter the Forest',
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    ForestExploreScreen.push(context);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Reveal(
                                delay: _ms * 1450,
                                child: const ForestPulseCard(),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --------------------------------------------------- nav
                  Reveal(
                    delay: _ms * 1600,
                    child: ForestBottomNav(
                      currentIndex: -1,
                      onSelect: (i) => openForestTab(context, i, current: -1),
                    ),
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

/// Leaf medallion + serif wordmark.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ForestOS',
      header: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ForestTheme.ctaGradient,
              boxShadow: [
                BoxShadow(
                  color: ForestTheme.fern.withValues(alpha: 0.5),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.eco_rounded,
              size: 20,
              color: ForestTheme.deepForest,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text.rich(
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              TextSpan(
                children: [
                  const TextSpan(text: 'Forest'),
                  TextSpan(
                    text: 'OS',
                    style: ForestTheme.display(
                      size: 26,
                      italic: true,
                      color: ForestTheme.morningGold,
                    ),
                  ),
                ],
              ),
              style: ForestTheme.display(size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass pill locating the scene: place, weather and a live signal.
class _LocationChip extends StatelessWidget {
  const _LocationChip();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 999,
      tint: 0.2,
      padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LiveDot(),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Whispering Woods',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ForestTheme.ivory(size: 13, weight: FontWeight.w700),
            ),
          ),
          Container(
            width: 3,
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ForestTheme.mistIvory.withValues(alpha: 0.6),
            ),
          ),
          Icon(
            Icons.cloud_outlined,
            size: 15,
            color: ForestTheme.mistIvory.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 5),
          Text(
            '18° Misty',
            style: ForestTheme.ivory(
              size: 13,
              weight: FontWeight.w600,
              opacity: 0.85,
            ),
          ),
        ],
      ),
    );
  }
}

/// A warm bloom of low sun in the upper corner that slowly breathes.
class _SunGlow extends StatefulWidget {
  const _SunGlow();

  @override
  State<_SunGlow> createState() => _SunGlowState();
}

class _SunGlowState extends State<_SunGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _breath,
          builder: (context, _) {
            final b = Curves.easeInOut.transform(_breath.value);
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.95, -0.85),
                  radius: 0.85 + 0.1 * b,
                  colors: [
                    ForestTheme.morningGold.withValues(alpha: 0.30 + 0.1 * b),
                    ForestTheme.morningGold.withValues(alpha: 0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Glass speaker control; shows a dancing equalizer while birdsong plays.
class _SoundToggle extends StatelessWidget {
  const _SoundToggle();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AmbientSoundscape.instance,
      builder: (context, _) {
        final enabled = AmbientSoundscape.instance.enabled;
        return Semantics(
          button: true,
          toggled: enabled,
          label: enabled ? 'Mute forest sounds' : 'Play forest sounds',
          excludeSemantics: true,
          child: PressableScale(
            scale: 0.9,
            onTap: AmbientSoundscape.instance.toggle,
            child: GlassPanel(
              radius: 999,
              tint: 0.2,
              child: SizedBox(
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: ForestTheme.quick,
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: enabled
                            ? const _Equalizer(key: ValueKey('on'))
                            : Icon(
                                Icons.volume_off_rounded,
                                key: const ValueKey('off'),
                                size: 18,
                                color: ForestTheme.mistIvory.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        enabled ? 'Birdsong' : 'Muted',
                        style: ForestTheme.ivory(
                          size: 12,
                          weight: FontWeight.w700,
                          opacity: enabled ? 1 : 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Equalizer extends StatefulWidget {
  const _Equalizer({super.key});

  @override
  State<_Equalizer> createState() => _EqualizerState();
}

class _EqualizerState extends State<_Equalizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: 18,
      height: 16,
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) {
          final t = _clock.value * 2 * math.pi;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: 3,
                  height: still
                      ? 8
                      : 4 + 12 * (0.5 + 0.5 * math.sin(t * (1 + i * 0.35) + i)),
                  decoration: BoxDecoration(
                    color: ForestTheme.springGlow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
