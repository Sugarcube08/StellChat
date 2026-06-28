import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class BrandTypography {
  static const String fontFamily = 'Poppins';
  static const String fallbackFontFamily = 'Inter';

  static TextStyle hero() => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: BrandColors.textPrimary,
  );

  static TextStyle title() => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: BrandColors.textPrimary,
  );

  static TextStyle header() => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: BrandColors.textPrimary,
  );

  static TextStyle section() => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: BrandColors.textPrimary,
  );

  static TextStyle body() => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: BrandColors.textPrimary,
  );

  static TextStyle secondary() => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: BrandColors.textSecondary,
  );

  static TextStyle caption() => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: BrandColors.textMuted,
  );
}
