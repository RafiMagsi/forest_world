import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/forest_theme.dart';

/// "Liquid glass" surface: a live backdrop blur, a faint ivory sheen falling
/// from the top-left edge and a hairline highlight border.
///
/// Uses [BackdropFilter.grouped] so every panel on screen shares one backdrop
/// read when a [BackdropGroup] is above it (installed in `main.dart`), which
/// keeps blurring over moving video affordable on Impeller.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 24,
    this.blur = 24,
    this.tint = 0.32,
    this.padding = EdgeInsets.zero,
    this.highlight,
  });

  final Widget child;
  final double radius;
  final double blur;

  /// Opacity of the deep-forest tint behind the content.
  final double tint;
  final EdgeInsetsGeometry padding;

  /// Optional accent for the border (e.g. gold when selected).
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: shape,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ForestTheme.mistIvory.withValues(alpha: 0.14),
                ForestTheme.deepForest.withValues(alpha: tint),
                ForestTheme.deepForest.withValues(alpha: tint + 0.08),
              ],
              stops: const [0, 0.45, 1],
            ),
            border: Border.all(
              color: (highlight ?? ForestTheme.mistIvory).withValues(
                alpha: highlight == null ? 0.18 : 0.7,
              ),
              width: highlight == null ? 1 : 1.3,
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A round glass icon button for floating top-bar controls.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color = ForestTheme.mistIvory,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 999,
      blur: 18,
      tint: 0.22,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        color: color,
        icon: icon,
      ),
    );
  }
}
