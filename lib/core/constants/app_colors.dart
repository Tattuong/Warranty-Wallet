import 'package:flutter/material.dart';

/// Copper Ink Vault — warm premium palette, distinct from generic blue/green apps.
class AppColors {
  static const Color copper = Color(0xFFC2773A);
  static const Color copperLight = Color(0xFFE8A35D);
  static const Color copperDark = Color(0xFF92400E);

  static Color _primary = copper;
  static Color _primaryLight = copperLight;
  static Color _primaryDark = copperDark;
  static Color _background = const Color(0xFFFFF8F0);
  static Color _surface = const Color(0xFFFFFFFF);
  static Color _surfaceVariant = const Color(0xFFF5EBE0);
  static Color _surfaceElevated = const Color(0xFFFFFCF8);
  static Color _darkBackground = const Color(0xFF14110F);
  static Color _darkSurface = const Color(0xFF1F1A17);
  static Color _darkSurfaceVariant = const Color(0xFF292524);
  static LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [copperDark, copper, copperLight],
  );
  static LinearGradient _heroGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [copper, Color(0xFF2DD4BF)],
  );

  static Color get primary => _primary;
  static Color get primaryLight => _primaryLight;
  static Color get primaryDark => _primaryDark;
  static Color get background => _background;
  static Color get surface => _surface;
  static Color get surfaceVariant => _surfaceVariant;
  static Color get surfaceElevated => _surfaceElevated;
  static Color get darkBackground => _darkBackground;
  static Color get darkSurface => _darkSurface;
  static Color get darkSurfaceVariant => _darkSurfaceVariant;
  static LinearGradient get headerGradient => _headerGradient;
  static LinearGradient get heroGradient => _heroGradient;

  /// Points brand colors at the theme the user applied.
  static void bind({
    required Color primary,
    required Color primaryLight,
    required Color background,
    required Color surface,
    required Color darkBackground,
    required Color darkSurface,
    required LinearGradient headerGradient,
    required LinearGradient heroGradient,
  }) {
    _primary = primary;
    _primaryLight = primaryLight;
    _primaryDark = headerGradient.colors.first;
    _background = background;
    _surface = surface;
    _darkBackground = darkBackground;
    _darkSurface = darkSurface;
    _headerGradient = headerGradient;
    _heroGradient = heroGradient;
    _surfaceVariant = Color.alphaBlend(primary.withValues(alpha: 0.10), background);
    _surfaceElevated = Color.lerp(surface, Colors.white, 0.7) ?? surface;
    _darkSurfaceVariant = Color.alphaBlend(primaryLight.withValues(alpha: 0.16), darkSurface);
  }

  static const Color accent = Color(0xFF2DD4BF);
  static const Color accentAlt = Color(0xFFFB7185);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1917);
  static const Color onSurfaceVariant = Color(0xFF78716C);

  static const Color success = Color(0xFF14B8A6);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFFB7185);
  static const Color coin = Color(0xFFFCD34D);
  static const Color expired = Color(0xFFFB7185);
  static const Color expiringSoon = Color(0xFFFBBF24);
  static const Color active = Color(0xFF2DD4BF);
  static const Color upcoming = Color(0xFFC084FC);

  static const LinearGradient meshCopper = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [Color(0x33C2773A), Color(0x222DD4BF), Color(0x18FB7185)],
  );

  static const List<Color> tagPalette = [
    Color(0xFFC2773A),
    Color(0xFF2DD4BF),
    Color(0xFFFB7185),
    Color(0xFFC084FC),
    Color(0xFFFBBF24),
    Color(0xFF38BDF8),
    Color(0xFF34D399),
    Color(0xFF78716C),
  ];

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : background;
}
