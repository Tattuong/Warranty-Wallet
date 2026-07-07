import 'package:flutter/material.dart';

/// Copper Ink Vault — warm premium palette, distinct from generic blue/green apps.
class AppColors {
  static const Color primary = Color(0xFFC2773A);
  static const Color primaryLight = Color(0xFFE8A35D);
  static const Color primaryDark = Color(0xFF92400E);

  static const Color accent = Color(0xFF2DD4BF);
  static const Color accentAlt = Color(0xFFFB7185);

  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5EBE0);
  static const Color surfaceElevated = Color(0xFFFFFCF8);

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

  static const Color darkBackground = Color(0xFF14110F);
  static const Color darkSurface = Color(0xFF1F1A17);
  static const Color darkSurfaceVariant = Color(0xFF292524);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF92400E), Color(0xFFC2773A), Color(0xFFE8A35D)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC2773A), Color(0xFF2DD4BF)],
  );

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
