import 'package:flutter/material.dart';

import '../theme/forest_theme.dart';
import '../widgets/forest_bottom_nav.dart';
import 'forest_explore_screen.dart';
import 'my_forest_screen.dart';

/// A quiet teaser for the living map. The demo keeps its scope to the three
/// primary screens, so this tab stays honest about what is coming instead of
/// faking a geographic engine.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  void _openTab(int index) {
    switch (index) {
      case ForestBottomNav.exploreIndex:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const ForestExploreScreen()),
        );
      case ForestBottomNav.mapIndex:
        break;
      case ForestBottomNav.myForestIndex:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const MyForestScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForestTheme.deepForest,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 24, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: ForestTheme.mistIvory,
                    ),
                  ),
                  const Text(
                    'Map',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: ForestTheme.mistIvory,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: AnimatedBuilder(
                          animation: _ring,
                          builder: (context, _) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                for (var i = 0; i < 3; i++)
                                  _pulse(i),
                                const Icon(
                                  Icons.terrain_rounded,
                                  size: 46,
                                  color: ForestTheme.fern,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'The living map is taking shape',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: ForestTheme.mistIvory,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Soon you will wander the Whispering Woods by '
                        'terrain — ridges, streams and clearings drawn from '
                        'the forest itself.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: ForestTheme.mistIvory.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ForestBottomNav(currentIndex: 1, onSelect: _openTab),
          ],
        ),
      ),
    );
  }

  Widget _pulse(int index) {
    final t = (_ring.value + index / 3) % 1;
    return Container(
      width: 60 + t * 90,
      height: 60 + t * 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ForestTheme.fern.withValues(alpha: (1 - t) * 0.5),
          width: 1.5,
        ),
      ),
    );
  }
}
