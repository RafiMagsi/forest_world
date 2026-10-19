import 'package:flutter/material.dart';

import '../models/forest_discovery.dart';
import '../theme/forest_theme.dart';
import 'glass_panel.dart';
import 'motion.dart';

/// "YOUR FOREST AT A GLANCE" — a compact liquid-glass panel over the moving
/// forest video. Values are sample demonstration data; they count up and
/// their progress threads fill with gold when the screen opens.
class ForestPulseCard extends StatelessWidget {
  const ForestPulseCard({super.key});

  static const _metrics = [
    (value: ForestPulse.speciesDiscovered, goal: 160, label: 'Species'),
    (value: ForestPulse.treesExplored, goal: 30, label: 'Trees'),
    (value: ForestPulse.wildlifeObservations, goal: 24, label: 'Wildlife'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'YOUR FOREST AT A GLANCE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ForestTheme.label(),
                ),
              ),
              const SizedBox(width: 8),
              const LiveDot(),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: ForestTheme.label(
                  size: 10,
                  color: ForestTheme.springGlow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < _metrics.length; i++) ...[
                if (i > 0) const SizedBox(width: 18),
                Expanded(
                  child: _PulseMetric(
                    value: _metrics[i].value,
                    goal: _metrics[i].goal,
                    label: _metrics[i].label,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({
    required this.value,
    required this.goal,
    required this.label,
  });

  final int value;
  final int goal;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1800),
        curve: ForestTheme.emphasized,
        builder: (context, t, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(value * t).round()}',
                style: ForestTheme.display(size: 34, height: 1),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: ForestTheme.ivory(
                  size: 12,
                  weight: FontWeight.w600,
                  opacity: 0.7,
                ),
              ),
              const SizedBox(height: 8),
              // Progress thread toward the season's goal.
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: ForestTheme.mistIvory.withValues(alpha: 0.12),
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (value / goal * t).clamp(0.0, 1.0),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: ForestTheme.goldGradient,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
