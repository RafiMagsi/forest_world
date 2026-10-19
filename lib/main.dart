import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/forest_discovery.dart';
import 'screens/forest_explore_screen.dart';
import 'screens/forest_home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/my_forest_screen.dart';
import 'screens/tree_detail_screen.dart';
import 'services/ambient_soundscape.dart';
import 'theme/forest_theme.dart';
import 'widgets/looping_forest_video.dart';

/// Optional screen to open on launch, for recording demos of a single scene:
/// `flutter run --dart-define=FOREST_START=explore` (or `map`, `my_forest`,
/// `detail`).
const _startScreen = String.fromEnvironment('FOREST_START');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  AmbientSoundscape.instance.attachLifecycle();
  runApp(const ForestOSApp());
}

/// ForestOS — an immersive, video-first nature preview.
///
/// Design principle: The forest is alive. The interface helps you explore it.
class ForestOSApp extends StatelessWidget {
  const ForestOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForestOS',
      debugShowCheckedModeBanner: false,
      theme: ForestTheme.theme,
      navigatorObservers: [forestRouteObserver],
      // One shared backdrop for every glass panel on screen, so blurring
      // over moving video costs a single backdrop read per frame.
      builder: (context, child) => BackdropGroup(child: child!),
      home: switch (_startScreen) {
        'explore' => const ForestExploreScreen(),
        'map' => const MapScreen(),
        'my_forest' => const MyForestScreen(),
        'detail' => const TreeDetailScreen(
          discovery: ForestDiscovery.ancientOak,
        ),
        _ => const ForestHomeScreen(),
      },
    );
  }
}
