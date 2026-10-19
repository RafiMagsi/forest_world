import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../services/ambient_soundscape.dart';
import '../theme/forest_theme.dart';
import '../widgets/forest_video_overlay.dart';
import '../widgets/looping_forest_video.dart';

/// Screen Three — Discover a Living Tree.
///
/// A cinematic close-up of the tree plays while its story slides gently into
/// view. The video autoplays muted; ambient sound follows the scene (water
/// for the stream, birdsong elsewhere).
class TreeDetailScreen extends StatefulWidget {
  const TreeDetailScreen({super.key, required this.discovery});

  final ForestDiscovery discovery;

  /// Fades the tree video in as the information moves into view.
  static Future<void> push(BuildContext context, ForestDiscovery discovery) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => TreeDetailScreen(discovery: discovery),
        transitionDuration: const Duration(milliseconds: 750),
        reverseTransitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.65, curve: Curves.easeOut),
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
          ));
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  @override
  State<TreeDetailScreen> createState() => _TreeDetailScreenState();
}

class _TreeDetailScreenState extends State<TreeDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final AnimationController _heart = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    // The stream detail swaps the ambience to running water.
    final track = widget.discovery.id == 'hidden_stream'
        ? AmbientSoundscape.streamAsset
        : AmbientSoundscape.birdsAsset;
    AmbientSoundscape.instance.playTrack(track);
  }

  @override
  void dispose() {
    _intro.dispose();
    _heart.dispose();
    super.dispose();
  }

  void _toggleSave(ForestDiscovery discovery) {
    final nowSaved = SavedForestStore.instance.toggle(discovery);
    if (nowSaved) {
      _heart.forward(from: 0);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('${discovery.title} saved to My Forest'),
            duration: const Duration(seconds: 2),
          ),
        );
    } else {
      _heart.reverse(from: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final discovery = widget.discovery;

    return Scaffold(
      backgroundColor: ForestTheme.deepForest,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final videoHeight = (constraints.maxHeight * 0.46).clamp(240.0, 460.0);
          return Column(
            children: [
              // -------------------------------------------------- video
              SizedBox(
                height: videoHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _intro,
                        curve: const Interval(0, 0.7, curve: Curves.easeOut),
                      ),
                      child: LoopingForestVideo(
                        asset: discovery.videoAsset,
                        scrim: ForestTheme.softVideoScrim,
                      ),
                    ),
                    ForestVideoOverlay(gradient: ForestTheme.softVideoScrim),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    color: ForestTheme.mistIvory,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Forest',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ForestTheme.mistIvory,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListenableBuilder(
                              listenable: SavedForestStore.instance,
                              builder: (context, _) {
                                final saved = SavedForestStore.instance
                                    .isSaved(discovery.id);
                                return IconButton(
                                  onPressed: () => _toggleSave(discovery),
                                  icon: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                        scale: anim,
                                        child: child,
                                      ),
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
              ),

              // ------------------------------------------------ content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
                  child: _staggered(
                    from: 0.35,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          discovery.kicker,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.4,
                            color: ForestTheme.morningGold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          discovery.title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: ForestTheme.mistIvory,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          discovery.description,
                          style: TextStyle(
                            fontSize: 15.5,
                            height: 1.55,
                            color: ForestTheme.mistIvory.withValues(alpha: 0.82),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: ForestTheme.deepForest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ForestTheme.mossGreen.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _InfoColumn(
                                  label: 'SPECIES',
                                  value: discovery.species,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: ForestTheme.mossGreen
                                    .withValues(alpha: 0.6),
                              ),
                              Expanded(
                                child: _InfoColumn(
                                  label: 'STATUS',
                                  value: discovery.status,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D3A2D)
                                .withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: ForestTheme.fern.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DID YOU KNOW?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: ForestTheme.morningGold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                discovery.didYouKnow,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.5,
                                  color: ForestTheme.mistIvory
                                      .withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SaveButton(
                          discovery: discovery,
                          heart: _heart,
                          onPressed: () => _toggleSave(discovery),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _staggered({required double from, required Widget child}) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _intro,
        curve: Interval(from, 1, curve: Curves.easeOutCubic),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _intro,
          curve: Interval(from, 1, curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.discovery,
    required this.heart,
    required this.onPressed,
  });

  final ForestDiscovery discovery;
  final Animation<double> heart;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SavedForestStore.instance,
      builder: (context, _) {
        final saved = SavedForestStore.instance.isSaved(discovery.id);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: saved
                ? null
                : const LinearGradient(
                    colors: [ForestTheme.fern, Color(0xFF7C9462)],
                  ),
            color: saved ? ForestTheme.deepForest : null,
            border: Border.all(
              color: saved
                  ? ForestTheme.morningGold
                  : ForestTheme.morningGold.withValues(alpha: 0),
              width: 1.4,
            ),
            boxShadow: saved
                ? null
                : [
                    BoxShadow(
                      color: ForestTheme.fern.withValues(alpha: 0.4),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.35).animate(
                      CurvedAnimation(parent: heart, curve: Curves.easeOutBack),
                    ),
                    child: Icon(
                      saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: saved
                          ? ForestTheme.morningGold
                          : ForestTheme.deepForest,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    saved ? 'Saved to My Forest' : 'Save Discovery',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: saved
                          ? ForestTheme.mistIvory
                          : ForestTheme.deepForest,
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

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: ForestTheme.fern.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ForestTheme.mistIvory,
          ),
        ),
      ],
    );
  }
}
