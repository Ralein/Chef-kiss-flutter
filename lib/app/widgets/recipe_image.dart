import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../core/media/local_image_store.dart';

extension ScrapbookThemeAccent on ScrapbookTheme {
  /// Per-recipe accent so each keepsake page keeps its own personality.
  Color accent(ChefColors c) => switch (this) {
        ScrapbookTheme.terracottaClassic => c.accentTomato,
        ScrapbookTheme.matchaSage => c.accentHerb,
        ScrapbookTheme.artisanKraft => c.isDark ? const Color(0xFFC9A57E) : const Color(0xFF8C6B47),
        ScrapbookTheme.nordicSlate => c.isDark ? const Color(0xFF8FB0C4) : const Color(0xFF4F6D7A),
      };

  String get label => switch (this) {
        ScrapbookTheme.terracottaClassic => 'Terracotta',
        ScrapbookTheme.matchaSage => 'Matcha sage',
        ScrapbookTheme.artisanKraft => 'Artisan kraft',
        ScrapbookTheme.nordicSlate => 'Nordic slate',
      };
}

/// Renders a recipe/scan image from any supported source:
/// bundled asset path, `http(s)` URL, or a local file path. Falls back to a
/// themed placeholder when there is no image or it fails to load.
class RecipeImage extends StatelessWidget {
  final String? source;
  final ScrapbookTheme theme;
  final IconData placeholderIcon;
  final BoxFit fit;
  final String? semanticLabel;

  const RecipeImage({
    super.key,
    required this.source,
    this.theme = ScrapbookTheme.terracottaClassic,
    this.placeholderIcon = Icons.restaurant_menu_rounded,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final src = source;
    Widget placeholder(BuildContext context) => _Placeholder(theme: theme, icon: placeholderIcon);
    Widget onError(BuildContext context, Object _, StackTrace? __) => placeholder(context);

    if (src == null || src.isEmpty) return placeholder(context);

    final Widget image;
    if (src.startsWith('http://') || src.startsWith('https://')) {
      image = Image.network(
        src,
        fit: fit,
        errorBuilder: onError,
        loadingBuilder: (context, child, progress) => progress == null ? child : placeholder(context),
      );
    } else if (src.startsWith('assets/')) {
      image = Image.asset(src, fit: fit, errorBuilder: onError);
    } else {
      final provider = localImageProvider(src);
      if (provider == null) return placeholder(context);
      image = Image(image: provider, fit: fit, errorBuilder: onError);
    }
    return Semantics(image: true, label: semanticLabel, child: SizedBox.expand(child: image));
  }
}

class _Placeholder extends StatelessWidget {
  final ScrapbookTheme theme;
  final IconData icon;
  const _Placeholder({required this.theme, required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final accent = theme.accent(c);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.meterTrack(accent), Color.alphaBlend(accent.withValues(alpha: 0.28), c.surfacePaper)],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 44, color: accent.withValues(alpha: 0.85)),
      ),
    );
  }
}
