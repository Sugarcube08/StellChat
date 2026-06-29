import 'package:flutter/material.dart';
import 'colors.dart';

class BrandTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BrandColors.backgroundPrimary,
      primaryColor: BrandColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: BrandColors.accent,
        secondary: BrandColors.accentSecondary,
        surface: BrandColors.backgroundSecondary,
        error: BrandColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BrandColors.backgroundPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      primaryColor: BrandColors.accent,
      colorScheme: const ColorScheme.light(
        primary: BrandColors.accent,
        secondary: BrandColors.accentSecondary,
        surface: Colors.white,
        error: BrandColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
