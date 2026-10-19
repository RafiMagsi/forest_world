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
  });

  /// Asset path, e.g. `assets/videos/forest_home.mp4`.
  final String asset;

  final BoxFit fit;

  /// Optional gradient drawn over the video (usually [ForestTheme.videoScrim]).
  final Gradient? scrim;

  /// Gently fade the clip in once it is ready.
  final bool fadeIn;

  @override
  State<LoopingForestVideo> createState() => _LoopingForestVideoState();
}

class _LoopingForestVideoState extends State<LoopingForestVideo>
    with WidgetsBindingObserver, RouteAware {
  late final VideoPlayerController _controller;

  bool _ready = false;
  bool _failed = false;
  bool _visible = true; // route is the current one
  bool _appResumed = true;
  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.asset(widget.asset);
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
      content = AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: _ready ? 1 : 0,
        child: FittedBox(
          fit: widget.fit,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: VideoPlayer(_controller),
          ),
        ),
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
