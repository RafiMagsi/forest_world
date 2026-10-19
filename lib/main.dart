import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/forest_home_screen.dart';
import 'services/ambient_soundscape.dart';
import 'theme/forest_theme.dart';
import 'widgets/looping_forest_video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
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
      home: const ForestHomeScreen(),
    );
  }
}
