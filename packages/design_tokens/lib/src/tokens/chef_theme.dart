import 'package:flutter/material.dart';
import 'chef_colors.dart';
import 'chef_typography.dart';
import 'chef_spacing.dart';

class ChefTheme {
  static ThemeData light() => _buildTheme(ChefColors.light, Brightness.light);
  static ThemeData dark() => _buildTheme(ChefColors.dark, Brightness.dark);
  static ThemeData highContrast() => _buildTheme(ChefColors.highContrast, Brightness.dark);

  static ThemeData _buildTheme(ChefColors colors, Brightness brightness) {
    final textTheme = ChefTypography.createTextTheme(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.surfaceCanvas,
      canvasColor: colors.surfaceCanvas,
      cardColor: colors.surfacePaper,
      dividerColor: colors.outlineSubtle,
      textTheme: textTheme,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accentTomato,
        onPrimary: colors.contentInverse,
        secondary: colors.accentHerb,
        onSecondary: colors.contentInverse,
        tertiary: colors.accentYolk,
        onTertiary: colors.contentPrimary,
        error: colors.stateDanger,
        onError: colors.contentInverse,
        surface: colors.surfacePaper,
        onSurface: colors.contentPrimary,
        outline: colors.outlineSubtle,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfaceCanvas,
        foregroundColor: colors.contentPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: colors.surfacePaper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChefRadius.card),
          side: BorderSide(color: colors.outlineSubtle, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfacePaper,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChefRadius.card),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: ChefRadius.sheetBorder,
        ),
      ),
      extensions: [colors],
    );
  }
}

extension ChefThemeContext on BuildContext {
  ChefColors get chefColors {
    return Theme.of(this).extension<ChefColors>() ??
        (Theme.of(this).brightness == Brightness.dark ? ChefColors.dark : ChefColors.light);
  }

  TextTheme get chefText => Theme.of(this).textTheme;
}
