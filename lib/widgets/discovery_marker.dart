import 'package:flutter/material.dart';

import '../theme/forest_theme.dart';

/// A restrained glowing pin that floats above the moving aerial video.
///
/// The marker breathes gently; when selected it brightens to Morning Gold and
/// its label fades in. Deliberately subtle — exploration, not sci-fi.
class DiscoveryMarker extends StatefulWidget {
  const DiscoveryMarker({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon = Icons.location_on_rounded,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  State<DiscoveryMarker> createState() => _DiscoveryMarkerState();
}

class _DiscoveryMarkerState extends State<DiscoveryMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2600 ~/ 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.selected
        ? (base: ForestTheme.morningGold, glow: ForestTheme.morningGold)
        : (base: ForestTheme.mistIvory, glow: ForestTheme.fern);

    return Semantics(
      button: true,
      label: 'Discover ${widget.label}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final wave = Curves.easeInOut.transform(_controller.value);
                final pulse = widget.selected ? 1.0 + 0.10 * wave : 1.0;
                final glow = widget.selected ? 0.55 + 0.35 * wave : 0.30 + 0.18 * wave;
                return Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.glow.withValues(alpha: glow),
                          blurRadius: widget.selected ? 26 : 18,
                          spreadRadius: widget.selected ? 5 : 2,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ForestTheme.deepForest.withValues(alpha: 0.55),
                  border: Border.all(
                    color: scheme.base.withValues(
                      alpha: widget.selected ? 0.95 : 0.65,
                    ),
                    width: 1.4,
                  ),
                ),
                child: Icon(widget.icon, size: 18, color: scheme.base),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: widget.selected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ForestTheme.deepForest.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: ForestTheme.morningGold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ForestTheme.mistIvory,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: 0, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}
