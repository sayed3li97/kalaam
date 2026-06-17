import 'package:flutter/material.dart';

abstract final class KalaamColors {
  static const surface = Color(0xFF0D0F14);
  static const surfaceVar = Color(0xFF161A22);
  static const surfaceTrim = Color(0xFF1E2330);
  static const primary = Color(0xFFC9943A);
  static const primaryDim = Color(0xFF8A6220);
  // Brightened from #3A7D8C for legible contrast on the dark surface (the old
  // teal failed WCAG AA for small text/icons).
  static const secondary = Color(0xFF5AA6B5);
  static const onPrimary = Color(0xFF0D0F14);
  static const onSurface = Color(0xFFEAE6DC);
  static const onSurfaceDim = Color(0xFF9B9590);
  static const error = Color(0xFFE05A5A);
  static const success = Color(0xFF4CAF7D);
}

abstract final class KalaamTheme {
  /// Bundled Arabic-capable families used as a glyph fallback for every text
  /// style, so Arabic always renders even in the Latin/mono faces.
  static const List<String> _arabicFallback = ['IBMPlexSansArabic', 'Amiri'];

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: KalaamColors.surface,
    colorScheme: const ColorScheme.dark(
      surface: KalaamColors.surface,
      surfaceContainerHighest: KalaamColors.surfaceVar,
      primary: KalaamColors.primary,
      onPrimary: KalaamColors.onPrimary,
      secondary: KalaamColors.secondary,
      onSurface: KalaamColors.onSurface,
      error: KalaamColors.error,
    ),
    // Every style falls back to a bundled Arabic-capable family, so Arabic
    // glyphs render even inside the Latin/mono faces (e.g. an Arabic word in a
    // monospaced label) instead of showing tofu boxes.
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Amiri',
        fontFamilyFallback: _arabicFallback,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: KalaamColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Amiri',
        fontFamilyFallback: _arabicFallback,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: KalaamColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: _arabicFallback,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: KalaamColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: _arabicFallback,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: KalaamColors.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: _arabicFallback,
        fontSize: 13,
        color: KalaamColors.onSurfaceDim,
      ),
      labelSmall: TextStyle(
        fontFamily: 'IBMPlexMono',
        fontFamilyFallback: _arabicFallback,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: KalaamColors.onSurfaceDim,
      ),
    ),
    cardTheme: const CardThemeData(
      color: KalaamColors.surfaceVar,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: KalaamColors.surfaceTrim,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: KalaamColors.surfaceTrim,
      labelStyle: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 12,
        color: KalaamColors.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );
}
