import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/forest_theme.dart';

/// Drifting motes of light — pollen in sunbeams by day, fireflies by dusk.
///
/// One [CustomPainter] driven by a single ticker; particles are generated once
/// from a fixed seed so the scene is stable between rebuilds. Honors the
/// platform "reduce motion" setting by rendering nothing.
class FireflyField extends StatefulWidget {
  const FireflyField({
    super.key,
    this.count = 38,
    this.color = ForestTheme.morningGold,
  });

  final int count;
  final Color color;

  @override
  State<FireflyField> createState() => _FireflyFieldState();
}

class _FireflyFieldState extends State<FireflyField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  late final List<_Mote> _motes;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _motes = _seed(widget.count);
  }

  static List<_Mote> _seed(int count) {
    final rng = math.Random(7);
    return List.generate(count, (_) {
      return _Mote(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 0.8 + rng.nextDouble() * 2.2,
        speed: 0.6 + rng.nextDouble() * 1.4,
        sway: 6 + rng.nextDouble() * 18,
        phase: rng.nextDouble() * math.pi * 2,
        twinkle: 1 + rng.nextDouble() * 3,
      );
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.expand();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _FireflyPainter(_motes, _clock, widget.color),
        ),
      ),
    );
  }
}

class _Mote {
  const _Mote({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.sway,
    required this.phase,
    required this.twinkle,
  });

  final double x, y, radius, speed, sway, phase, twinkle;
}

class _FireflyPainter extends CustomPainter {
  _FireflyPainter(this.motes, this.clock, this.color) : super(repaint: clock);

  final List<_Mote> motes;
  final Animation<double> clock;
  final Color color;

  final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  final Paint _core = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value * 40; // seconds
    for (final m in motes) {
      // Rise slowly and wrap around; sway sideways on a sine.
      final y = (m.y - t * 0.012 * m.speed) % 1.0;
      final x =
          m.x * size.width + math.sin(t * 0.5 * m.speed + m.phase) * m.sway;
      final pos = Offset(x, y * size.height);

      // Fade in near the bottom and out near the top; twinkle on top.
      final edge = math.min(1.0, math.min(y, 1 - y) * 5);
      final flicker =
          0.45 + 0.55 * (0.5 + 0.5 * math.sin(t * m.twinkle + m.phase));
      final alpha = (edge * flicker).clamp(0.0, 1.0);

      _glow.color = color.withValues(alpha: alpha * 0.55);
      canvas.drawCircle(pos, m.radius * 3.2, _glow);
      _core.color = Color.lerp(
        color,
        ForestTheme.mistIvory,
        0.6,
      )!.withValues(alpha: alpha);
      canvas.drawCircle(pos, m.radius * 0.7, _core);
    }
  }

  @override
  bool shouldRepaint(_FireflyPainter old) =>
      old.motes != motes || old.color != color;
}
