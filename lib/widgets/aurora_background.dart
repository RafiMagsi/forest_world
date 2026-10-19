import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/forest_theme.dart';

/// Slow, living gradient for screens without video: soft pools of moss,
/// fern and gold light drift across deep forest like light through leaves.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: ForestTheme.deepForest),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _clock,
            builder: (context, _) {
              final t = still ? 0.0 : _clock.value * 2 * math.pi;
              return Stack(
                fit: StackFit.expand,
                children: [
                  _blob(
                    Alignment(
                      -0.8 + 0.3 * math.sin(t),
                      -0.7 + 0.2 * math.cos(t),
                    ),
                    ForestTheme.mossGreen.withValues(alpha: 0.55),
                    1.3,
                  ),
                  _blob(
                    Alignment(0.9 + 0.2 * math.cos(t), 0.1 + 0.3 * math.sin(t)),
                    ForestTheme.fern.withValues(alpha: 0.22),
                    1.1,
                  ),
                  _blob(
                    Alignment(
                      0.5 * math.sin(t + 1.4),
                      -1.05 + 0.15 * math.cos(t),
                    ),
                    ForestTheme.morningGold.withValues(alpha: 0.18),
                    0.9,
                  ),
                ],
              );
            },
          ),
        ),
        // Grain-free vignette to seat content.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.2,
              colors: [Color(0x000B1D15), Color(0xCC0B1D15)],
            ),
          ),
        ),
        ?widget.child,
      ],
    );
  }

  Widget _blob(Alignment center, Color color, double radius) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
