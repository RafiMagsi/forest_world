import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../services/ambient_soundscape.dart';
import '../theme/forest_theme.dart';
import '../widgets/discovery_marker.dart';
import '../widgets/forest_bottom_nav.dart';
import '../widgets/forest_video_overlay.dart';
import '../widgets/looping_forest_video.dart';
import 'map_screen.dart';
import 'my_forest_screen.dart';
import 'tree_detail_screen.dart';

/// Screen Two — Explore the Living Forest.
///
/// An aerial forest video fills the main area while glowing discovery pins
/// float above the moving landscape. Markers are positioned manually over the
/// video — no real geographic mapping needed for the preview.
class ForestExploreScreen extends StatefulWidget {
  const ForestExploreScreen({super.key});

  /// Pushes the explore screen with the "Enter the Forest" transition: the
  /// home scene fades and drifts forward into the aerial view.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const ForestExploreScreen(),
        transitionDuration: const Duration(milliseconds: 850),
        reverseTransitionDuration: const Duration(milliseconds: 650),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.7, curve: Curves.easeOut),
          );
          final scale = Tween<double>(begin: 1.06, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              alignment: Alignment.topCenter,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<ForestExploreScreen> createState() => _ForestExploreScreenState();
}

class _ForestExploreScreenState extends State<ForestExploreScreen> {
  ForestDiscovery? _selected;
  bool _cardOpen = false;

  @override
  void initState() {
    super.initState();
    AmbientSoundscape.instance.playTrack(AmbientSoundscape.birdsAsset);
  }

  void _selectMarker(ForestDiscovery discovery) {
    setState(() {
      _selected = discovery;
      _cardOpen = true;
    });
  }

  void _closeCard() {
    setState(() {
      _cardOpen = false;
      _selected = null;
    });
  }

  void _openDetail(ForestDiscovery discovery) {
    TreeDetailScreen.push(context, discovery);
  }

  void _openTab(int index) {
    switch (index) {
      case ForestBottomNav.exploreIndex:
        break;
      case ForestBottomNav.mapIndex:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const MapScreen()),
        );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------- header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 24, 14),
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
                    'Explore',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: ForestTheme.mistIvory,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'WHISPERING WOODS',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                          color:
                              ForestTheme.morningGold.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Whispering Woods',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: ForestTheme.mistIvory,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'A forest full of stories.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xB3F4F1E7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------- aerial video
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LoopingForestVideo(
                        asset: 'assets/videos/forest_aerial.mp4',
                        scrim: ForestTheme.softVideoScrim,
                      ),
                      ForestVideoOverlay(gradient: ForestTheme.softVideoScrim),

                      // markers
                      for (final discovery in ForestDiscovery.all)
                        Align(
                          alignment: Alignment(
                            discovery.markerPosition.dx * 2 - 1,
                            discovery.markerPosition.dy * 2 - 1,
                          ),
                          child: DiscoveryMarker(
                            label: discovery.title,
                            selected: _selected?.id == discovery.id,
                            icon: switch (discovery.id) {
                              'ancient_oak' => Icons.park_rounded,
                              'hidden_stream' => Icons.water_drop_rounded,
                              _ => Icons.pets_rounded,
                            },
                            onTap: () => _selectMarker(discovery),
                          ),
                        ),

                      // gentle hint that fades once the user explores
                      if (_selected == null)
                        const Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 18),
                            child: Text(
                              'Tap a marker to discover',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xCCF4F1E7),
                              ),
                            ),
                          ),
                        ),

                      // discovery card slides up from the bottom
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                          offset: _cardOpen ? Offset.zero : const Offset(0, 1.3),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 320),
                            opacity: _cardOpen ? 1 : 0,
                            child: _selected == null
                                ? const SizedBox.shrink()
                                : _DiscoveryCard(
                                    discovery: _selected!,
                                    onClose: _closeCard,
                                    onOpen: () {
                                      final d = _selected;
                                      if (d != null) _openDetail(d);
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ------------------------------------------------ DISCOVER
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'DISCOVER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                  color: ForestTheme.morningGold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            for (final discovery in ForestDiscovery.all)
              _DiscoverRow(
                discovery: discovery,
                onTap: () => _openDetail(discovery),
              ),
            const SizedBox(height: 12),

            // --------------------------------------------------- nav
            ForestBottomNav(currentIndex: 0, onSelect: _openTab),
          ],
        ),
      ),
    );
  }
}

class _DiscoverRow extends StatelessWidget {
  const _DiscoverRow({required this.discovery, required this.onTap});

  final ForestDiscovery discovery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Text(discovery.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  discovery.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ForestTheme.mistIvory,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: ForestTheme.fern,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slid up over the moving aerial video when a marker is selected.
class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.discovery,
    required this.onClose,
    required this.onOpen,
  });

  final ForestDiscovery discovery;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ForestTheme.deepForest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ForestTheme.fern.withValues(alpha: 0.35)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpen,
          child: Row(
            children: [
              // Static gradient thumbnail — deliberately not a second video
              // controller (performance rule: one video at a time).
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF254736), ForestTheme.mossGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  discovery.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discovery.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ForestTheme.mistIvory,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      discovery.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: ForestTheme.mistIvory.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_outward_rounded,
                color: ForestTheme.morningGold,
                size: 20,
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: ForestTheme.mistIvory.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
