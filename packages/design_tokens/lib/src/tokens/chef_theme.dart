import 'package:flutter/material.dart';
import 'chef_colors.dart';
import 'chef_typography.dart';
import 'chef_spacing.dart';

class ChefTheme {
  static ThemeData light() => _buildTheme(ChefColors.light, Brightness.light);
  static ThemeData dark() => _buildTheme(ChefColors.dark, Brightness.dark);
  static ThemeData highContrast() => _buildTheme(ChefColors.highContrast, Brightness.dark);

  static ThemeData _buildTheme(ChefColors c, Brightness brightness) {
    final text = ChefTypography.createTextTheme(c);
    final isDark = brightness == Brightness.dark;
    Color blend(Color a, Color b, double t) => Color.lerp(a, b, t)!;
    final outline = isDark ? const Color(0xFF5A524B) : const Color(0xFFCFC5B8);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accentTomato,
      onPrimary: c.onAccent,
      primaryContainer: c.tomatoSoft,
      onPrimaryContainer: c.contentPrimary,
      secondary: c.accentHerb,
      onSecondary: c.onAccent,
      secondaryContainer: c.herbSoft,
      onSecondaryContainer: c.contentPrimary,
      tertiary: c.accentYolk,
      onTertiary: const Color(0xFF1E1A18),
      tertiaryContainer: c.yolkSoft,
      onTertiaryContainer: c.contentPrimary,
      error: c.stateDanger,
      onError: c.onAccent,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.contentPrimary,
      surface: c.surfacePaper,
      onSurface: c.contentPrimary,
      onSurfaceVariant: c.contentSecondary,
      surfaceContainerLowest: isDark ? blend(c.surfaceCanvas, Colors.black, 0.2) : c.surfacePaper,
      surfaceContainerLow: blend(c.surfacePaper, c.surfaceRaised, 0.35),
      surfaceContainer: blend(c.surfacePaper, c.surfaceRaised, 0.6),
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: blend(c.surfaceRaised, c.outlineSubtle, 0.45),
      outline: outline,
      outlineVariant: c.outlineSubtle,
      inverseSurface: c.contentPrimary,
      onInverseSurface: c.surfacePaper,
      inversePrimary: isDark ? const Color(0xFFC2552F) : const Color(0xFFE57A55),
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );

    const pill = StadiumBorder();
    final buttonText = text.labelLarge!.copyWith(fontWeight: FontWeight.w700);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceCanvas,
      canvasColor: c.surfaceCanvas,
      cardColor: c.surfacePaper,
      dividerColor: c.outlineSubtle,
      textTheme: text,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surfaceCanvas,
        foregroundColor: c.contentPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: c.surfacePaper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChefRadius.tile),
          side: BorderSide(color: c.outlineSubtle),
        ),
      ),
      // Colors come from the scheme (primary / secondaryContainer), so both
      // FilledButton and FilledButton.tonal keep their distinct looks.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accentTomato,
          foregroundColor: c.onAccent,
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.contentPrimary,
          side: BorderSide(color: outline),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentTomato,
          minimumSize: const Size(48, 44),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accentTomato,
        foregroundColor: c.onAccent,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        highlightElevation: 4,
        extendedTextStyle: buttonText,
        shape: const StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: text.bodyMedium!.copyWith(color: c.contentSecondary),
        labelStyle: text.bodyMedium!.copyWith(color: c.contentSecondary),
        floatingLabelStyle: text.bodySmall!.copyWith(color: c.accentTomato, fontWeight: FontWeight.w600),
        prefixIconColor: c.contentSecondary,
        suffixIconColor: c.contentSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.outlineSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.accentTomato, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.stateDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.stateDanger, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfacePaper,
        selectedColor: c.tomatoSoft,
        disabledColor: c.surfaceRaised,
        checkmarkColor: c.accentTomato,
        labelStyle: text.labelLarge!.copyWith(fontWeight: FontWeight.w600),
        secondaryLabelStyle: text.labelLarge,
        side: BorderSide(color: c.outlineSubtle),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        iconTheme: IconThemeData(color: c.contentSecondary, size: 18),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfacePaper,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.tomatoSoft,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? c.accentTomato : c.contentSecondary,
              size: 24,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => text.labelMedium!.copyWith(
              color: states.contains(WidgetState.selected) ? c.contentPrimary : c.contentSecondary,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surfaceCanvas,
        indicatorColor: c.tomatoSoft,
        selectedIconTheme: IconThemeData(color: c.accentTomato),
        unselectedIconTheme: IconThemeData(color: c.contentSecondary),
        selectedLabelTextStyle: text.labelLarge!.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: text.labelLarge!.copyWith(color: c.contentSecondary, fontWeight: FontWeight.w500),
        useIndicator: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfacePaper,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.card)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfacePaper,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surfacePaper,
        showDragHandle: true,
        dragHandleColor: outline,
        shape: const RoundedRectangleBorder(borderRadius: ChefRadius.sheetBorder),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfacePaper,
        contentTextStyle: text.bodyMedium,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.contentSecondary,
        titleTextStyle: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: text.bodyMedium!.copyWith(color: c.contentSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: c.outlineSubtle, thickness: 1, space: 1),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.tomatoSoft : c.surfacePaper,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.contentPrimary : c.contentSecondary,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accentTomato : c.contentSecondary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: c.outlineSubtle)),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accentTomato,
        linearTrackColor: c.meterTrack(c.accentTomato),
        circularTrackColor: c.meterTrack(c.accentTomato),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.onAccent : outline),
        trackColor:
            WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accentTomato : c.surfaceRaised),
        trackOutlineColor: WidgetStatePropertyAll(c.outlineSubtle),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accentHerb : null),
        checkColor: WidgetStatePropertyAll(c.onAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accentTomato,
        inactiveTrackColor: c.meterTrack(c.accentTomato),
        thumbColor: c.accentTomato,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.contentPrimary, borderRadius: BorderRadius.circular(8)),
        textStyle: text.bodySmall!.copyWith(color: c.surfacePaper, fontWeight: FontWeight.w600),
        waitDuration: const Duration(milliseconds: 400),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfacePaper,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.outlineSubtle),
        ),
      ),
      badgeTheme: BadgeThemeData(backgroundColor: c.accentTomato, textColor: c.onAccent),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accentTomato,
        selectionColor: c.accentTomato.withValues(alpha: 0.28),
        selectionHandleColor: c.accentTomato,
      ),
      extensions: [c],
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
