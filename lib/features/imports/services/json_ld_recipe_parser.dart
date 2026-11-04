import 'dart:convert';

import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';

import '../../../core/media/recipe_art.dart';

/// Parses schema.org `Recipe` data embedded in web pages (JSON-LD), which
/// almost every recipe site publishes for search engines. Deterministic, free
/// and offline-capable, so it is always tried before any AI fallback.
class JsonLdRecipeParser {
  final RecipeNormalizer _normalizer;
  final Uuid _uuid;

  JsonLdRecipeParser({Uuid uuid = const Uuid()})
      : _uuid = uuid,
        _normalizer = RecipeNormalizer(idGenerator: uuid.v4);

  static final _scriptBlock = RegExp(
    r'''<script[^>]*type\s*=\s*["']application/ld\+json["'][^>]*>([\s\S]*?)</script>''',
    caseSensitive: false,
  );

  /// Finds the first Recipe object in [input], which may be raw JSON-LD or a
  /// whole HTML document with several `ld+json` blocks.
  Recipe? parse(String input, {required String profileId, String? sourceUrl}) {
    final candidates = <String>[
      ..._scriptBlock.allMatches(input).map((m) => m.group(1)!.trim()),
      if (!input.contains('<script')) input.trim(),
    ];
    for (final block in candidates) {
      final Object? decoded;
      try {
        decoded = jsonDecode(block);
      } catch (_) {
        continue;
      }
      final recipeMap = _findRecipe(decoded);
      if (recipeMap != null) return _toRecipe(recipeMap, profileId: profileId, sourceUrl: sourceUrl);
    }
    return null;
  }

  static Map<String, dynamic>? _findRecipe(Object? node) {
    if (node is List) {
      for (final item in node) {
        final found = _findRecipe(item);
        if (found != null) return found;
      }
    } else if (node is Map<String, dynamic>) {
      final type = node['@type'];
      final isRecipe = type == 'Recipe' || (type is List && type.contains('Recipe'));
      if (isRecipe) return node;
      if (node['@graph'] != null) return _findRecipe(node['@graph']);
    }
    return null;
  }

  Recipe _toRecipe(Map<String, dynamic> map, {required String profileId, String? sourceUrl}) {
    final recipeId = _uuid.v4();
    final title = decodeEntities(_text(map['name'])).trim();

    final ingredients = <RecipeIngredient>[];
    for (final raw in _asList(map['recipeIngredient'] ?? map['ingredients'])) {
      final line = decodeEntities(_text(raw)).trim();
      if (line.isEmpty) continue;
      final ing = _normalizer.normalizeIngredient(line, recipeId: recipeId, position: ingredients.length + 1);
      ingredients.add(ing.copyWith(icon: RecipeArt.iconKeyFor(ing.displayName)));
    }

    final stepTexts = <String>[];
    void collectSteps(Object? node) {
      if (node is String) {
        stepTexts.addAll(node.split(RegExp(r'\n+')).map((l) => l.trim()).where((l) => l.isNotEmpty));
      } else if (node is List) {
        node.forEach(collectSteps);
      } else if (node is Map) {
        if (node['itemListElement'] != null) {
          collectSteps(node['itemListElement']); // HowToSection
        } else if (node['text'] != null) {
          collectSteps(node['text']);
        } else if (node['name'] != null) {
          collectSteps(node['name']);
        }
      }
    }

    collectSteps(map['recipeInstructions']);
    final steps = <RecipeStep>[];
    for (final text in stepTexts) {
      final clean = decodeEntities(stripTags(text)).trim();
      if (clean.isEmpty) continue;
      steps.add(_normalizer.normalizeStep(clean, recipeId: recipeId, position: steps.length + 1));
    }

    final labels = <RecipeLabel>[];
    for (final cuisine in _asList(map['recipeCuisine']).map(_text).where((c) => c.trim().isNotEmpty).take(2)) {
      final key = cuisine.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      labels.add(RecipeLabel(
        id: _uuid.v4(),
        recipeId: recipeId,
        labelId: 'cuisine:$key',
        kind: 'cuisine',
        canonicalKey: key,
        displayName: decodeEntities(cuisine.trim()),
      ));
    }

    final image = _imageUrl(map['image']);
    final minutes = parseIsoDurationMinutes(_text(map['totalTime'])) ??
        _sumNullable(parseIsoDurationMinutes(_text(map['prepTime'])), parseIsoDurationMinutes(_text(map['cookTime'])));
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final resolvedTitle = title.isEmpty ? 'Imported recipe' : title;

    return Recipe(
      id: recipeId,
      profileId: profileId,
      title: resolvedTitle,
      summary: _nullIfEmpty(decodeEntities(stripTags(_text(map['description']))).trim()),
      status: RecipeStatus.draft,
      baseServings: _servings(map['recipeYield']),
      totalMinutes: minutes ?? 0,
      createdAt: now,
      updatedAt: now,
      origin: Origin.imported,
      coverImage: image ?? RecipeArt.coverFor(resolvedTitle, ingredients.map((i) => i.displayName)),
      polaroidCaption: resolvedTitle,
      ingredients: ingredients,
      steps: steps,
      labels: labels,
      notes: sourceUrl == null
          ? const []
          : [RecipeNote(id: _uuid.v4(), recipeId: recipeId, body: 'Source: $sourceUrl', noteType: 'source', position: 1)],
    );
  }

  static Rational _servings(Object? raw) {
    final text = _asList(raw).map(_text).join(' ');
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(text);
    final value = match == null ? null : double.tryParse(match.group(0)!);
    if (value == null || value <= 0 || value > 200) return Rational(2);
    return Rational.fromDouble(value, 0.01);
  }

  static String? _imageUrl(Object? raw) {
    if (raw is String && raw.startsWith('http')) return raw;
    if (raw is List && raw.isNotEmpty) return _imageUrl(raw.first);
    if (raw is Map) return _imageUrl(raw['url'] ?? raw['contentUrl']);
    return null;
  }

  /// Minutes in an ISO-8601 duration such as `PT1H30M` or `P0DT45M`.
  static int? parseIsoDurationMinutes(String raw) {
    final m = RegExp(r'^P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?$', caseSensitive: false)
        .firstMatch(raw.trim());
    if (m == null || raw.trim() == 'P' || raw.trim() == 'PT') return null;
    int v(int g) => int.tryParse(m.group(g) ?? '') ?? 0;
    final total = v(1) * 1440 + v(2) * 60 + v(3) + (v(4) >= 30 ? 1 : 0);
    return total > 0 ? total : null;
  }

  static int? _sumNullable(int? a, int? b) => (a == null && b == null) ? null : (a ?? 0) + (b ?? 0);
  static String? _nullIfEmpty(String s) => s.isEmpty ? null : s;
  static List<dynamic> _asList(Object? v) => v == null ? const [] : (v is List ? v : [v]);
  static String _text(Object? v) => v == null ? '' : (v is String ? v : (v is Map ? '${v['name'] ?? v['text'] ?? ''}' : '$v'));

  static String stripTags(String html) => html.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'[ \t]+'), ' ');

  static const _entities = {
    '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"', '&apos;': "'", '&nbsp;': ' ', '&frac12;': '½',
    '&frac14;': '¼', '&frac34;': '¾', '&deg;': '°', '&ndash;': '–', '&mdash;': '—', '&hellip;': '…',
    '&rsquo;': '’', '&lsquo;': '‘', '&ldquo;': '“', '&rdquo;': '”',
  };

  static String decodeEntities(String s) {
    var out = s.replaceAllMapped(RegExp(r'&#(x?)([0-9a-fA-F]+);'), (m) {
      final code = int.tryParse(m.group(2)!, radix: m.group(1)!.isEmpty ? 10 : 16);
      return code == null ? m.group(0)! : String.fromCharCode(code);
    });
    _entities.forEach((k, v) => out = out.replaceAll(k, v));
    return out;
  }

  /// Readable text of an HTML page for the AI fallback: drops scripts,
  /// styles and markup, keeps line structure.
  static String htmlToText(String html) {
    var s = html
        .replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ')
        .replaceAll(RegExp(r'<(script|style|noscript|svg|iframe|template)[^>]*>[\s\S]*?</\1>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<(br|/p|/div|/li|/h[1-6]|/tr|/section|/article)[^>]*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ');
    s = decodeEntities(stripTags(s));
    return s
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .join('\n');
  }
}
