import 'package:flutter/material.dart';
import 'chef_colors.dart';

class ChefTypography {
  /// Complete Material 3 type scale. Every role is defined so no widget falls
  /// back to framework defaults (which would ignore the brand ink colors).
  static TextTheme createTextTheme(ChefColors colors) {
    TextStyle s(double size, FontWeight weight, {double? height, double letterSpacing = 0, Color? color}) =>
        TextStyle(
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing,
          color: color ?? colors.contentPrimary,
        );

    return TextTheme(
      // displayLarge is the "hero figure" size (≥ 48px, proportional figures).
      displayLarge: s(52, FontWeight.w700, height: 1.05, letterSpacing: -1.2),
      displayMedium: s(36, FontWeight.w700, height: 1.12, letterSpacing: -0.6),
      displaySmall: s(28, FontWeight.w700, height: 1.18, letterSpacing: -0.4),
      headlineLarge: s(26, FontWeight.w700, height: 1.2, letterSpacing: -0.4),
      headlineMedium: s(22, FontWeight.w700, height: 1.25, letterSpacing: -0.2),
      headlineSmall: s(20, FontWeight.w700, height: 1.3, letterSpacing: -0.2),
      titleLarge: s(18, FontWeight.w700, height: 1.3, letterSpacing: -0.1),
      titleMedium: s(16, FontWeight.w600, height: 1.35),
      titleSmall: s(14, FontWeight.w600, height: 1.35),
      bodyLarge: s(16, FontWeight.w400, height: 1.5),
      bodyMedium: s(14, FontWeight.w400, height: 1.45),
      bodySmall: s(12.5, FontWeight.w400, height: 1.4, color: colors.contentSecondary),
      labelLarge: s(14, FontWeight.w600, letterSpacing: 0.1),
      labelMedium: s(12, FontWeight.w600, letterSpacing: 0.2),
      labelSmall: s(11, FontWeight.w600, letterSpacing: 0.4, color: colors.contentSecondary),
    );
  }

  /// Tabular figures for values that must align or tick (timers, columns).
  static TextStyle numeric(Color color, {double size = 18.0, FontWeight weight = FontWeight.w600}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: color,
    );
  }
}
