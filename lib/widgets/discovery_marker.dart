import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/forest_theme.dart';

/// A glowing pin that floats above the moving aerial video.
///
/// Radar ripples spread from it continuously; when selected it turns Morning
/// Gold, lifts, and its name appears in a glass chip beneath.
class DiscoveryMarker extends StatefulWidget {
  const DiscoveryMarker({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon = Icons.location_on_rounded,
  });

  /// Size of the square pin + ripple area; the pin is centred within it.
  static const double pinExtent = 76;

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  State<DiscoveryMarker> createState() => _DiscoveryMarkerState();
}

class _DiscoveryMarkerState extends State<DiscoveryMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final accent = selected ? ForestTheme.morningGold : ForestTheme.springGlow;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Discover ${widget.label}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: DiscoveryMarker.pinExtent,
              height: DiscoveryMarker.pinExtent,
              child: AnimatedBuilder(
                animation: _ripple,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var i = 0; i < 2; i++)
                        _ring((_ripple.value + i / 2) % 1, accent),
                      child!,
                    ],
                  );
                },
                child: AnimatedScale(
                  scale: selected ? 1.18 : 1,
                  duration: ForestTheme.medium,
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: ForestTheme.medium,
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: selected ? ForestTheme.goldGradient : null,
                      color: selected
                          ? null
                          : ForestTheme.deepForest.withValues(alpha: 0.6),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.9),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: selected ? 0.7 : 0.4),
                          blurRadius: selected ? 22 : 14,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: selected ? ForestTheme.deepForest : accent,
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: ForestTheme.medium,
              switchInCurve: ForestTheme.emphasized,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(anim),
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
              child: selected
                  ? Container(
                      key: const ValueKey('label'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ForestTheme.deepForest.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: ForestTheme.morningGold.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        widget.label,
                        style: ForestTheme.ivory(
                          size: 12,
                          weight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox(key: ValueKey('none'), height: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ring(double t, Color color) {
    return Container(
      width: 38 + 38 * t,
      height: 38 + 38 * t,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.55 * (1 - t)),
          width: 1.2,
        ),
      ),
    );
  }
}
