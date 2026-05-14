import 'package:flutter/material.dart';

/// Design tokens aligned with the original `css/style.css` (:root variables).
abstract final class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color secondary = Color(0xFFFF8F00);
  static const Color textDark = Color(0xFF263238);
  static const Color textLight = Color(0xFF546E7A);
  static const Color background = Color(0xFFF8FAF8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E7E0);
  static const Color uploadBorder = Color(0xFFCBD5CB);
  static const Color diseaseBg = Color(0xFFFFF3E0);
  static const Color diseaseFg = Color(0xFFE65100);
  static const Color healthyBg = Color(0xFFE8F5E8);
  static const Color surfaceTint = Color(0x1A2E7D32);
}

ThemeData buildCassavaTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary,
    surface: AppColors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: AppColors.textDark,
        side: const BorderSide(color: AppColors.border, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.surfaceTint),
      ),
      color: AppColors.white,
      shadowColor: Colors.black26,
    ),
    fontFamily: 'Roboto',
  );
}

LinearGradient get primaryGradient => const LinearGradient(
  colors: [AppColors.primary, AppColors.primaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
