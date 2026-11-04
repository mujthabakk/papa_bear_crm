import 'package:flutter/material.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';

abstract final class PbText {
  static TextStyle display(
    double size, {
    Color color = PbColors.ink,
    double weight = 560,
    double height = 1.08,
    double letterSpacing = -0.6,
  }) {
    return TextStyle(
      fontFamily: 'Fraunces',
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: [
        FontVariation('wght', weight),
        FontVariation('opsz', size.clamp(14, 72)),
      ],
    );
  }

  static TextStyle body(
    double size, {
    Color color = PbColors.ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.35,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'Outfit',
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
    );
  }
}

abstract final class PbTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: PbColors.cream,
      splashFactory: InkRipple.splashFactory,
      dividerColor: PbColors.line,
      colorScheme: const ColorScheme.light(
        primary: PbColors.ink,
        onPrimary: PbColors.cream,
        secondary: PbColors.honey,
        onSecondary: PbColors.ink,
        surface: PbColors.paper,
        onSurface: PbColors.ink,
        error: PbColors.clay,
      ),
    );

    return base.copyWith(
      textTheme: TextTheme(
        displayLarge: PbText.display(48),
        displayMedium: PbText.display(36),
        displaySmall: PbText.display(30),
        headlineLarge: PbText.display(28),
        headlineMedium: PbText.display(24),
        headlineSmall: PbText.display(20),
        titleLarge: PbText.display(22),
        titleMedium: PbText.body(16, weight: FontWeight.w600),
        titleSmall: PbText.body(14, weight: FontWeight.w600),
        bodyLarge: PbText.body(16),
        bodyMedium: PbText.body(14),
        bodySmall: PbText.body(12, color: PbColors.inkSoft),
        labelLarge: PbText.body(14, weight: FontWeight.w600),
        labelMedium: PbText.body(12, weight: FontWeight.w600),
        labelSmall: PbText.body(11, weight: FontWeight.w600, letterSpacing: 0.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PbColors.cream,
        foregroundColor: PbColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PbColors.cream,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: PbText.body(14, color: PbColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PbColors.honey, width: 1.5),
        ),
      ),
    );
  }
}
