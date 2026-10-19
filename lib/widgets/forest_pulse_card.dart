import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../theme/forest_theme.dart';

/// "YOUR FOREST AT A GLANCE" — a compact translucent panel over the moving
/// forest video. Values are sample demonstration data and count gently into
/// view when the screen opens.
class ForestPulseCard extends StatelessWidget {
  const ForestPulseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ForestTheme.deepForest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ForestTheme.fern.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR FOREST AT A GLANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: ForestTheme.morningGold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PulseMetric(
                  value: ForestPulse.speciesDiscovered,
                  label: 'Species discovered',
                ),
              ),
              _divider(),
              Expanded(
                child: _PulseMetric(
                  value: ForestPulse.treesExplored,
                  label: 'Trees explored',
                ),
              ),
              _divider(),
              Expanded(
                child: _PulseMetric(
                  value: ForestPulse.wildlifeObservations,
                  label: 'Wildlife observations',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 42,
        color: ForestTheme.mossGreen.withValues(alpha: 0.5),
      );
}

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$animated',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ForestTheme.mistIvory,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: ForestTheme.mistIvory.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      },
    );
  }
}
