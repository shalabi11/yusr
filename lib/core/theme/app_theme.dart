import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const base = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.background,
    );

    final uiFontFamily = GoogleFonts.notoNaskhArabic().fontFamily;
    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: base,
      fontFamily: uiFontFamily,
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base,
      textTheme: GoogleFonts.notoNaskhArabicTextTheme(baseTheme.textTheme)
          .apply(
            bodyColor: AppColors.textWhite,
            displayColor: AppColors.textWhite,
          ),
      primaryTextTheme: GoogleFonts.notoNaskhArabicTextTheme(
        baseTheme.primaryTextTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
