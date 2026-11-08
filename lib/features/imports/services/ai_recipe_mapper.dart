import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';

import '../../../core/media/recipe_art.dart';

/// Result of turning a structured AI recipe payload into a domain [Recipe].
class AiRecipeDraft {
  final Recipe recipe;
  final List<String> warnings;
  const AiRecipeDraft(this.recipe, this.warnings);
}

/// Pure mapping from the `AiPrompts.recipeSchema` JSON to a [Recipe] draft.
/// Values are re-validated here: the schema guarantees shape, not sanity.
class AiRecipeMapper {
  final Uuid _uuid;
  const AiRecipeMapper({Uuid uuid = const Uuid()}) : _uuid = uuid;

  AiRecipeDraft map(
    Map<String, dynamic> json, {
    required Origin origin,
    String profileId = 'default',
    ScrapbookTheme theme = ScrapbookTheme.terracottaClassic,
    int? nowMs,
  }) {
    final now = nowMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    final recipeId = _uuid.v4();

    final ingredients = <RecipeIngredient>[];
    for (final raw in _maps(json['ingredients'])) {
      final name = _str(raw['name']);
      if (name.isEmpty) continue;
      final qty = _num(raw['quantity']);
      final unit = _str(raw['unit']).toLowerCase();
      final note = _str(raw['note']);
      final toTaste = qty <= 0;
      ingredients.add(RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipeId,
        displayName: _sentenceCase(name),
        quantity: toTaste ? null : _rational(qty),
        unitCode: unit.isEmpty ? null : unit,
        authoredQuantity: toTaste && note.toLowerCase().contains('taste') ? 'to taste' : null,
        scalingPolicy: toTaste ? ScalingPolicy.toTaste : ScalingPolicy.scale,
        prepText: note.isEmpty ? null : note,
        isOptional: raw['optional'] == true,
        position: ingredients.length + 1,
        icon: RecipeArt.iconKeyFor(name),
      ));
    }

    final steps = <RecipeStep>[];
    var timedMinutes = 0.0;
    for (final raw in _maps(json['steps'])) {
      final instruction = _str(raw['instruction']);
      if (instruction.isEmpty) continue;
      final stepId = _uuid.v4();
      final minutes = _num(raw['timer_minutes']).clamp(0, 48 * 60).toDouble();
      final tempC = _num(raw['temperature_c']).round().clamp(0, 400);
      final action = _str(raw['action']);
      timedMinutes += minutes;
      steps.add(RecipeStep(
        id: stepId,
        recipeId: recipeId,
        position: steps.length + 1,
        instructionShort: instruction,
        instructionDetail: _str(raw['detail']).isEmpty ? null : _str(raw['detail']),
        actionKey: action.isEmpty ? null : _sentenceCase(action),
        durationSeconds: minutes > 0 ? (minutes * 60).round() : null,
        temperatureC: tempC > 0 ? tempC : null,
        temperatureF: tempC > 0 ? (tempC * 9 / 5 + 32).round() : null,
        timers: minutes > 0
            ? [
                StepTimer(
                  id: _uuid.v4(),
                  recipeStepId: stepId,
                  label: action.isEmpty ? 'Step ${steps.length + 1}' : _sentenceCase(action),
                  durationSeconds: (minutes * 60).round(),
                ),
              ]
            : const [],
      ));
    }

    final labels = <RecipeLabel>[];
    final cuisine = _str(json['cuisine']);
    if (cuisine.isNotEmpty) labels.add(_label(recipeId, 'cuisine', cuisine));
    for (final tag in _strings(json['tags']).take(5)) {
      labels.add(_label(recipeId, 'tag', tag));
    }

    final title = _str(json['title']).isEmpty ? 'Untitled recipe' : _str(json['title']);
    final servings = _num(json['servings']);
    final totalMinutes = _num(json['total_minutes']).round();
    final chefTip = _str(json['chef_tip']);

    final recipe = Recipe(
      id: recipeId,
      profileId: profileId,
      title: title,
      summary: _str(json['summary']).isEmpty ? null : _str(json['summary']),
      status: RecipeStatus.draft,
      baseServings: servings > 0 ? _rational(servings.clamp(0.5, 100).toDouble()) : Rational(2),
      difficulty: RecipeDifficulty.fromString(_str(json['difficulty'])),
      totalMinutes: totalMinutes > 0 ? totalMinutes.clamp(1, 7 * 24 * 60) : timedMinutes.round(),
      origin: origin,
      polaroidCaption: title,
      theme: theme,
      moodStamps: _strings(json['tags']).take(3).map(_sentenceCase).toList(),
      chefTip: chefTip.isEmpty ? null : chefTip,
      chefTipIcon: chefTip.isEmpty ? null : 'chef-hat',
      createdAt: now,
      updatedAt: now,
      ingredients: ingredients,
      steps: steps,
      labels: labels,
    );
    return AiRecipeDraft(recipe, _strings(json['warnings']).take(6).toList());
  }

  RecipeLabel _label(String recipeId, String kind, String name) {
    final key = name.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return RecipeLabel(
      id: _uuid.v4(),
      recipeId: recipeId,
      labelId: '$kind:$key',
      kind: kind,
      canonicalKey: key,
      displayName: _sentenceCase(name),
      sourceConfidence: 0.8,
      isUserConfirmed: false,
    );
  }

  /// Snaps model decimals (0.333) back to friendly kitchen fractions (1/3).
  static Rational _rational(double v) {
    try {
      final r = Rational.fromDouble(v, 0.02);
      return r.denominator > 16 ? Rational((v * 100).round(), 100) : r;
    } catch (_) {
      return Rational(1);
    }
  }

  static String _sentenceCase(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  static String _str(Object? v) => v is String ? v.trim() : '';
  static double _num(Object? v) {
    final d = v is num ? v.toDouble() : double.tryParse('$v');
    return d == null || !d.isFinite || d < 0 ? 0 : d;
  }

  static Iterable<Map<String, dynamic>> _maps(Object? v) => v is List ? v.whereType<Map<String, dynamic>>() : const [];
  static Iterable<String> _strings(Object? v) =>
      v is List ? v.whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty) : const [];
}
