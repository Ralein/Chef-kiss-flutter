import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';

RecipeIngredient ing(String name, {num? qty, String? unit, int position = 1}) => RecipeIngredient(
      id: 'i-$name-$position',
      recipeId: 'r',
      displayName: name,
      quantity: qty == null ? null : Rational.fromDouble(qty.toDouble()),
      unitCode: unit,
      position: position,
    );

Recipe recipe(List<RecipeIngredient> ingredients, {int servings = 4, Map<String, NutritionFacts>? overrides}) =>
    Recipe(
      id: 'r',
      profileId: 'default',
      title: 'Test',
      baseServings: Rational(servings),
      createdAt: 0,
      updatedAt: 0,
      ingredients: ingredients,
      nutritionOverrides: overrides ?? const {},
    );

void main() {
  group('FoodMatcher', () {
    final m = FoodMatcher.standard;
    String? id(String name) => m.match(name)?.id;

    test('prefers the head noun (right-most phrase)', () {
      expect(id('whole milk ricotta cheese'), 'ricotta');
      expect(id('creamy peanut butter'), 'peanut_butter');
      expect(id('rice vinegar'), 'vinegar');
      expect(id('coconut milk'), 'coconut_milk');
      expect(id('almond milk'), isNot('almonds'));
      expect(id('milk chocolate'), 'chocolate_chips');
    });

    test('handles plurals, accents, punctuation and descriptors', () {
      expect(id('Grated Parmigiano-Reggiano'), 'parmesan');
      expect(id('finely chopped yellow onions'), 'onion');
      expect(id('boneless, skinless chicken breasts'), 'chicken_breast');
      expect(id('2 cloves garlic, minced'), 'garlic');
      expect(id('fresh basil leaves, torn'), 'fresh_herbs');
      expect(id('Crème fraîche'), 'cream_sour');
      expect(id('Red pepper flakes'), 'chili_flakes');
      expect(id('red bell pepper'), 'bell_pepper');
      expect(id('cherry tomatoes'), 'tomato_cherry');
      expect(id('San Marzano Tomatoes'), 'tomato_canned');
      expect(id('olives'), 'olives');
    });

    test('returns null for unknown foods instead of guessing', () {
      expect(m.match('Key Ingredient'), isNull);
      expect(m.match(''), isNull);
      expect(m.match('dragon scales'), isNull);
    });

    test('singularize avoids naive -ves / -ies mistakes', () {
      expect(FoodMatcher.singularize('cloves'), 'clove');
      expect(FoodMatcher.singularize('olives'), 'olive');
      expect(FoodMatcher.singularize('leaves'), 'leaf');
      expect(FoodMatcher.singularize('berries'), 'berry');
      expect(FoodMatcher.singularize('tomatoes'), 'tomato');
      expect(FoodMatcher.singularize('glass'), 'glass');
      expect(FoodMatcher.singularize('chilies'), 'chili');
    });
  });

  group('KitchenUnits.toGrams', () {
    final flour = FoodMatcher.standard.match('flour')!;
    final egg = FoodMatcher.standard.match('egg')!;
    final garlic = FoodMatcher.standard.match('garlic')!;
    final pasta = FoodMatcher.standard.match('fresh pasta')!;

    test('converts mass, volume (via density) and count units', () {
      expect(KitchenUnits.toGrams(200, 'g', flour), 200);
      expect(KitchenUnits.toGrams(1, 'lb', flour), closeTo(453.6, 0.1));
      expect(KitchenUnits.toGrams(1, 'cup', flour), closeTo(125.4, 0.5));
      expect(KitchenUnits.toGrams(2, null, egg), 100);
      expect(KitchenUnits.toGrams(3, 'cloves', garlic), 9);
    });

    test('returns null when a conversion would be a guess', () {
      expect(KitchenUnits.toGrams(null, 'g', flour), isNull);
      expect(KitchenUnits.toGrams(1, 'to taste', flour), isNull);
      expect(KitchenUnits.toGrams(1, 'cup', pasta), isNull, reason: 'no density on record');
      expect(KitchenUnits.toGrams(1, 'pkg', flour), isNull);
      expect(KitchenUnits.toGrams(-2, 'g', flour), isNull);
    });
  });

  group('RecipeNutritionAnalyzer', () {
    final analyzer = RecipeNutritionAnalyzer();

    test('estimates a full recipe and splits per serving', () {
      // Lemon ricotta pasta, serves 4.
      final r = recipe([
        ing('rigatoni pasta', qty: 1, unit: 'lb', position: 1),
        ing('whole milk ricotta cheese', qty: 1, unit: 'cup', position: 2),
        ing('grated Parmigiano-Reggiano', qty: 0.5, unit: 'cup', position: 3),
        ing('lemons', qty: 2, position: 4),
        ing('garlic', qty: 2, unit: 'cloves', position: 5),
        ing('extra-virgin olive oil', qty: 0.25, unit: 'cup', position: 6),
        ing('salt and freshly cracked black pepper to taste', position: 7),
      ]);
      final report = analyzer.analyze(r);

      expect(report.coverage, 1.0);
      // pasta 1682 + ricotta 428 + parmesan 195 + lemons 34 + garlic 9 + oil 477 ≈ 2825 kcal
      expect(report.total.calories, closeTo(2825, 60));
      expect(report.perServing.calories, closeTo(706, 15));
      expect(report.perServing.proteinG, greaterThan(20));
      expect(report.diet.isVegetarian, isTrue);
      expect(report.diet.isVegan, isFalse);
      expect(report.diet.isGlutenFree, isFalse);
      expect(report.diet.allergens, containsAll(['Gluten', 'Dairy']));
      expect(report.diet.isComplete, isTrue);
    });

    test('reports unresolved lines honestly instead of inventing numbers', () {
      final report = analyzer.analyze(recipe([
        ing('flour', qty: 200, unit: 'g', position: 1),
        ing('Key Ingredient', qty: 250, unit: 'g', position: 2),
        ing('tortilla', qty: 1, unit: 'cup', position: 3),
      ]));
      expect(report.coveredLines, 1);
      expect(report.coverage, closeTo(1 / 3, 1e-9));
      expect(report.unresolved.map((l) => l.status),
          [NutritionLineStatus.unmatched, NutritionLineStatus.unquantified]);
      expect(report.diet.isComplete, isFalse);
    });

    test('meat and seafood break vegetarian; honey breaks vegan only', () {
      expect(analyzer.analyze(recipe([ing('chicken thighs', qty: 4)])).diet.isVegetarian, isFalse);
      expect(analyzer.analyze(recipe([ing('shrimp', qty: 200, unit: 'g')])).diet.allergens, ['Shellfish']);
      final honey = analyzer.analyze(recipe([ing('honey', qty: 1, unit: 'tbsp')])).diet;
      expect(honey.isVegetarian, isTrue);
      expect(honey.isVegan, isFalse);
    });

    test('overrides apply only while the ingredient line is unchanged', () {
      final mystery = ing('Nonna secret blend', qty: 2, unit: 'tbsp');
      final fp = RecipeNutritionAnalyzer.fingerprint(mystery);
      const facts = NutritionFacts(calories: 80, fatG: 6);

      final withOverride = analyzer.analyze(recipe([mystery], overrides: {fp: facts}));
      expect(withOverride.lines.single.status, NutritionLineStatus.override);
      expect(withOverride.total.calories, 80);

      final edited = mystery.copyWith(quantity: Rational(3));
      final stale = analyzer.analyze(recipe([edited], overrides: {fp: facts}));
      expect(stale.lines.single.status, NutritionLineStatus.unmatched);
      expect(stale.total.calories, 0);
    });

    test('guards against zero or invalid servings', () {
      final r = recipe([ing('butter', qty: 100, unit: 'g')], servings: 0);
      final report = analyzer.analyze(r);
      expect(report.servings, 1);
      expect(report.perServing.calories, closeTo(717, 1));
    });
  });

  group('NutritionFacts', () {
    test('parsing clamps garbage to safe values', () {
      final f = NutritionFacts.fromJson({'calories': -5, 'protein_g': 'NaN', 'fat_g': '12.5', 'carbs_g': double.infinity});
      expect(f.calories, 0);
      expect(f.proteinG, 0);
      expect(f.fatG, 12.5);
      expect(f.carbsG, 0);
      expect(f.scale(double.nan), NutritionFacts.zero);
    });

    test('macro energy split uses Atwater factors', () {
      const f = NutritionFacts(proteinG: 10, carbsG: 10, fatG: 10);
      final split = f.macroEnergySplit;
      expect(split.fat, closeTo(90 / 170, 1e-9));
      expect(split.protein + split.carbs + split.fat, closeTo(1, 1e-9));
    });

    test('override maps round-trip through JSON', () {
      final encoded = NutritionFacts.encodeOverrides({'a|1|g': const NutritionFacts(calories: 42.04)});
      final decoded = NutritionFacts.decodeOverrides(encoded);
      expect(decoded['a|1|g']!.calories, 42.0);
    });
  });

  group('FoodAnalysis.fromJson', () {
    test('sums items for totals and normalizes allergens', () {
      final a = FoodAnalysis.fromJson({
        'is_food': true,
        'title': '  Margherita pizza ',
        'description': 'Wood-fired',
        'confidence': 85,
        'items': [
          {'name': 'Pizza slice', 'portion': '2 slices', 'grams': 220, 'calories': 560, 'protein_g': 24},
          {'name': 'Side salad', 'portion': '1 bowl', 'grams': 80, 'calories': 40, 'protein_g': 1},
          {'name': '', 'calories': 9999},
          'not-an-object',
        ],
        'allergens': ['Wheat', 'milk', 'tree nut', 'radioactive'],
        'dietary_tags': ['vegetarian'],
      }, mode: ScanMode.meal);

      expect(a.title, 'Margherita pizza');
      expect(a.confidence, 0.85);
      expect(a.items, hasLength(2));
      expect(a.total.calories, 600);
      expect(a.allergens, ['gluten', 'dairy', 'tree_nuts']);
      expect(a.toJson()['items'], hasLength(2));
    });

    test('tolerates a completely malformed payload', () {
      final a = FoodAnalysis.fromJson({'items': 'nope', 'confidence': 'high', 'allergens': 7});
      expect(a.isFood, isFalse);
      expect(a.items, isEmpty);
      expect(a.confidence, 0);
      expect(a.title, 'Scanned food');
    });
  });
}
