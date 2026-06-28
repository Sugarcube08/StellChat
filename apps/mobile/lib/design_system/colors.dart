import 'package:flutter/material.dart';
import '../core/theme/stell_theme.dart';

class AppColors {
  static StellColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<StellColorsExtension>()!;
  }

  // Brand-Specific Colors
  static const Color backgroundPrimary = Color(0xFF090B12);
  static const Color backgroundSecondary = Color(0xFF10131C);
  static const Color surfacePrimary = Color(0xFF10131C);
  static const Color surfaceSecondary = Color(0xFF151A24); // Card
  static const Color borderPrimary = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const Color borderMuted = Color(0x0AFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAEB7C6);
  static const Color textMuted = Color(0xFF70798B);
  static const Color success = Color(0xFF00D68F);
  static const Color warning = Color(0xFFF5A524);
  static const Color error = Color(0xFFFF5C7A); // Danger
  static const Color info = Color(0xFF35B7FF); // Highlight Blue
  static const Color accent = Color(0xFF6C4DFF); // Primary Accent
  static const Color accentSecondary = Color(0xFF8D6BFF); // Secondary Accent

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF5B3DF5),
    Color(0xFF7C5CFF),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF2AAEFF),
    Color(0xFF6D5DFF),
  ];
  static const List<Color> successGradient = [
    Color(0xFF00D68F),
    Color(0xFF3BE6A5),
  ];

  // Legacy constants for backward compatibility
  static const Color primaryBackground = backgroundPrimary;
  static const Color secondaryBackground = backgroundSecondary;
  static const Color elevatedSurface = surfacePrimary;
  static const Color hairline = borderPrimary;
  static const Color primaryText = textPrimary;
  static const Color secondaryText = textSecondary;
  static const Color stellAccent = accent;
}
