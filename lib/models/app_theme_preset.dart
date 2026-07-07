import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class AppThemePreset {
  final String id;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color darkBackground;
  final Color darkSurface;
  final LinearGradient headerGradient;
  final LinearGradient balanceGradient;

  const AppThemePreset({
    required this.id,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.darkBackground,
    required this.darkSurface,
    required this.headerGradient,
    required this.balanceGradient,
  });

  ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        scaffold: background,
        surfaceColor: surface,
        onSurface: AppColors.onSurface,
      );

  ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        scaffold: darkBackground,
        surfaceColor: darkSurface,
        onSurface: const Color(0xFFF1F5F9),
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surfaceColor,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryLight,
              secondary: primary,
              surface: surfaceColor,
              onSurface: onSurface,
              onPrimary: AppColors.onPrimary,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primaryLight,
              surface: surfaceColor,
              onPrimary: AppColors.onPrimary,
              onSurface: onSurface,
            ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: onSurface, letterSpacing: -0.3),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? primaryLight : primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.45), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? primaryLight : primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class AppThemePresets {
  AppThemePresets._();

  static const AppThemePreset defaultPreset = AppThemePreset(
    id: 'theme_default',
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    background: AppColors.background,
    surface: AppColors.surface,
    darkBackground: AppColors.darkBackground,
    darkSurface: AppColors.darkSurface,
    headerGradient: AppColors.headerGradient,
    balanceGradient: AppColors.heroGradient,
  );

  static const AppThemePreset sunset = AppThemePreset(
    id: 'theme_sunset',
    primary: Color(0xFFE17055),
    primaryLight: Color(0xFFFF7675),
    background: Color(0xFFFFF5F3),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF2D1B1B),
    darkSurface: Color(0xFF4A2C2C),
    headerGradient: LinearGradient(colors: [Color(0xFFD63031), Color(0xFFE17055), Color(0xFFFF7675)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFE17055), Color(0xFFFF7675)]),
  );

  static const AppThemePreset midnight = AppThemePreset(
    id: 'theme_midnight',
    primary: Color(0xFF0984E3),
    primaryLight: Color(0xFF74B9FF),
    background: Color(0xFFF0F8FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0C1B2A),
    darkSurface: Color(0xFF1A2F45),
    headerGradient: LinearGradient(colors: [Color(0xFF0652DD), Color(0xFF0984E3), Color(0xFF74B9FF)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF0984E3), Color(0xFF74B9FF)]),
  );

  static const AppThemePreset neon = AppThemePreset(
    id: 'theme_neon',
    primary: Color(0xFF6C5CE7),
    primaryLight: Color(0xFFA29BFE),
    background: Color(0xFFF8F7FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF1A1A2E),
    darkSurface: Color(0xFF252542),
    headerGradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFFD79A8), Color(0xFFFF7675)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFFD79A8)]),
  );

  static const AppThemePreset ocean = AppThemePreset(
    id: 'theme_ocean',
    primary: Color(0xFF00B894),
    primaryLight: Color(0xFF55EFC4),
    background: Color(0xFFF0FFF8),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0D2818),
    darkSurface: Color(0xFF1A3D2A),
    headerGradient: LinearGradient(colors: [Color(0xFF00A085), Color(0xFF00B894), Color(0xFF55EFC4)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF00B894), Color(0xFF55EFC4)]),
  );

  static const Map<String, AppThemePreset> byId = {
    'theme_default': defaultPreset,
    'theme_sunset': sunset,
    'theme_midnight': midnight,
    'theme_neon': neon,
    'theme_ocean': ocean,
  };

  static AppThemePreset get(String? id) => byId[id] ?? defaultPreset;
}

class DeviceBackground {
  final String id;
  final LinearGradient gradient;

  const DeviceBackground({required this.id, required this.gradient});

  static const DeviceBackground defaultBg = DeviceBackground(
    id: 'bg_default',
    gradient: AppColors.heroGradient,
  );

  static const DeviceBackground sunrise = DeviceBackground(
    id: 'bg_sunrise',
    gradient: LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D)]),
  );

  static const DeviceBackground aurora = DeviceBackground(
    id: 'bg_aurora',
    gradient: LinearGradient(colors: [Color(0xFF6C3CE0), Color(0xFF00B894), Color(0xFF74B9FF)]),
  );

  static const DeviceBackground galaxy = DeviceBackground(
    id: 'bg_galaxy',
    gradient: LinearGradient(colors: [Color(0xFF2D1B69), Color(0xFF6C3CE0), Color(0xFF11998E)]),
  );

  static const DeviceBackground fire = DeviceBackground(
    id: 'bg_fire',
    gradient: LinearGradient(colors: [Color(0xFFFF416C), Color(0xFFFF4B2B), Color(0xFFFFD93D)]),
  );

  static const Map<String, DeviceBackground> byId = {
    'bg_default': defaultBg,
    'bg_sunrise': sunrise,
    'bg_aurora': aurora,
    'bg_galaxy': galaxy,
    'bg_fire': fire,
  };

  static DeviceBackground get(String? id) => byId[id] ?? defaultBg;
}

class DeviceCardSkin {
  final String id;
  final double borderRadius;
  final double blur;
  final Color? overlayColor;
  final bool showBorder;
  final double elevation;

  const DeviceCardSkin({
    required this.id,
    this.borderRadius = 24,
    this.blur = 0,
    this.overlayColor,
    this.showBorder = false,
    this.elevation = 4,
  });

  static const DeviceCardSkin defaultSkin = DeviceCardSkin(id: 'skin_default');

  static const DeviceCardSkin glass = DeviceCardSkin(
    id: 'skin_glass',
    borderRadius: 28,
    blur: 12,
    overlayColor: Color(0x33FFFFFF),
    showBorder: true,
    elevation: 0,
  );

  static const DeviceCardSkin minimal = DeviceCardSkin(
    id: 'skin_minimal',
    borderRadius: 8,
    elevation: 0,
  );

  static const DeviceCardSkin bold = DeviceCardSkin(
    id: 'skin_bold',
    borderRadius: 32,
    showBorder: true,
    elevation: 8,
  );

  static const Map<String, DeviceCardSkin> byId = {
    'skin_default': defaultSkin,
    'skin_glass': glass,
    'skin_minimal': minimal,
    'skin_bold': bold,
  };

  static DeviceCardSkin get(String? id) => byId[id] ?? defaultSkin;
}
