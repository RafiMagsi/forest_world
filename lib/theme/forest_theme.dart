import 'package:flutter/material.dart';

/// ForestOS visual identity.
///
/// Design principle: The forest is alive. The interface helps you explore it.
/// The video provides most of the visual richness, so this theme defines the
/// palette, an editorial type pairing (Instrument Serif + Manrope), motion
/// tokens and the scrims that keep text readable over moving footage.
class ForestTheme {
  const ForestTheme._();

  // ---------------------------------------------------------------- palette

  /// Deep Forest — backgrounds and overlays.
  static const deepForest = Color(0xFF0B1D15);

  /// Canopy — raised surfaces on non-video screens.
  static const canopy = Color(0xFF13291F);

  /// Moss Green — secondary UI elements.
  static const mossGreen = Color(0xFF4F6B47);

  /// Fern — buttons and interactive elements.
  static const fern = Color(0xFFA3C585);

  /// Spring Glow — a luminous accent reserved for "live" signals.
  static const springGlow = Color(0xFFD4F28E);

  /// Mist Ivory — text and light surfaces.
  static const mistIvory = Color(0xFFF5F2E8);

  /// Morning Gold — small highlights.
  static const morningGold = Color(0xFFE9C27D);

  /// Primary call-to-action fill: sunlit fern.
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0F5B0), fern, Color(0xFF86AC69)],
    stops: [0, 0.55, 1],
  );

  /// Gilded text / accent gradient.
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBE7B5), morningGold, Color(0xFFD49A4A)],
  );

  // ----------------------------------------------------------------- motion

  /// Expressive deceleration used for entrances.
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1);
  static const Duration quick = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 420);
  static const Duration slow = Duration(milliseconds: 900);

  // ----------------------------------------------------------------- scrims

  /// Vertical scrim laid over video so ivory text stays readable without
  /// placing large opaque cards over the scenery.
  static const videoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x990B1D15),
      Color(0x000B1D15),
      Color(0x000B1D15),
      Color(0xB30B1D15),
      Color(0xF00B1D15),
    ],
    stops: [0.0, 0.26, 0.48, 0.78, 1.0],
  );

  /// A gentler scrim for partially covered video (e.g. detail header).
  static const softVideoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x800B1D15), Color(0x000B1D15), Color(0xCC0B1D15)],
    stops: [0.0, 0.45, 1.0],
  );

  // ------------------------------------------------------------- typography

  static const displayFamily = 'InstrumentSerif';
  static const textFamily = 'Manrope';

  static const _softShadow = [
    Shadow(color: Color(0x59000000), blurRadius: 16, offset: Offset(0, 2)),
  ];

  /// Editorial serif for headlines.
  static TextStyle display({
    double size = 44,
    bool italic = false,
    Color color = mistIvory,
    double height = 1.0,
  }) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: size,
      height: height,
      letterSpacing: -0.02 * size,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      color: color,
      shadows: _softShadow,
    );
  }

  /// Small uppercase tracking label (kickers, section titles).
  static TextStyle label({
    double size = 11,
    Color color = morningGold,
    double opacity = 1,
  }) {
    return TextStyle(
      fontFamily: textFamily,
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: size * 0.2,
      color: color.withValues(alpha: opacity),
    );
  }

  /// Ivory text with a whisper of shadow — keeps type legible over bright
  /// sunlight and busy foliage.
  static TextStyle ivory({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    double spacing = 0,
    Color color = mistIvory,
    double opacity = 1,
    double? height,
  }) {
    return TextStyle(
      fontFamily: textFamily,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      height: height,
      color: color.withValues(alpha: opacity),
      shadows: _softShadow,
    );
  }

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: textFamily,
      scaffoldBackgroundColor: deepForest,
      colorScheme: const ColorScheme.dark(
        primary: fern,
        secondary: morningGold,
        tertiary: springGlow,
        surface: deepForest,
        surfaceContainer: canopy,
        onPrimary: deepForest,
        onSecondary: deepForest,
        onSurface: mistIvory,
      ),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: mistIvory,
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: textFamily,
        bodyColor: mistIvory,
        displayColor: mistIvory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: canopy,
        contentTextStyle: const TextStyle(
          fontFamily: textFamily,
          fontWeight: FontWeight.w600,
          color: mistIvory,
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: morningGold.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
