import 'package:recipe_domain/recipe_domain.dart';

/// System prompts and JSON schemas for every AI task in the app.
///
/// Schemas follow the structured-outputs rules: every object sets
/// `additionalProperties: false`, every property is required (unknowns are
/// expressed as 0 / "" / []), and no numeric or length constraints are used —
/// ranges are enforced client-side when parsing.
class AiPrompts {
  AiPrompts._();

  static Map<String, dynamic> _obj(Map<String, dynamic> properties) => {
        'type': 'object',
        'properties': properties,
        'required': properties.keys.toList(),
        'additionalProperties': false,
      };

  static const _str = {'type': 'string'};
  static const _num = {'type': 'number'};
  static const _int = {'type': 'integer'};
  static const _bool = {'type': 'boolean'};
  static const _strList = {'type': 'array', 'items': _str};

  static Map<String, dynamic> get _nutrientProps => {
        'calories': _num,
        'protein_g': _num,
        'carbs_g': _num,
        'fat_g': _num,
        'fiber_g': _num,
        'sugar_g': _num,
        'sodium_mg': _num,
      };

  // --- Food photo analysis ---------------------------------------------------

  static Map<String, dynamic> get foodAnalysisSchema => _obj({
        'is_food': _bool,
        'title': _str,
        'description': _str,
        'cuisine': _str,
        'confidence': _num,
        'items': {
          'type': 'array',
          'items': _obj({
            'name': _str,
            'portion': _str,
            'grams': _num,
            ..._nutrientProps,
            'confidence': _num,
          }),
        },
        'allergens': {
          'type': 'array',
          'items': {'type': 'string', 'enum': canonicalAllergens},
        },
        'dietary_tags': _strList,
        'health_notes': _strList,
        'detected_ingredients': _strList,
        'recipe_ideas': _strList,
      });

  static const mealSystem = '''
You estimate the nutrition of food and drink shown in photos for a home-cooking and food-journal app. People use the numbers to keep a food log, so realistic estimates matter more than precision you do not have.

For each distinct component that is visible (a main, a side, a sauce, a drink), estimate the portion actually shown in grams and the nutrients of that portion, using typical recipes and standard food-composition values. Account for visible oil, butter, dressings and sauces. Judge size from cues such as plate or bowl size, utensils, hands and packaging. Report identical pieces together as one item ("3 cookies").

Field notes:
- confidence values run from 0 to 1. Express doubt through confidence rather than by leaving out a component.
- Use 0 for a nutrient you cannot estimate at all.
- allergens: only those likely present in what is shown.
- dietary_tags: a few short lowercase tags that genuinely apply, such as "vegetarian", "vegan", "gluten-free", "high-protein", "high-fiber".
- health_notes: at most three short, practical, non-judgmental observations about the meal. Never give medical advice.
- detected_ingredients: main ingredients you can see or reasonably infer.
- recipe_ideas: up to three dish ideas for cooking this food at home or using leftovers.
- title: a natural dish name; description: one sentence.
- If the photo does not show food or drink, set is_food to false, say what you see in description, and leave the lists empty.''';

  static const ingredientsSystem = '''
You identify cooking ingredients in photos of fridges, pantries, groceries or cutting boards for a home-cooking app, so the user can find or create recipes with what they have.

- detected_ingredients: every distinct ingredient you can identify, written the way a cook would search for it ("red bell pepper", "cheddar cheese", "eggs"), most prominent first. Do not list items you cannot actually see.
- recipe_ideas: three to five realistic dishes that use mostly these ingredients plus common pantry staples.
- items: leave empty unless a quantity is clearly readable (for example on packaging).
- title: a short summary such as "Fridge staples" and description: one sentence about what is there.
- allergens: those present among the identified ingredients.
- health_notes and dietary_tags: may be empty.
- If the photo shows no food or ingredients, set is_food to false and leave the lists empty.''';

  // --- Recipes (extraction & generation) ------------------------------------

  static Map<String, dynamic> get recipeSchema => _obj({
        'is_recipe': _bool,
        'title': _str,
        'summary': _str,
        'servings': _num,
        'total_minutes': _int,
        'difficulty': {
          'type': 'string',
          'enum': ['easy', 'medium', 'hard'],
        },
        'cuisine': _str,
        'ingredients': {
          'type': 'array',
          'items': _obj({
            'quantity': _num,
            'unit': _str,
            'name': _str,
            'note': _str,
            'optional': _bool,
          }),
        },
        'steps': {
          'type': 'array',
          'items': _obj({
            'instruction': _str,
            'detail': _str,
            'action': _str,
            'timer_minutes': _num,
            'temperature_c': _int,
          }),
        },
        'chef_tip': _str,
        'tags': _strList,
        'warnings': _strList,
      });

  static const _recipeFieldNotes = '''
Field notes:
- quantity: a decimal number (0.5 for "1/2", 0.333 for "1/3", 1.5 for "1 1/2"). Use 0 when no amount is given, such as "salt to taste".
- unit: a short standard unit (g, kg, ml, l, tsp, tbsp, cup, oz, lb, clove, slice, can, pinch, bunch) or "" for countable items ("2 eggs" is quantity 2, unit "").
- name: the ingredient itself ("yellow onion"); preparation such as "finely chopped" goes in note.
- steps: one action per step, in order. instruction is a short imperative sentence; detail adds useful specifics or is "".
- action: a single capitalized cooking verb for the step ("Simmer", "Whisk", "Bake").
- timer_minutes: a duration the cook must wait or watch in that step (upper bound of a range), else 0.
- temperature_c: oven or oil temperature in °C if one applies (convert from °F), else 0.
- servings: the yield in servings; total_minutes: active plus passive time.
- tags: up to five short lowercase tags (course, diet, key technique).''';

  static const extractSystem = '''
You convert recipe sources — pasted text, web page text, or photos of cookbook pages and handwritten cards — into structured data for a personal cookbook app.

Transcribe faithfully. Keep the author's ingredients, amounts and method; do not invent ingredients, steps or timings that the source does not support. Correct obvious OCR or handwriting errors, normalize units, and drop page clutter such as ads, navigation, comments and life stories. If something is illegible or missing (for example no servings given), make the most reasonable reading and say so in warnings. If the source is not a recipe, set is_recipe to false and leave the lists empty.

$_recipeFieldNotes''';

  static const generateSystem = '''
You develop original, reliable recipes for a home-cooking app. Write one recipe that fulfils the user's request with realistic quantities, clear technique, and timing a home cook can follow. Use widely available ingredients unless the request asks otherwise, and default to 2–4 servings. Include food-safety essentials where they apply (for example safe internal temperatures for poultry). Give one genuinely useful chef_tip. Set is_recipe to true and leave warnings empty unless the request could not be fully honoured.

$_recipeFieldNotes''';

  // --- Ingredient nutrition estimates ----------------------------------------

  static Map<String, dynamic> get ingredientNutritionSchema => _obj({
        'estimates': {
          'type': 'array',
          'items': _obj({
            'line': _int,
            'grams': _num,
            ..._nutrientProps,
            'confidence': _num,
          }),
        },
      });

  static const ingredientNutritionSystem = '''
You estimate nutrition for individual recipe ingredient lines for a cooking app's nutrition panel. For each numbered line, estimate the weight in grams of the whole amount written and the nutrients of that whole amount (not per 100 g), using standard food-composition values for the ingredient as purchased. If a line has no amount, assume a typical amount for one recipe and lower the confidence. Return one estimate per line, using the line numbers given. confidence runs from 0 to 1.''';
}
