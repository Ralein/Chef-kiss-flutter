import 'package:flutter/material.dart';
import 'chef_colors.dart';

class ChefTypography {
  static TextTheme createTextTheme(ChefColors colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: colors.contentPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
        color: colors.contentPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: colors.contentPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: colors.contentPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: colors.contentPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: colors.contentPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: colors.contentSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: colors.contentPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: colors.contentSecondary,
      ),
    );
  }

  /// Numeric tabular style for timer countdowns and servings
  static TextStyle numeric(Color color, {double size = 18.0, FontWeight weight = FontWeight.w600}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: color,
    );
  }
}
