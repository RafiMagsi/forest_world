import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../services/ambient_soundscape.dart';
import '../theme/forest_theme.dart';
import '../widgets/forest_bottom_nav.dart';
import '../widgets/forest_pulse_card.dart';
import '../widgets/forest_video_overlay.dart';
import '../widgets/looping_forest_video.dart';
import 'forest_explore_screen.dart';
import 'map_screen.dart';
import 'my_forest_screen.dart';

/// Screen One — The Living Forest Home.
///
/// A cinematic, looping morning-mist video fills the screen while the
/// interface sits quietly on top of it.
class ForestHomeScreen extends StatefulWidget {
  const ForestHomeScreen({super.key});

  @override
  State<ForestHomeScreen> createState() => _ForestHomeScreenState();
}

class _ForestHomeScreenState extends State<ForestHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void initState() {
    super.initState();
    // Greet the visitor with birdsong.
    AmbientSoundscape.instance.playTrack(AmbientSoundscape.birdsAsset);
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Animation<double> _phase(double begin, double end) => CurvedAnimation(
        parent: _intro,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  Widget _staggered({
    required double from,
    required double to,
    required Widget child,
  }) {
    final anim = _phase(from, to);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.10),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  void _openTab(int index) {
    switch (index) {
      case ForestBottomNav.exploreIndex:
        ForestExploreScreen.push(context);
      case ForestBottomNav.mapIndex:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MapScreen()),
        );
      case ForestBottomNav.myForestIndex:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MyForestScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          LoopingForestVideo(
            asset: 'assets/videos/forest_home.mp4',
            scrim: ForestTheme.videoScrim,
          ),
          ForestVideoOverlay(gradient: ForestTheme.videoScrim),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // ------------------------------------------------ top bar
                  _staggered(
                    from: 0,
                    to: 0.35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FORESTOS',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                            color: ForestTheme.mistIvory,
                          ),
                        ),
                        const _SoundToggle(),
                      ],
                    ),
                  ),

                  // --------------------------------------------- content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _staggered(
                              from: 0.15,
                              to: 0.6,
                              child: Text(
                                'Sunlight · Mist · Leaves',
                                style: TextStyle(
                                  fontSize: 13,
                                  letterSpacing: 2.4,
                                  fontWeight: FontWeight.w500,
                                  color: ForestTheme.morningGold
                                      .withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _staggered(
                              from: 0.25,
                              to: 0.7,
                              child: const Text(
                                'A quieter\nworld awaits.',
                                style: TextStyle(
                                  fontSize: 44,
                                  height: 1.05,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1,
                                  color: ForestTheme.mistIvory,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x88000000),
                                      blurRadius: 18,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _staggered(
                              from: 0.35,
                              to: 0.8,
                              child: Text(
                                'Discover the living world around you.',
                                style: ForestTheme.ivory(
                                  size: 16,
                                  opacity: 0.82,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _staggered(
                              from: 0.45,
                              to: 0.9,
                              child: _EnterForestButton(
                                onPressed: () =>
                                    ForestExploreScreen.push(context),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _staggered(
                              from: 0.55,
                              to: 1,
                              child: Text(
                                '${ForestPulse.speciesDiscovered} species'
                                ' · ${ForestPulse.treesExplored} discoveries',
                                style: ForestTheme.ivory(
                                  size: 13,
                                  opacity: 0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _staggered(
                              from: 0.65,
                              to: 1,
                              child: const ForestPulseCard(),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --------------------------------------------------- nav
                  _staggered(
                    from: 0.75,
                    to: 1,
                    child: ForestBottomNav(
                      currentIndex: -1,
                      onSelect: _openTab,
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

class _EnterForestButton extends StatelessWidget {
  const _EnterForestButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ForestTheme.fern, Color(0xFF7C9462)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: ForestTheme.fern.withValues(alpha: 0.45),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter the Forest',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: ForestTheme.deepForest,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 20,
                  color: ForestTheme.deepForest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
          label: enabled ? 'Mute forest sounds' : 'Play forest sounds',
          child: IconButton(
            onPressed: () => AmbientSoundscape.instance.toggle(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                key: ValueKey(enabled),
                color: enabled
                    ? ForestTheme.mistIvory
                    : ForestTheme.mistIvory.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
