import 'package:recipe_domain/recipe_domain.dart';

/// Picks bundled artwork and icons for recipes that have no photo of their own.
class RecipeArt {
  RecipeArt._();

  static const pasta = 'assets/illustrations/sketchbook_pasta.jpg';
  static const crepes = 'assets/illustrations/sketchbook_crepes.jpg';
  static const ramen = 'assets/illustrations/sketchbook_ramen.jpg';
  static const salad = 'assets/illustrations/sketchbook_salad.jpg';
  static const sourdough = 'assets/illustrations/sketchbook_sourdough.jpg';

  static const all = [pasta, crepes, ramen, salad, sourdough];

  static const Map<String, List<String>> _keywords = {
    ramen: ['ramen', 'noodle soup', 'pho', 'udon', 'soba', 'miso soup', 'laksa', 'broth', 'soup', 'stew', 'curry'],
    pasta: ['pasta', 'spaghetti', 'fettuccine', 'penne', 'rigatoni', 'linguine', 'lasagna', 'lasagne', 'gnocchi',
        'carbonara', 'pomodoro', 'bolognese', 'macaroni', 'tagliatelle', 'orzo', 'risotto'],
    crepes: ['crepe', 'pancake', 'waffle', 'french toast', 'cake', 'cookie', 'tart', 'pie', 'pastry', 'muffin',
        'brownie', 'dessert', 'pudding', 'custard', 'scone'],
    sourdough: ['bread', 'sourdough', 'loaf', 'focaccia', 'baguette', 'boule', 'bun', 'roll', 'brioche', 'bagel',
        'pizza', 'flatbread', 'dough'],
    salad: ['salad', 'avocado', 'toast', 'bowl', 'slaw', 'greens', 'vegetable', 'veggie', 'grain bowl', 'poke'],
  };

  /// Best-matching illustration for [title] (then ingredients), or null when
  /// nothing fits — callers then render a themed placeholder rather than a
  /// misleading picture.
  static String? coverFor(String title, [Iterable<String> ingredientNames = const []]) {
    String norm(String s) => FoodMatcher.normalizeWords(s).join(' ');
    final t = ' ${norm(title)} ';
    for (final entry in _keywords.entries) {
      if (entry.value.any((k) => t.contains(' ${norm(k)} '))) return entry.key;
    }
    final ingredients = ' ${ingredientNames.map(norm).join(' ')} ';
    for (final entry in _keywords.entries) {
      if (entry.value.any((k) => ingredients.contains(' ${norm(k)} '))) return entry.key;
    }
    return null;
  }

  static const Map<String, String> _iconForFood = {
    'flour_ap': 'wheat', 'flour_bread': 'wheat', 'flour_ww': 'wheat', 'semolina': 'wheat', 'oats': 'wheat',
    'rice_white': 'wheat', 'rice_cooked': 'wheat', 'rice_brown': 'wheat', 'quinoa': 'wheat', 'couscous': 'wheat',
    'pasta_dry': 'utensils', 'pasta_fresh': 'utensils', 'noodles_egg': 'soup', 'noodles_rice': 'soup',
    'bread_white': 'bread', 'bread_sourdough': 'bread', 'bread_brioche': 'croissant', 'breadcrumbs': 'bread',
    'tortilla': 'sandwich', 'sourdough_starter': 'sourdough-starter',
    'egg': 'egg', 'egg_yolk': 'egg', 'egg_white': 'egg',
    'butter': 'butter', 'butter_unsalted': 'butter', 'ghee': 'butter',
    'milk_whole': 'milk', 'milk_low': 'milk', 'milk_skim': 'milk', 'buttermilk': 'milk', 'cream_heavy': 'milk',
    'cream_sour': 'milk', 'yogurt': 'milk', 'yogurt_greek': 'milk', 'coconut_milk': 'milk',
    'olive_oil': 'droplets', 'vegetable_oil': 'droplets', 'sesame_oil': 'droplets', 'coconut_oil': 'droplets',
    'honey': 'honey', 'maple_syrup': 'honey', 'sugar': 'candy', 'sugar_brown': 'candy', 'sugar_powdered': 'candy',
    'chocolate_dark': 'cookie', 'chocolate_chips': 'cookie', 'cocoa': 'cookie',
    'chicken_breast': 'drumstick', 'chicken_thigh': 'drumstick', 'chicken': 'drumstick',
    'beef_ground': 'beef', 'beef': 'beef', 'pork': 'ham', 'pork_ground': 'ham', 'bacon': 'ham',
    'salmon': 'fish', 'white_fish': 'fish', 'tuna_canned': 'fish', 'anchovy': 'fish', 'shrimp': 'shrimp',
    'shellfish': 'shrimp',
    'almonds': 'nut', 'walnuts': 'nut', 'cashews': 'nut', 'pine_nuts': 'nut', 'peanuts': 'nut',
    'peanut_butter': 'nut', 'beans': 'bean', 'chickpeas': 'bean', 'lentils': 'bean', 'edamame': 'bean',
    'garlic': 'garlic', 'tomato': 'tomato', 'tomato_cherry': 'tomato', 'tomato_canned': 'tomato',
    'tomato_paste': 'tomato', 'tomato_sauce': 'tomato', 'chili': 'chili', 'chili_flakes': 'chili',
    'avocado': 'avocado', 'mushroom': 'mushroom', 'carrot': 'carrot', 'lemon': 'lemon', 'lemon_juice': 'lemon',
    'lime': 'citrus', 'orange': 'citrus', 'citrus_zest': 'citrus', 'apple': 'apple', 'banana': 'banana',
    'strawberry': 'cherry', 'blueberry': 'cherry', 'berries': 'cherry', 'grapes': 'grape',
    'fresh_herbs': 'leaf', 'dried_herbs': 'leaf', 'spinach': 'salad', 'leafy_greens': 'salad', 'lettuce': 'salad',
    'salt': 'sea-salt', 'black_pepper': 'sea-salt', 'water': 'glass-water', 'wine': 'wine',
  };

  /// Culinary icon key for an ingredient, derived from the food catalog.
  static String iconKeyFor(String ingredientName) {
    final food = FoodMatcher.standard.match(ingredientName);
    return _iconForFood[food?.id] ?? 'utensils';
  }
}
