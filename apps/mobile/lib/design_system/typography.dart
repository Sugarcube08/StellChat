import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static const String fontFamily = 'Poppins';
  static const String fallbackFontFamily = 'Inter';

  static TextStyle hero(BuildContext context) => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.of(context).textPrimary,
  );

  static TextStyle title(BuildContext context) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.of(context).textPrimary,
  );

  static TextStyle header(BuildContext context) => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.of(context).textPrimary,
  );

  static TextStyle section(BuildContext context) => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.of(context).textPrimary,
  );

  static TextStyle body(BuildContext context) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.of(context).textPrimary,
  );

  static TextStyle secondary(BuildContext context) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.of(context).textSecondary,
  );

  static TextStyle caption(BuildContext context) => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.of(context).textMuted,
  );
}
