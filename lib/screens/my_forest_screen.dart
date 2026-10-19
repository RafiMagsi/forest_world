import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../theme/forest_theme.dart';
import '../widgets/forest_bottom_nav.dart';
import 'forest_explore_screen.dart';
import 'map_screen.dart';
import 'tree_detail_screen.dart';

/// The user's saved discoveries — everything they tapped "Save Discovery" on.
class MyForestScreen extends StatelessWidget {
  const MyForestScreen({super.key});

  void _openTab(BuildContext context, int index) {
    switch (index) {
      case ForestBottomNav.exploreIndex:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const ForestExploreScreen()),
        );
      case ForestBottomNav.mapIndex:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const MapScreen()),
        );
      case ForestBottomNav.myForestIndex:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForestTheme.deepForest,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'My Forest',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: ForestTheme.mistIvory,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Kept close to your heart',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: ForestTheme.mistIvory,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListenableBuilder(
                listenable: SavedForestStore.instance,
                builder: (context, _) {
                  final saved = SavedForestStore.instance.savedDiscoveries;
                  if (saved.isEmpty) return const _EmptyForest();
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                    itemCount: saved.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final discovery = saved[index];
                      return Material(
                        color: ForestTheme.deepForest,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => TreeDetailScreen.push(
                            context,
                            discovery,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: ForestTheme.fern
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF254736),
                                        ForestTheme.mossGreen,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    discovery.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        discovery.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: ForestTheme.mistIvory,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        discovery.species,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: ForestTheme.mistIvory
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.favorite_rounded,
                                  size: 20,
                                  color: ForestTheme.morningGold,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ForestBottomNav(
              currentIndex: 2,
              onSelect: (i) => _openTab(context, i),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyForest extends StatelessWidget {
  const _EmptyForest();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.park_outlined,
              size: 64,
              color: ForestTheme.mossGreen,
            ),
            const SizedBox(height: 18),
            const Text(
              'Your forest is quiet yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ForestTheme.mistIvory,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save a discovery in the Whispering Woods and it will wait '
              'for you here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: ForestTheme.mistIvory.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const ForestExploreScreen(),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ForestTheme.fern,
                side: const BorderSide(color: ForestTheme.fern),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.explore_outlined, size: 20),
              label: const Text(
                'Explore the Whispering Woods',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
