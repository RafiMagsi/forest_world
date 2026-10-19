import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../theme/forest_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/firefly_field.dart';
import '../widgets/forest_bottom_nav.dart';
import '../widgets/glass_panel.dart';
import '../widgets/motion.dart';
import 'forest_tabs.dart';
import 'tree_detail_screen.dart';

/// The user's saved discoveries — everything they tapped "Save Discovery" on.
class MyForestScreen extends StatelessWidget {
  const MyForestScreen({super.key});

  static const _ms = Duration(milliseconds: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const FireflyField(count: 22),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: GlassIconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Reveal(
                          delay: _ms * 200,
                          child: ListenableBuilder(
                            listenable: SavedForestStore.instance,
                            builder: (context, _) {
                              final n =
                                  SavedForestStore.instance.savedIds.length;
                              return Text(
                                'MY FOREST · $n SAVED',
                                style: ForestTheme.label(size: 12),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        WordReveal(
                          delay: _ms * 300,
                          style: ForestTheme.display(size: 46),
                          accentStyle: ForestTheme.display(
                            size: 46,
                            italic: true,
                          ),
                          lines: const [
                            [
                              (text: 'Kept', accent: false),
                              (text: 'close', accent: false),
                            ],
                            [
                              (text: 'to', accent: false),
                              (text: 'your', accent: false),
                              (text: 'heart', accent: true),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: SavedForestStore.instance,
                      builder: (context, _) {
                        final saved =
                            SavedForestStore.instance.savedDiscoveries;
                        if (saved.isEmpty) return const _EmptyForest();
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                          itemCount: saved.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => Reveal(
                            delay: _ms * (500 + 120 * index),
                            child: _SavedCard(discovery: saved[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ForestBottomNav(
                      currentIndex: ForestBottomNav.myForestIndex,
                      onSelect: (i) => openForestTab(
                        context,
                        i,
                        current: ForestBottomNav.myForestIndex,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.discovery});

  final ForestDiscovery discovery;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${discovery.title}, ${discovery.species}',
      excludeSemantics: true,
      child: PressableScale(
        onTap: () => TreeDetailScreen.push(context, discovery),
        child: GlassPanel(
          radius: 26,
          tint: 0.3,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2F5A43), ForestTheme.mossGreen],
                  ),
                ),
                child: Text(
                  discovery.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: ForestTheme.display(size: 24, height: 1.05),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${discovery.species} · ${discovery.status}',
                      style: ForestTheme.ivory(size: 13, opacity: 0.7),
                    ),
                  ],
                ),
              ),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: ForestTheme.goldGradient.createShader,
                child: const Icon(Icons.favorite_rounded, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyForest extends StatefulWidget {
  const _EmptyForest();

  @override
  State<_EmptyForest> createState() => _EmptyForestState();
}

class _EmptyForestState extends State<_EmptyForest>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rings;

  @override
  void initState() {
    super.initState();
    _rings = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _rings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Reveal(
          delay: const Duration(milliseconds: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: AnimatedBuilder(
                  animation: _rings,
                  builder: (context, _) => Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        _ring((_rings.value + i / 3) % 1),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: ForestTheme.ctaGradient,
                          boxShadow: [
                            BoxShadow(
                              color: ForestTheme.fern.withValues(alpha: 0.5),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.park_rounded,
                          size: 34,
                          color: ForestTheme.deepForest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Your forest is quiet yet',
                textAlign: TextAlign.center,
                style: ForestTheme.display(size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                'Save a discovery in the Whispering Woods and it will wait '
                'for you here.',
                textAlign: TextAlign.center,
                style: ForestTheme.ivory(size: 15, opacity: 0.72, height: 1.5),
              ),
              const SizedBox(height: 26),
              ShimmerButton(
                label: 'Explore the woods',
                icon: Icons.explore_rounded,
                onPressed: () => openForestTab(
                  context,
                  ForestBottomNav.exploreIndex,
                  current: ForestBottomNav.myForestIndex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ring(double t) {
    return Container(
      width: 72 + t * 78,
      height: 72 + t * 78,
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
