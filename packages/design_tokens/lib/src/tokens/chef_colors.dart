import 'package:flutter/material.dart';

@immutable
class ChefColors extends ThemeExtension<ChefColors> {
  final Color surfaceCanvas;
  final Color surfacePaper;
  final Color surfaceRaised;

  final Color contentPrimary;
  final Color contentSecondary;
  final Color contentInverse;

  final Color accentTomato;
  final Color accentHerb;
  final Color accentYolk;

  final Color stateWarning;
  final Color stateDanger;
  final Color stateSuccess;
  final Color outlineSubtle;
  final Color focusRing;

  const ChefColors({
    required this.surfaceCanvas,
    required this.surfacePaper,
    required this.surfaceRaised,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentInverse,
    required this.accentTomato,
    required this.accentHerb,
    required this.accentYolk,
    required this.stateWarning,
    required this.stateDanger,
    required this.stateSuccess,
    required this.outlineSubtle,
    required this.focusRing,
  });

  static const light = ChefColors(
    surfaceCanvas: Color(0xFFFAF7F2),
    surfacePaper: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF3EDE4),
    contentPrimary: Color(0xFF1E1A18),
    contentSecondary: Color(0xFF6B625B),
    contentInverse: Color(0xFFFFFFFF),
    accentTomato: Color(0xFFC2552F), // terracotta, 4.5:1 on white
    accentHerb: Color(0xFF4A6B53), // sage, 6.0:1 on white
    accentYolk: Color(0xFFD9922B),
    stateWarning: Color(0xFFB86A12),
    stateDanger: Color(0xFFC0392B),
    stateSuccess: Color(0xFF2E7D4A),
    outlineSubtle: Color(0xFFE8E0D2),
    focusRing: Color(0xFFC2552F),
  );

  static const dark = ChefColors(
    surfaceCanvas: Color(0xFF161412),
    surfacePaper: Color(0xFF201D1A),
    surfaceRaised: Color(0xFF2B2724),
    contentPrimary: Color(0xFFF5F0EA),
    contentSecondary: Color(0xFFB3A99E),
    contentInverse: Color(0xFF1A1816),
    accentTomato: Color(0xFFE57A55),
    accentHerb: Color(0xFF7FA98A),
    accentYolk: Color(0xFFF2B84B),
    stateWarning: Color(0xFFEAA036),
    stateDanger: Color(0xFFEF6A5B),
    stateSuccess: Color(0xFF5DBB7A),
    outlineSubtle: Color(0xFF3A3430),
    focusRing: Color(0xFFE57A55),
  );

  static const highContrast = ChefColors(
    surfaceCanvas: Color(0xFF000000),
    surfacePaper: Color(0xFF121212),
    surfaceRaised: Color(0xFF222222),
    contentPrimary: Color(0xFFFFFFFF),
    contentSecondary: Color(0xFFDDDDDD),
    contentInverse: Color(0xFF000000),
    accentTomato: Color(0xFFFF523B),
    accentHerb: Color(0xFF59C58B),
    accentYolk: Color(0xFFFFC043),
    stateWarning: Color(0xFFFF9800),
    stateDanger: Color(0xFFFF3D00),
    stateSuccess: Color(0xFF00E676),
    outlineSubtle: Color(0xFF666666),
    focusRing: Color(0xFF00E5FF),
  );

  bool get isDark => surfaceCanvas.computeLuminance() < 0.2;

  /// Foreground for content placed on a filled accent (button labels, badges).
  Color get onAccent => contentInverse;

  Color _soft(Color accent) => Color.alphaBlend(accent.withValues(alpha: isDark ? 0.22 : 0.12), surfacePaper);

  /// Tinted container backgrounds that work in light and dark themes.
  Color get tomatoSoft => _soft(accentTomato);
  Color get herbSoft => _soft(accentHerb);
  Color get yolkSoft => _soft(accentYolk);
  Color get dangerSoft => _soft(stateDanger);

  // --- Data visualization --------------------------------------------------
  //
  // Categorical macro palette, validated with the dataviz six-checks script
  // (OKLab ΔE, Machado 2009 CVD simulation) against surfacePaper:
  //   light #C2552F · #3F72A8 · #2E8B57 — worst adjacent CVD ΔE 14.9, normal 16.7
  //   dark  #E0703F · #5C8FD6 · #33A86E — worst adjacent CVD ΔE 16.8, normal 19.6
  // All-pairs protein↔fat sits in the 6–8 CVD band, so these colors are only
  // ever used with a text label beside them and in protein | carbs | fat order.
  // Brand sage/yolk were rejected: sage reads as gray (chroma 0.05) and yolk
  // is 2.6:1 on white.

  Color get macroProtein => isDark ? const Color(0xFFE0703F) : const Color(0xFFC2552F);
  Color get macroCarbs => isDark ? const Color(0xFF5C8FD6) : const Color(0xFF3F72A8);
  Color get macroFat => isDark ? const Color(0xFF33A86E) : const Color(0xFF2E8B57);

  /// Slot-1 color for single-series charts (e.g. daily calories).
  Color get chartPrimary => macroProtein;

  /// Meter track: a lighter step of the fill's own hue.
  Color meterTrack(Color fill) => Color.alphaBlend(fill.withValues(alpha: isDark ? 0.26 : 0.16), surfacePaper);

  @override
  ChefColors copyWith({
    Color? surfaceCanvas,
    Color? surfacePaper,
    Color? surfaceRaised,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentInverse,
    Color? accentTomato,
    Color? accentHerb,
    Color? accentYolk,
    Color? stateWarning,
    Color? stateDanger,
    Color? stateSuccess,
    Color? outlineSubtle,
    Color? focusRing,
  }) {
    return ChefColors(
      surfaceCanvas: surfaceCanvas ?? this.surfaceCanvas,
      surfacePaper: surfacePaper ?? this.surfacePaper,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentInverse: contentInverse ?? this.contentInverse,
      accentTomato: accentTomato ?? this.accentTomato,
      accentHerb: accentHerb ?? this.accentHerb,
      accentYolk: accentYolk ?? this.accentYolk,
      stateWarning: stateWarning ?? this.stateWarning,
      stateDanger: stateDanger ?? this.stateDanger,
      stateSuccess: stateSuccess ?? this.stateSuccess,
      outlineSubtle: outlineSubtle ?? this.outlineSubtle,
      focusRing: focusRing ?? this.focusRing,
    );
  }

  @override
  ChefColors lerp(ThemeExtension<ChefColors>? other, double t) {
    if (other is! ChefColors) return this;
    return ChefColors(
      surfaceCanvas: Color.lerp(surfaceCanvas, other.surfaceCanvas, t)!,
      surfacePaper: Color.lerp(surfacePaper, other.surfacePaper, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      contentPrimary: Color.lerp(contentPrimary, other.contentPrimary, t)!,
      contentSecondary: Color.lerp(contentSecondary, other.contentSecondary, t)!,
      contentInverse: Color.lerp(contentInverse, other.contentInverse, t)!,
      accentTomato: Color.lerp(accentTomato, other.accentTomato, t)!,
      accentHerb: Color.lerp(accentHerb, other.accentHerb, t)!,
      accentYolk: Color.lerp(accentYolk, other.accentYolk, t)!,
      stateWarning: Color.lerp(stateWarning, other.stateWarning, t)!,
      stateDanger: Color.lerp(stateDanger, other.stateDanger, t)!,
      stateSuccess: Color.lerp(stateSuccess, other.stateSuccess, t)!,
      outlineSubtle: Color.lerp(outlineSubtle, other.outlineSubtle, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
    );
  }
}
