import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/forest_theme.dart';

/// [ForestTheme.emphasized] starting after [delay] within a controller that
/// runs for `delay + duration`.
Curve delayedCurve(Duration delay, Duration duration) {
  final total = (delay + duration).inMicroseconds;
  if (total == 0) return ForestTheme.emphasized;
  return Interval(
    delay.inMicroseconds / total,
    1,
    curve: ForestTheme.emphasized,
  );
}

/// Entrance animation: the child rises, sharpens out of a soft blur and
/// fades in after [delay]. Shows instantly when the platform asks for
/// reduced motion.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
    this.offset = 24,
    this.blur = 8,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Vertical travel in logical pixels.
  final double offset;

  /// Starting blur sigma; 0 disables the blur-in.
  final double blur;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  // The delay is folded into the controller as a leading interval, so no
  // timers outlive the widget.
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.delay + widget.duration,
    )..forward();
    _t = CurvedAnimation(
      parent: _controller,
      curve: delayedCurve(widget.delay, widget.duration),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        final sigma = widget.blur * (1 - v);
        // Keep the tree shape constant (toggle `enabled`, never unwrap) so
        // the child's state survives the end of the animation.
        return ImageFiltered(
          enabled: sigma > 0.05,
          imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - v)),
            child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
          ),
        );
      },
    );
  }
}

/// A headline word and whether it carries the gilded italic accent.
typedef HeadlineWord = ({String text, bool accent});

/// Editorial headline that rises word by word from behind a mask, like
/// title cards in a nature documentary.
class WordReveal extends StatelessWidget {
  const WordReveal({
    super.key,
    required this.lines,
    required this.style,
    required this.accentStyle,
    this.delay = Duration.zero,
    this.stagger = const Duration(milliseconds: 90),
  });

  final List<List<HeadlineWord>> lines;
  final TextStyle style;
  final TextStyle accentStyle;
  final Duration delay;
  final Duration stagger;

  @override
  Widget build(BuildContext context) {
    var index = 0;
    final label = lines.map((l) => l.map((w) => w.text).join(' ')).join(' ');
    return Semantics(
      header: true,
      label: label,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Wrap(
              spacing: (style.fontSize ?? 40) * 0.24,
              children: [
                for (final word in line)
                  _MaskedWord(
                    delay: delay + stagger * index++,
                    child: word.accent
                        ? ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback:
                                ForestTheme.goldGradient.createShader,
                            child: Text(word.text, style: accentStyle),
                          )
                        : Text(word.text, style: style),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MaskedWord extends StatefulWidget {
  const _MaskedWord({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  State<_MaskedWord> createState() => _MaskedWordState();
}

class _MaskedWordState extends State<_MaskedWord>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1000);

  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.delay + _duration,
    )..forward();
    _t = CurvedAnimation(
      parent: _controller,
      curve: delayedCurve(widget.delay, _duration),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    // Pad the clip so descenders and italic overhangs are not cut off.
    return ClipRect(
      clipper: const _LooseClipper(),
      child: AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (context, child) => FractionalTranslation(
          translation: Offset(0, 1.05 * (1 - _t.value)),
          child: Transform.rotate(
            angle: 0.06 * (1 - _t.value),
            alignment: Alignment.bottomLeft,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LooseClipper extends CustomClipper<Rect> {
  const _LooseClipper();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-size.width, -size.height, size.width * 2, size.height);

  @override
  bool shouldReclip(_LooseClipper oldClipper) => false;
}

/// Gives any tappable surface a soft press-in scale with a haptic tick.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.96,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: ForestTheme.quick,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// The hero call-to-action: a sunlit pill with a light sweep that glides
/// across every few seconds, a glowing halo and an arrow medallion.
class ShimmerButton extends StatefulWidget {
  const ShimmerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: PressableScale(
        scale: 0.97,
        onTap: widget.onPressed,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: ForestTheme.ctaGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: ForestTheme.fern.withValues(alpha: 0.45),
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!still)
                  AnimatedBuilder(
                    animation: _sweep,
                    builder: (context, _) {
                      // Sweep during the first 35% of the cycle, then rest.
                      final p = (_sweep.value / 0.35).clamp(0.0, 1.0);
                      return FractionalTranslation(
                        translation: Offset(-1.2 + 2.4 * p, 0),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-1, -0.4),
                              end: Alignment(1, 0.4),
                              colors: [
                                Color(0x00FFFFFF),
                                Color(0x88FFFFFF),
                                Color(0x00FFFFFF),
                              ],
                              stops: [0.3, 0.5, 0.7],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            fontFamily: ForestTheme.textFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                            color: ForestTheme.deepForest,
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ForestTheme.deepForest,
                        ),
                        child: Icon(
                          widget.icon,
                          color: ForestTheme.springGlow,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A tiny breathing dot that signals something is live.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.color = ForestTheme.springGlow});

  final Color color;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final t = _pulse.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 6 + 8 * t,
                height: 6 + 8 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.45 * (1 - t)),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
