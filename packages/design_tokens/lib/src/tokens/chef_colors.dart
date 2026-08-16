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
    surfaceRaised: Color(0xFFF4EFE6),
    contentPrimary: Color(0xFF211D19),
    contentSecondary: Color(0xFF686057),
    contentInverse: Color(0xFFFFFFFF),
    accentTomato: Color(0xFFD94B34),
    accentHerb: Color(0xFF3D7A5A),
    accentYolk: Color(0xFFE5A124),
    stateWarning: Color(0xFFD47A1E),
    stateDanger: Color(0xFFC7382B),
    stateSuccess: Color(0xFF2E8540),
    outlineSubtle: Color(0xFFE4DDD3),
    focusRing: Color(0xFFD94B34),
  );

  static const dark = ChefColors(
    surfaceCanvas: Color(0xFF161514),
    surfacePaper: Color(0xFF201E1C),
    surfaceRaised: Color(0xFF2A2724),
    contentPrimary: Color(0xFFF5F2ED),
    contentSecondary: Color(0xFFABA196),
    contentInverse: Color(0xFF1A1816),
    accentTomato: Color(0xFFE8634D),
    accentHerb: Color(0xFF529972),
    accentYolk: Color(0xFFF2B84B),
    stateWarning: Color(0xFFEAA036),
    stateDanger: Color(0xFFE05345),
    stateSuccess: Color(0xFF44A95B),
    outlineSubtle: Color(0xFF383430),
    focusRing: Color(0xFFE8634D),
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
