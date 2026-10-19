import 'package:flutter/material.dart';

/// ForestOS visual identity.
///
/// Design principle: The forest is alive. The interface helps you explore it.
/// The video provides most of the visual richness, so this theme only defines
/// the palette, typography and the scrims that keep text readable over motion.
class ForestTheme {
  const ForestTheme._();

  /// Deep Forest — backgrounds and overlays.
  static const deepForest = Color(0xFF142B22);

  /// Moss Green — secondary UI elements.
  static const mossGreen = Color(0xFF526B48);

  /// Fern — buttons and interactive elements.
  static const fern = Color(0xFF91A878);

  /// Mist Ivory — text and light surfaces.
  static const mistIvory = Color(0xFFF4F1E7);

  /// Morning Gold — small highlights.
  static const morningGold = Color(0xFFD9B878);

  /// Subtle vertical scrim laid over video so ivory text stays readable
  /// without placing large opaque cards over the scenery.
  static const videoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xB3142B22),
      Color(0x00142B22),
      Color(0x00142B22),
      Color(0xE6142B22),
    ],
    stops: [0.0, 0.32, 0.55, 1.0],
  );

  /// A gentler scrim for partially covered video (e.g. detail header).
  static const softVideoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x99142B22),
      Color(0x00142B22),
      Color(0xCC142B22),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Ivory text with a whisper of shadow — keeps type legible over bright
  /// sunlight and busy foliage.
  static TextStyle ivory({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    double spacing = 0,
    Color color = mistIvory,
    double opacity = 1,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color.withValues(alpha: opacity),
      shadows: const [
        Shadow(
          color: Color(0x66000000),
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepForest,
      colorScheme: const ColorScheme.dark(
        primary: fern,
        secondary: morningGold,
        surface: deepForest,
        onPrimary: deepForest,
        onSecondary: deepForest,
        onSurface: mistIvory,
      ),
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: mistIvory,
        displayColor: mistIvory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepForest,
        contentTextStyle: const TextStyle(color: mistIvory),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x3391A878)),
        ),
      ),
    );
  }
}
