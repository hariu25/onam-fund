import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final malayalamTextTheme = GoogleFonts.notoSansMalayalamTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.notoSansMalayalam(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.notoSansMalayalam(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.notoSansMalayalam(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.notoSansMalayalam(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.notoSansMalayalam(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.notoSansMalayalam(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.notoSansMalayalam().fontFamily,
      fontFamilyFallback: const ['Noto Sans Malayalam', 'sans-serif'],
      primaryColor: AppColors.primaryDarkGreen,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDarkGreen,
        primary: AppColors.primaryDarkGreen,
        secondary: AppColors.primaryGold,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
      ),
      textTheme: malayalamTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansMalayalam(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkGreen,
          foregroundColor: AppColors.primaryGold,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.notoSansMalayalam(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDarkGreen,
          side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.notoSansMalayalam(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.primaryDarkGreen,
        elevation: 3,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.notoSansMalayalam(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.notoSansMalayalam(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


