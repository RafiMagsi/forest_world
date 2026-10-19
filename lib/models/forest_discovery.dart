import 'package:flutter/foundation.dart';

/// A place the user can discover in the Whispering Woods.
///
/// Positions are relative (0..1) over the aerial exploration video, so the
/// markers stay pinned to the scene without any real geographic mapping.
class ForestDiscovery {
  const ForestDiscovery({
    required this.id,
    required this.emoji,
    required this.kicker,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.species,
    required this.status,
    required this.didYouKnow,
    required this.videoAsset,
    required this.markerPosition,
  });

  final String id;
  final String emoji;

  /// Small gold label above the title, e.g. "THE FOREST GIANT".
  final String kicker;
  final String title;
  final String shortDescription;
  final String description;
  final String species;
  final String status;
  final String didYouKnow;

  /// Asset used on the detail screen.
  final String videoAsset;

  /// Marker placement over the aerial video, in relative coordinates.
  final Offset markerPosition;

  static const ancientOak = ForestDiscovery(
    id: 'ancient_oak',
    emoji: '🌳',
    kicker: 'THE FOREST GIANT',
    title: 'The Ancient Oak',
    shortDescription: 'A living landmark of the Whispering Woods.',
    description:
        'A living landmark of the Whispering Woods, standing since before '
        'the paths were drawn. Its branches hold the quiet of centuries.',
    species: 'Oak',
    status: 'Thriving',
    didYouKnow: 'A single oak can host hundreds of species, from insects '
        'and birds to fungi and mosses. Oaks support diverse woodland '
        'ecosystems.',
    videoAsset: 'assets/videos/ancient_oak.mp4',
    markerPosition: Offset(0.30, 0.30),
  );

  static const hiddenStream = ForestDiscovery(
    id: 'hidden_stream',
    emoji: '💧',
    kicker: 'THE HIDDEN STREAM',
    title: 'The Hidden Stream',
    shortDescription: 'Cold water running softly between the roots.',
    description:
        'Cold water running softly between the roots, carrying morning '
        'light down to the valley floor. Follow it and you will never be '
        'lost.',
    species: 'Freshwater',
    status: 'Flowing',
    didYouKnow: 'Forest streams filter water naturally; every kilometre of '
        'healthy stream can cool the surrounding air by several degrees.',
    videoAsset: 'assets/videos/forest_stream.mp4',
    markerPosition: Offset(0.68, 0.52),
  );

  static const woodlandWildlife = ForestDiscovery(
    id: 'woodland_wildlife',
    emoji: '🐦',
    kicker: 'WOODLAND WILDLIFE',
    title: 'Woodland Wildlife',
    shortDescription: 'Movement in the canopy at first light.',
    description:
        'Movement in the canopy at first light — wings, paws and quiet '
        'footsteps. The forest never sleeps; it only softens its voice.',
    species: 'Mixed fauna',
    status: 'Active at dawn',
    didYouKnow: 'Many woodland birds sing loudest just before sunrise, a '
        'chorus known as the dawn effect.',
    videoAsset: 'assets/videos/forest_home.mp4',
    markerPosition: Offset(0.44, 0.68),
  );

  static const all = [ancientOak, hiddenStream, woodlandWildlife];
}

/// Sample demonstration data for the Forest Pulse panel — not live
/// environmental measurements.
class ForestPulse {
  const ForestPulse._();

  static const speciesDiscovered = 128;
  static const treesExplored = 24;
  static const wildlifeObservations = 16;
}

/// In-memory store of the discoveries the user has saved.
class SavedForestStore extends ChangeNotifier {
  SavedForestStore._();

  static final SavedForestStore instance = SavedForestStore._();

  final Set<String> _savedIds = <String>{};

  List<String> get savedIds => List.unmodifiable(_savedIds);

  List<ForestDiscovery> get savedDiscoveries => ForestDiscovery.all
      .where((d) => _savedIds.contains(d.id))
      .toList(growable: false);

  bool isSaved(String id) => _savedIds.contains(id);

  /// Returns true when the discovery is now saved.
  bool toggle(ForestDiscovery discovery) {
    final wasSaved = _savedIds.contains(discovery.id);
    if (wasSaved) {
      _savedIds.remove(discovery.id);
    } else {
      _savedIds.add(discovery.id);
    }
    notifyListeners();
    return !wasSaved;
  }
}
