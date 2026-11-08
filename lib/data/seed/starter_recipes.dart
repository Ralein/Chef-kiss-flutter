import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../core/media/recipe_art.dart';

/// The bundled starter recipes: classic, tested dishes the welcome tour
/// offers. Nothing reaches the library unless the cook picks it.
const starterRecipesAsset = 'assets/seed/starter_recipes.json';

/// Ids of the sample recipes earlier versions added on first launch. They
/// were placeholders with stock artwork, so they're taken off the shelf.
const retiredStarterIds = ['pasta-pomodoro', 'french-crepes', 'avocado-brioche', 'tokyo-ramen', 'rustic-sourdough'];

Future<List<Recipe>> loadStarterRecipes([AssetBundle? bundle]) async {
  final raw = await (bundle ?? rootBundle).loadString(starterRecipesAsset);
  return parseStarterRecipes(raw);
}

List<Recipe> parseStarterRecipes(String raw) {
  final parsed = jsonDecode(raw);
  if (parsed is! List) return const [];
  return parsed.whereType<Map<String, dynamic>>().map(parseStarterRecipe).toList();
}

/// Builds a [Recipe] from the bundled starter JSON format.
Recipe parseStarterRecipe(Map<String, dynamic> json) {
  final recipeId = json['id'] as String;

  final ingredients = (json['ingredients'] as List<dynamic>? ?? const []).map((i) {
    return RecipeIngredient(
      id: i['id'] as String,
      recipeId: recipeId,
      displayName: i['displayName'] as String,
      quantity: i['quantityNum'] != null ? Rational(i['quantityNum'] as int, i['quantityDen'] as int? ?? 1) : null,
      unitCode: i['unitCode'] as String?,
      authoredQuantity: i['authoredQuantity'] as String?,
      scalingPolicy: ScalingPolicy.fromString(i['scalingPolicy'] as String?),
      prepText: i['prepText'] as String?,
      isOptional: i['isOptional'] as bool? ?? false,
      position: i['position'] as int? ?? 1,
      icon: i['icon'] as String? ?? RecipeArt.iconKeyFor(i['displayName'] as String),
      iconColor: i['iconColor'] as String?,
      x: (i['x'] as num?)?.toDouble(),
      y: (i['y'] as num?)?.toDouble(),
    );
  }).toList();

  final steps = (json['steps'] as List<dynamic>? ?? const []).map((s) {
    final timers = (s['timers'] as List<dynamic>? ?? const []).map((t) {
      return StepTimer(
        id: t['id'] as String,
        recipeStepId: s['id'] as String,
        label: t['label'] as String,
        durationSeconds: t['durationSeconds'] as int,
        position: t['position'] as int? ?? 1,
      );
    }).toList();
    return RecipeStep(
      id: s['id'] as String,
      recipeId: recipeId,
      position: s['position'] as int? ?? 1,
      instructionShort: s['instructionShort'] as String,
      instructionDetail: s['instructionDetail'] as String?,
      actionKey: s['actionKey'] as String?,
      iconKey: s['iconKey'] as String?,
      iconColor: s['iconColor'] as String?,
      cookwareKey: s['cookwareKey'] as String?,
      durationSeconds: s['durationSeconds'] as int?,
      temperatureC: s['temperatureC'] as int?,
      temperatureF: s['temperatureF'] as int?,
      x: (s['x'] as num?)?.toDouble(),
      y: (s['y'] as num?)?.toDouble(),
      timers: timers,
    );
  }).toList();

  final tools = (json['tools'] as List<dynamic>? ?? const []).map((t) {
    return RecipeTool(
      id: t['id'] as String,
      recipeId: recipeId,
      displayName: t['displayName'] as String,
      quantity: t['quantity'] as int? ?? 1,
      position: t['position'] as int? ?? 1,
    );
  }).toList();

  final labels = (json['labels'] as List<dynamic>? ?? const []).map((l) {
    return RecipeLabel(
      id: l['id'] as String,
      recipeId: recipeId,
      labelId: l['labelId'] as String,
      kind: l['kind'] as String,
      canonicalKey: l['canonicalKey'] as String,
      displayName: l['displayName'] as String,
    );
  }).toList();

  final now = DateTime.now().toUtc().millisecondsSinceEpoch;
  return Recipe(
    id: recipeId,
    profileId: json['profileId'] as String? ?? 'default',
    title: json['title'] as String,
    slug: json['slug'] as String?,
    summary: json['summary'] as String?,
    status: RecipeStatus.fromString(json['status'] as String?),
    baseServings: Rational(json['baseServingsNum'] as int? ?? 2, json['baseServingsDen'] as int? ?? 1),
    difficulty: RecipeDifficulty.fromString(json['difficulty'] as String?),
    totalMinutes: json['totalMinutes'] as int? ?? 0,
    visualTemplate: json['visualTemplate'] as String?,
    visualStyleVersion: json['visualStyleVersion'] as String? ?? 'v1',
    isCurated: json['isCurated'] as bool? ?? false,
    origin: Origin.fromString(json['origin'] as String?),
    isFavorite: json['isFavorite'] as bool? ?? false,
    coverImage: json['coverImage'] as String?,
    polaroidCaption: json['polaroidCaption'] as String?,
    polaroidRotation: (json['polaroidRotation'] as num?)?.toDouble(),
    polaroidX: (json['polaroidX'] as num?)?.toDouble(),
    polaroidY: (json['polaroidY'] as num?)?.toDouble(),
    chefTip: json['chefTip'] as String?,
    chefTipIcon: json['chefTipIcon'] as String?,
    chefTipIconColor: json['chefTipIconColor'] as String?,
    theme: ScrapbookTheme.fromKey(json['theme'] as String?),
    moodStamps: (json['moodStamps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    stickers: (json['stickers'] as List<dynamic>?)
            ?.map((e) => ScrapbookSticker.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    washiTapes: (json['washiTapes'] as List<dynamic>?)
            ?.map((e) => WashiTapeDecoration.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    createdAt: now,
    updatedAt: now,
    ingredients: ingredients,
    steps: steps,
    tools: tools,
    labels: labels,
    bookStyle: BookStyle.fromJson(json['bookStyle']),
  );
}
