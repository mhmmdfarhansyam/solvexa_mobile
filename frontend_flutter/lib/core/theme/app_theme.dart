import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class SolvexaTheme {
  SolvexaTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SolvexaColors.background,
      primaryColor: SolvexaColors.primaryNavy,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SolvexaColors.primaryNavy,
        primary: SolvexaColors.primaryNavy,
        secondary: SolvexaColors.accentAmber,
        surface: SolvexaColors.surface,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: SolvexaColors.textHeading,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: SolvexaColors.textHeading,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: SolvexaColors.textHeading,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: SolvexaColors.textSub,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: SolvexaColors.textSub,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SolvexaColors.surface,
        foregroundColor: SolvexaColors.textHeading,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SolvexaColors.primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}
