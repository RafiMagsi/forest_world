import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

/// Looping ambient sound for the forest.
///
/// * Home / Explore / Tree screens play soft birdsong.
/// * The Hidden Stream detail swaps to trickling water.
/// * The user can mute everything with the speaker toggle in the top bar.
///
/// All platform errors are swallowed: on the web, autoplay before the first
/// user gesture is blocked by the browser, and a silent nature app is still
/// a better experience than a crashed one. The next tap on the toggle will
/// start the ambience.
class AmbientSoundscape extends ChangeNotifier with WidgetsBindingObserver {
  AmbientSoundscape._() {
    _player.setReleaseMode(ReleaseMode.loop);
  }

  static final AmbientSoundscape instance = AmbientSoundscape._();

  static const birdsAsset = 'audio/forest_birds.mp3';
  static const streamAsset = 'audio/forest_stream.mp3';

  final AudioPlayer _player = AudioPlayer();

  bool _enabled = true;
  bool _attached = false;
  String _currentTrack = birdsAsset;
  bool _appResumed = true;
  bool _playing = false;

  bool get enabled => _enabled;

  /// Wire up app lifecycle so ambience pauses in the background.
  void attachLifecycle() {
    if (_attached) return;
    _attached = true;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Ask for a track (idempotent). Plays immediately when sound is on.
  Future<void> playTrack(String asset) async {
    if (_currentTrack != asset) {
      _currentTrack = asset;
      if (_enabled && _playing) {
        // Restart on the new ambience.
        await _safe(() => _player.stop());
        _playing = false;
      }
    }
    await _resumeIfWanted();
  }

  Future<void> toggle() async {
    _enabled = !_enabled;
    notifyListeners();
    if (_enabled) {
      await _resumeIfWanted();
    } else {
      await _safe(() => _player.stop());
      _playing = false;
    }
  }

  Future<void> _resumeIfWanted() async {
    if (!_enabled || !_appResumed || _playing) return;
    await _safe(() async {
      await _player.play(AssetSource(_currentTrack));
      _playing = true;
    });
  }

  Future<void> _pause() async {
    if (!_playing) return;
    await _safe(() => _player.stop());
    _playing = false;
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('AmbientSoundscape: $e');
    }
  }

  // App lifecycle ----------------------------------------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _appResumed) return;
    _appResumed = resumed;
    if (resumed) {
      _resumeIfWanted();
    } else {
      _pause();
    }
  }

  Future<void> disposePlayer() async {
    WidgetsBinding.instance.removeObserver(this);
    await _safe(() => _player.dispose());
  }
}
