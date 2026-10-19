import 'package:flutter/material.dart';

/// A gradient scrim laid over moving video so text stays readable without
/// covering the scenery with opaque cards. Uses a plain gradient instead of
/// an expensive blur, as the performance rules require.
class ForestVideoOverlay extends StatelessWidget {
  const ForestVideoOverlay({
    super.key,
    required this.gradient,
    this.child,
  });

  final Gradient gradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child == null ? const SizedBox.expand() : child,
    );
  }
}
