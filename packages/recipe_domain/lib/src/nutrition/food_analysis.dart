import 'package:meta/meta.dart';
import 'nutrition_facts.dart';

/// What the user pointed the camera at.
enum ScanMode {
  /// A plated meal or snack → identify components and estimate nutrition.
  meal,

  /// Raw ingredients / fridge / pantry → identify ingredients for cooking.
  ingredients,

  /// A printed or handwritten recipe → extract a structured recipe.
  recipeCard;

  String get key => switch (this) {
        ScanMode.meal => 'meal',
        ScanMode.ingredients => 'ingredients',
        ScanMode.recipeCard => 'recipe_card',
      };

  static ScanMode fromKey(String? key) => switch (key) {
        'ingredients' => ScanMode.ingredients,
        'recipe_card' => ScanMode.recipeCard,
        _ => ScanMode.meal,
      };
}

/// Canonical allergen vocabulary shared by the AI schema and the UI.
const List<String> canonicalAllergens = [
  'gluten',
  'dairy',
  'egg',
  'peanuts',
  'tree_nuts',
  'soy',
  'sesame',
  'fish',
  'shellfish',
];

String allergenLabel(String key) => switch (key) {
      'gluten' => 'Gluten',
      'dairy' => 'Dairy',
      'egg' => 'Egg',
      'peanuts' => 'Peanuts',
      'tree_nuts' => 'Tree nuts',
      'soy' => 'Soy',
      'sesame' => 'Sesame',
      'fish' => 'Fish',
      'shellfish' => 'Shellfish',
      _ => key,
    };

@immutable
class FoodItemEstimate {
  final String name;
  final String portion;
  final double grams;
  final NutritionFacts nutrition;
  final double confidence;

  const FoodItemEstimate({
    required this.name,
    required this.portion,
    required this.grams,
    required this.nutrition,
    required this.confidence,
  });

  factory FoodItemEstimate.fromJson(Map<String, dynamic> json) => FoodItemEstimate(
        name: _str(json['name']),
        portion: _str(json['portion']),
        grams: _num(json['grams']),
        nutrition: NutritionFacts.fromJson(json),
        confidence: _unit(json['confidence']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'portion': portion,
        'grams': grams,
        ...nutrition.toJson(),
        'confidence': confidence,
      };
}

/// Structured result of a camera scan, produced by the vision model and
/// validated here. Every field is safe to render directly.
@immutable
class FoodAnalysis {
  final ScanMode mode;
  final bool isFood;
  final String title;
  final String description;
  final String cuisine;
  final double confidence;
  final List<FoodItemEstimate> items;
  final List<String> allergens;
  final List<String> dietaryTags;
  final List<String> healthNotes;
  final List<String> detectedIngredients;
  final List<String> recipeIdeas;

  const FoodAnalysis({
    required this.mode,
    required this.isFood,
    required this.title,
    required this.description,
    this.cuisine = '',
    required this.confidence,
    this.items = const [],
    this.allergens = const [],
    this.dietaryTags = const [],
    this.healthNotes = const [],
    this.detectedIngredients = const [],
    this.recipeIdeas = const [],
  });

  /// Totals are always the sum of the items, so the numbers on screen add up
  /// even if the model's own arithmetic was off.
  NutritionFacts get total => NutritionFacts.sum(items.map((i) => i.nutrition));

  factory FoodAnalysis.fromJson(Map<String, dynamic> json, {ScanMode? mode}) {
    final items = _list(json['items'])
        .whereType<Map<String, dynamic>>()
        .map(FoodItemEstimate.fromJson)
        .where((i) => i.name.isNotEmpty)
        .toList(growable: false);
    final allergenSet = _strings(json['allergens'])
        .map((a) => a.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_'))
        .map((a) => switch (a) {
              'nuts' || 'tree_nut' || 'treenuts' => 'tree_nuts',
              'peanut' => 'peanuts',
              'eggs' => 'egg',
              'milk' || 'lactose' => 'dairy',
              'wheat' => 'gluten',
              _ => a,
            })
        .where(canonicalAllergens.contains)
        .toSet();

    return FoodAnalysis(
      mode: mode ?? ScanMode.fromKey(json['mode'] as String?),
      isFood: json['is_food'] is bool ? json['is_food'] as bool : items.isNotEmpty,
      title: _str(json['title'], fallback: 'Scanned food'),
      description: _str(json['description']),
      cuisine: _str(json['cuisine']),
      confidence: _unit(json['confidence']),
      items: items,
      allergens: canonicalAllergens.where(allergenSet.contains).toList(growable: false),
      dietaryTags: _strings(json['dietary_tags']).take(8).toList(growable: false),
      healthNotes: _strings(json['health_notes']).take(6).toList(growable: false),
      detectedIngredients: _strings(json['detected_ingredients']).take(40).toList(growable: false),
      recipeIdeas: _strings(json['recipe_ideas']).take(6).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.key,
        'is_food': isFood,
        'title': title,
        'description': description,
        'cuisine': cuisine,
        'confidence': confidence,
        'items': items.map((i) => i.toJson()).toList(),
        'allergens': allergens,
        'dietary_tags': dietaryTags,
        'health_notes': healthNotes,
        'detected_ingredients': detectedIngredients,
        'recipe_ideas': recipeIdeas,
      };

}

String _str(Object? v, {String fallback = ''}) {
  if (v is String) {
    final t = v.trim();
    return t.isEmpty ? fallback : t;
  }
  return fallback;
}

List<dynamic> _list(Object? v) => v is List ? v : const [];

Iterable<String> _strings(Object? v) =>
    _list(v).whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);

double _num(Object? v) {
  final d = v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null);
  if (d == null || !d.isFinite || d < 0) return 0;
  return d;
}

double _unit(Object? v) {
  final d = _num(v);
  return d > 1 ? (d <= 100 ? d / 100 : 1) : d;
}
