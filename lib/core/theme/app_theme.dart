import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Global Colors
  static const Color primary = Color(0xFF1A237E); // Deep Navy
  static const Color primaryDark = Color(0xFF000051); 
  static const Color primaryLight = Color(0xFF534BAE); 
  static const Color accent = Color(0xFF2979FF); // Bright Blue
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF0F4FF);
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFF6D00);
  
  static const Color textTitle = Color(0xFF1D2939);
  static const Color textBody = Color(0xFF6B7280);

  // Global Shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withAlpha(20),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Theme Data
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();
    
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
        error: warning,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
        displayMedium: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
        displaySmall: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        labelMedium: baseTextTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        labelSmall: baseTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textTitle),
        titleTextStyle: TextStyle(
          color: textTitle,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
