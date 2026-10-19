import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/forest_theme.dart';

/// Global observer so full-screen videos can pause whenever another route
/// covers them (performance rule: never run several videos at once).
final RouteObserver<ModalRoute<void>> forestRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// Plays a bundled, portrait forest clip with muted autoplay and a seamless
/// loop, while handling everything a preview needs to stay robust:
///
/// * initialization with a soft loading shimmer,
/// * a gradient error fallback when a clip cannot be decoded,
/// * pausing when the app is backgrounded or another route covers this one,
/// * full disposal when the screen is removed.
class LoopingForestVideo extends StatefulWidget {
  const LoopingForestVideo({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.scrim,
    this.fadeIn = true,
    this.kenBurns = false,
    this.focusPull = false,
  });

  /// Asset path, e.g. `assets/videos/forest_home.mp4`.
  final String asset;

  final BoxFit fit;

  /// Optional gradient drawn over the video (usually [ForestTheme.videoScrim]).
  final Gradient? scrim;

  /// Gently fade the clip in once it is ready.
  final bool fadeIn;

  /// Slow, endless push-in and drift — makes even a static shot feel filmed.
  final bool kenBurns;

  /// Open on a soft, slightly over-scaled frame that racks into focus, like
  /// a camera finding its subject.
  final bool focusPull;

  @override
  State<LoopingForestVideo> createState() => _LoopingForestVideoState();
}

class _LoopingForestVideoState extends State<LoopingForestVideo>
    with WidgetsBindingObserver, RouteAware, TickerProviderStateMixin {
  late final VideoPlayerController _controller;

  late final AnimationController _drift;
  late final AnimationController _focus;

  bool _ready = false;
  bool _failed = false;
  bool _visible = true; // route is the current one
  bool _appResumed = true;
  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    );
    _focus = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller = VideoPlayerController.asset(
      widget.asset,
      // Ambient clip: never steal audio focus from music or the soundscape.
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      if (!mounted) {
        await _controller.dispose();
        return;
      }
      await _controller.setLooping(true);
      await _controller.setVolume(0); // muted autoplay, per spec
      if (!mounted) return;
      setState(() => _ready = true);
      if (widget.kenBurns) _drift.repeat();
      if (widget.focusPull) _focus.forward();
      _updatePlayback();
    } catch (_) {
      // Missing asset, unsupported codec, blocked platform... show the
      // graceful gradient fallback instead of crashing the experience.
      if (mounted) setState(() => _failed = true);
    }
  }

  void _updatePlayback() {
    if (!_ready || _failed) return;
    final shouldPlay = _visible && _appResumed;
    if (shouldPlay) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subscribed) {
      final route = ModalRoute.of(context);
      if (route is PageRoute) {
        forestRouteObserver.subscribe(this, route);
        _subscribed = true;
        _visible = route.isCurrent;
        _updatePlayback();
      }
    }
  }

  // RouteAware -------------------------------------------------------------
  @override
  void didPush() {
    _visible = true;
    _updatePlayback();
  }

  @override
  void didPushNext() {
    _visible = false;
    _updatePlayback();
  }

  @override
  void didPopNext() {
    _visible = true;
    _updatePlayback();
  }

  @override
  void didPop() {
    _visible = false;
    _updatePlayback();
  }

  // App lifecycle ----------------------------------------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _updatePlayback();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_subscribed) forestRouteObserver.unsubscribe(this);
    _drift.dispose();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_failed) {
      content = const _VideoFallback();
    } else if (!_ready) {
      content = const _LoadingShimmer();
    } else {
      final size = _controller.value.size;
      content = FittedBox(
        fit: widget.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(_controller),
        ),
      );
      if (!MediaQuery.disableAnimationsOf(context) &&
          (widget.kenBurns || widget.focusPull)) {
        content = _CameraMove(
          drift: _drift,
          focus: widget.focusPull ? _focus : null,
          child: content,
        );
      }
      content = TweenAnimationBuilder<double>(
        tween: Tween(begin: widget.fadeIn ? 0 : 1, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOut,
        child: content,
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(child: content),
        if (widget.scrim != null)
          DecoratedBox(decoration: BoxDecoration(gradient: widget.scrim)),
      ],
    );
  }
}

/// Applies the Ken Burns drift and the opening focus pull to the video.
class _CameraMove extends StatelessWidget {
  const _CameraMove({required this.drift, required this.child, this.focus});

  final Animation<double> drift;
  final Animation<double>? focus;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final focusCurve = focus == null
        ? null
        : CurvedAnimation(parent: focus!, curve: Curves.easeOutCubic);
    return ClipRect(
      child: AnimatedBuilder(
        animation: Listenable.merge([drift, ?focusCurve]),
        child: child,
        builder: (context, child) {
          final t = drift.value * 2 * math.pi;
          final f = focusCurve?.value ?? 1;
          // Breathe between 1.04x and 1.10x, drifting a few pixels.
          final scale = 1.07 + 0.03 * math.sin(t) + 0.12 * (1 - f);
          final dx = 10 * math.cos(t);
          final dy = 6 * math.sin(t * 2);
          final sigma = 14 * (1 - f);
          // Constant tree shape: toggling `enabled` keeps the VideoPlayer
          // mounted when the focus pull finishes.
          return ImageFiltered(
            enabled: sigma > 0.1,
            imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translateByDouble(dx, dy, 0, 1)
                ..scaleByDouble(scale, scale, 1, 1),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Soft animated gradient shown while the controller initializes.
class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = 0.5 + 0.5 * (2 * (_controller.value % 0.5) - 0.5).abs();
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, -1),
              end: Alignment(1 - 2 * t, 1),
              colors: const [
                ForestTheme.deepForest,
                Color(0xFF1D3A2D),
                ForestTheme.deepForest,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Keeps the screen visually calm when a clip cannot be played.
class _VideoFallback extends StatelessWidget {
  const _VideoFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ForestTheme.deepForest,
            Color(0xFF1D3A2D),
            Color(0xFF254736),
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.25,
          child: Icon(Icons.park_outlined, size: 96, color: ForestTheme.fern),
        ),
      ),
    );
  }
}
