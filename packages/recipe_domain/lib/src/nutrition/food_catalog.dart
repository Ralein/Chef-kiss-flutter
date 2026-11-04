import 'package:meta/meta.dart';
import 'nutrition_facts.dart';

/// Dietary / allergen traits attached to catalog foods. Used to derive diet
/// badges (vegetarian, vegan, gluten-free …) for whole recipes.
enum FoodTrait {
  meat,
  poultry,
  fish,
  shellfish,
  dairy,
  egg,
  gluten,
  treeNut,
  peanut,
  soy,
  sesame,

  /// Animal-derived but not meat/dairy/egg (honey, gelatin): breaks vegan only.
  animalDerived,
  alcohol,
}

/// A reference food with nutrients per 100 g plus the data needed to convert
/// kitchen measurements (cups, pieces, slices, cans …) into grams.
@immutable
class FoodEntry {
  final String id;
  final String name;
  final List<String> keywords;
  final NutritionFacts per100g;

  /// Grams per millilitre, for volume measures (cup, tbsp, ml …).
  final double? densityGPerMl;

  /// Grams for one typical piece ("2 eggs", "1 onion").
  final double? pieceGrams;
  final double? sliceGrams;
  final double? cloveGrams;
  final double? canGrams;
  final double? bunchGrams;

  final Set<FoodTrait> traits;

  /// Seasonings, water and garnishes whose energy is negligible. They never
  /// count against coverage, even when no quantity is given ("salt to taste").
  final bool isTrace;

  const FoodEntry({
    required this.id,
    required this.name,
    required this.keywords,
    required this.per100g,
    this.densityGPerMl,
    this.pieceGrams,
    this.sliceGrams,
    this.cloveGrams,
    this.canGrams,
    this.bunchGrams,
    this.traits = const {},
    this.isTrace = false,
  });
}

/// Compact constructor for per-100 g facts: kcal, protein, carbs, fat, fiber,
/// sugar (g) and sodium (mg).
NutritionFacts _n(double kcal, double p, double c, double f, double fiber, double sugar, double na) =>
    NutritionFacts(calories: kcal, proteinG: p, carbsG: c, fatG: f, fiberG: fiber, sugarG: sugar, sodiumMg: na);

/// Built-in reference catalog. Values are per 100 g of the food as purchased
/// (raw unless noted) and are based on USDA FoodData Central (SR Legacy /
/// Foundation Foods) entries, rounded. Results derived from this table are
/// estimates and are labelled as such in the UI.
final List<FoodEntry> foodCatalog = List.unmodifiable(<FoodEntry>[
  // --- Grains, flours & starches -------------------------------------------
  FoodEntry(id: 'flour_ap', name: 'All-purpose flour', keywords: ['flour', 'all purpose flour', 'plain flour', '00 flour', 'cake flour', 'pastry flour', 'self rising flour'], per100g: _n(364, 10.3, 76.3, 1.0, 2.7, 0.3, 2), densityGPerMl: 0.53, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'flour_bread', name: 'Bread flour', keywords: ['bread flour', 'strong flour'], per100g: _n(361, 12.0, 72.5, 1.7, 2.4, 0.3, 2), densityGPerMl: 0.54, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'flour_ww', name: 'Whole wheat flour', keywords: ['whole wheat flour', 'wholemeal flour', 'whole grain flour'], per100g: _n(340, 13.2, 72.0, 2.5, 10.7, 0.4, 2), densityGPerMl: 0.51, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'semolina', name: 'Semolina', keywords: ['semolina'], per100g: _n(360, 12.7, 72.8, 1.1, 3.9, 0, 1), densityGPerMl: 0.71, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'cornstarch', name: 'Cornstarch', keywords: ['cornstarch', 'corn starch', 'cornflour'], per100g: _n(381, 0.3, 91.3, 0.1, 0.9, 0, 9), densityGPerMl: 0.54),
  FoodEntry(id: 'rice_white', name: 'White rice (uncooked)', keywords: ['rice', 'white rice', 'jasmine rice', 'basmati rice', 'arborio rice', 'sushi rice', 'long grain rice'], per100g: _n(365, 7.1, 80.0, 0.7, 1.3, 0.1, 5), densityGPerMl: 0.78),
  FoodEntry(id: 'rice_cooked', name: 'White rice (cooked)', keywords: ['cooked rice', 'steamed rice', 'cooked white rice'], per100g: _n(130, 2.7, 28.2, 0.3, 0.4, 0.1, 1), densityGPerMl: 0.67),
  FoodEntry(id: 'rice_brown', name: 'Brown rice (uncooked)', keywords: ['brown rice'], per100g: _n(370, 7.9, 77.2, 2.9, 3.5, 0.9, 7), densityGPerMl: 0.8),
  FoodEntry(id: 'pasta_dry', name: 'Pasta (dry)', keywords: ['pasta', 'spaghetti', 'penne', 'rigatoni', 'fettuccine', 'linguine', 'macaroni', 'fusilli', 'tagliatelle', 'farfalle', 'orzo', 'lasagna sheet', 'lasagne'], per100g: _n(371, 13.0, 74.7, 1.5, 3.2, 2.7, 6), densityGPerMl: 0.42, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'pasta_fresh', name: 'Fresh egg pasta', keywords: ['fresh pasta', 'egg pasta', 'fresh fettuccine', 'fresh tagliatelle'], per100g: _n(288, 11.3, 54.7, 2.3, 2.0, 0.5, 26), traits: {FoodTrait.gluten, FoodTrait.egg}),
  FoodEntry(id: 'noodles_egg', name: 'Egg noodles (dry)', keywords: ['noodle', 'egg noodle', 'ramen noodle', 'ramen', 'udon', 'lo mein noodle'], per100g: _n(384, 14.2, 71.3, 4.4, 3.3, 1.9, 21), pieceGrams: 100, traits: {FoodTrait.gluten, FoodTrait.egg}),
  FoodEntry(id: 'noodles_rice', name: 'Rice noodles (dry)', keywords: ['rice noodle', 'rice vermicelli', 'pad thai noodle'], per100g: _n(364, 6.0, 80.2, 0.6, 1.6, 0.1, 182), pieceGrams: 100),
  FoodEntry(id: 'oats', name: 'Rolled oats', keywords: ['oat', 'oats', 'rolled oat', 'oatmeal', 'porridge oat'], per100g: _n(379, 13.2, 67.7, 6.5, 10.1, 1.0, 6), densityGPerMl: 0.34),
  FoodEntry(id: 'quinoa', name: 'Quinoa (uncooked)', keywords: ['quinoa'], per100g: _n(368, 14.1, 64.2, 6.1, 7.0, 0, 5), densityGPerMl: 0.72),
  FoodEntry(id: 'couscous', name: 'Couscous (dry)', keywords: ['couscous'], per100g: _n(376, 12.8, 77.4, 0.6, 5.0, 0, 10), densityGPerMl: 0.73, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'bread_white', name: 'White bread', keywords: ['bread', 'white bread', 'sandwich bread', 'toast'], per100g: _n(266, 7.6, 49.4, 3.3, 2.7, 5.3, 491), pieceGrams: 28, sliceGrams: 28, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'bread_sourdough', name: 'Sourdough bread', keywords: ['sourdough bread', 'sourdough', 'country bread', 'french bread', 'baguette', 'ciabatta', 'boule'], per100g: _n(272, 10.8, 51.9, 2.4, 2.2, 2.3, 602), pieceGrams: 50, sliceGrams: 50, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'bread_brioche', name: 'Brioche', keywords: ['brioche', 'challah'], per100g: _n(346, 8.2, 49.6, 12.8, 2.0, 11.5, 420), pieceGrams: 40, sliceGrams: 40, traits: {FoodTrait.gluten, FoodTrait.egg, FoodTrait.dairy}),
  FoodEntry(id: 'breadcrumbs', name: 'Breadcrumbs', keywords: ['breadcrumb', 'bread crumb', 'panko'], per100g: _n(395, 13.4, 72.0, 5.3, 4.5, 6.2, 732), densityGPerMl: 0.46, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'tortilla', name: 'Flour tortilla', keywords: ['tortilla', 'flour tortilla', 'wrap'], per100g: _n(306, 8.2, 50.0, 7.9, 3.5, 3.0, 600), pieceGrams: 45, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'sourdough_starter', name: 'Sourdough starter', keywords: ['sourdough starter', 'starter', 'levain'], per100g: _n(182, 5.2, 38.2, 0.5, 1.4, 0.2, 1), densityGPerMl: 1.0, traits: {FoodTrait.gluten}),
  FoodEntry(id: 'potato', name: 'Potato', keywords: ['potato', 'russet potato', 'yukon gold potato', 'baby potato'], per100g: _n(77, 2.1, 17.5, 0.1, 2.1, 0.8, 6), densityGPerMl: 0.65, pieceGrams: 213),
  FoodEntry(id: 'sweet_potato', name: 'Sweet potato', keywords: ['sweet potato', 'yam'], per100g: _n(86, 1.6, 20.1, 0.1, 3.0, 4.2, 55), densityGPerMl: 0.6, pieceGrams: 130),

  // --- Dairy & eggs ----------------------------------------------------------
  FoodEntry(id: 'egg', name: 'Egg', keywords: ['egg', 'whole egg', 'large egg'], per100g: _n(143, 12.6, 0.7, 9.5, 0, 0.4, 142), densityGPerMl: 1.03, pieceGrams: 50, traits: {FoodTrait.egg}),
  FoodEntry(id: 'egg_yolk', name: 'Egg yolk', keywords: ['egg yolk', 'yolk'], per100g: _n(322, 15.9, 3.6, 26.5, 0, 0.6, 48), densityGPerMl: 1.03, pieceGrams: 17, traits: {FoodTrait.egg}),
  FoodEntry(id: 'egg_white', name: 'Egg white', keywords: ['egg white'], per100g: _n(52, 10.9, 0.7, 0.2, 0, 0.7, 166), densityGPerMl: 1.03, pieceGrams: 33, traits: {FoodTrait.egg}),
  FoodEntry(id: 'butter', name: 'Butter', keywords: ['butter', 'salted butter'], per100g: _n(717, 0.9, 0.1, 81.1, 0, 0.1, 643), densityGPerMl: 0.96, pieceGrams: 113, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'butter_unsalted', name: 'Unsalted butter', keywords: ['unsalted butter', 'sweet butter', 'cultured butter'], per100g: _n(717, 0.9, 0.1, 81.1, 0, 0.1, 11), densityGPerMl: 0.96, pieceGrams: 113, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'ghee', name: 'Ghee', keywords: ['ghee', 'clarified butter'], per100g: _n(876, 0.3, 0, 99.5, 0, 0, 2), densityGPerMl: 0.91, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'milk_whole', name: 'Whole milk', keywords: ['milk', 'whole milk'], per100g: _n(61, 3.2, 4.8, 3.3, 0, 5.1, 43), densityGPerMl: 1.03, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'milk_low', name: 'Low-fat milk', keywords: ['2 milk', 'low fat milk', 'semi skimmed milk', 'reduced fat milk'], per100g: _n(50, 3.3, 4.8, 2.0, 0, 5.1, 47), densityGPerMl: 1.03, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'milk_skim', name: 'Skim milk', keywords: ['skim milk', 'skimmed milk', 'nonfat milk', 'fat free milk'], per100g: _n(34, 3.4, 5.0, 0.1, 0, 5.1, 42), densityGPerMl: 1.03, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'buttermilk', name: 'Buttermilk', keywords: ['buttermilk'], per100g: _n(40, 3.3, 4.8, 0.9, 0, 4.8, 105), densityGPerMl: 1.03, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'cream_heavy', name: 'Heavy cream', keywords: ['cream', 'heavy cream', 'whipping cream', 'double cream', 'heavy whipping cream', 'whipped cream'], per100g: _n(340, 2.8, 2.8, 36.1, 0, 2.9, 27), densityGPerMl: 1.0, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'cream_sour', name: 'Sour cream', keywords: ['sour cream', 'creme fraiche'], per100g: _n(198, 2.4, 4.6, 19.4, 0, 3.4, 31), densityGPerMl: 0.97, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'yogurt', name: 'Plain yogurt', keywords: ['yogurt', 'yoghurt', 'plain yogurt', 'natural yogurt'], per100g: _n(61, 3.5, 4.7, 3.3, 0, 4.7, 46), densityGPerMl: 1.04, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'yogurt_greek', name: 'Greek yogurt', keywords: ['greek yogurt', 'greek yoghurt', 'strained yogurt', 'skyr'], per100g: _n(73, 10.0, 3.9, 1.9, 0, 3.6, 34), densityGPerMl: 1.04, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'parmesan', name: 'Parmesan', keywords: ['parmesan', 'parmigiano', 'parmigiano reggiano', 'grana padano', 'pecorino', 'pecorino romano', 'hard cheese'], per100g: _n(392, 35.8, 3.2, 25.8, 0, 0.8, 1602), densityGPerMl: 0.42, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'mozzarella', name: 'Mozzarella', keywords: ['mozzarella', 'burrata', 'bocconcini'], per100g: _n(300, 22.2, 2.2, 22.4, 0, 1.0, 627), densityGPerMl: 0.47, pieceGrams: 125, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'cheddar', name: 'Cheddar', keywords: ['cheddar', 'cheese', 'shredded cheese', 'gruyere', 'swiss cheese', 'monterey jack', 'gouda', 'emmental'], per100g: _n(403, 24.9, 1.3, 33.1, 0, 0.5, 621), densityGPerMl: 0.48, sliceGrams: 21, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'ricotta', name: 'Ricotta', keywords: ['ricotta', 'ricotta cheese', 'cottage cheese'], per100g: _n(174, 11.3, 3.0, 13.0, 0, 0.3, 84), densityGPerMl: 1.04, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'cream_cheese', name: 'Cream cheese', keywords: ['cream cheese', 'mascarpone'], per100g: _n(342, 5.9, 4.1, 34.2, 0, 3.2, 321), densityGPerMl: 0.98, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'feta', name: 'Feta', keywords: ['feta', 'goat cheese', 'chevre', 'halloumi'], per100g: _n(264, 14.2, 4.1, 21.3, 0, 4.1, 917), densityGPerMl: 0.63, traits: {FoodTrait.dairy}),

  // --- Fats & oils -----------------------------------------------------------
  FoodEntry(id: 'olive_oil', name: 'Olive oil', keywords: ['olive oil', 'extra virgin olive oil', 'evoo'], per100g: _n(884, 0, 0, 100, 0, 0, 2), densityGPerMl: 0.91),
  FoodEntry(id: 'vegetable_oil', name: 'Vegetable oil', keywords: ['oil', 'vegetable oil', 'canola oil', 'sunflower oil', 'neutral oil', 'grapeseed oil', 'avocado oil', 'peanut oil', 'frying oil', 'cooking oil'], per100g: _n(884, 0, 0, 100, 0, 0, 0), densityGPerMl: 0.92),
  FoodEntry(id: 'sesame_oil', name: 'Sesame oil', keywords: ['sesame oil', 'toasted sesame oil'], per100g: _n(884, 0, 0, 100, 0, 0, 0), densityGPerMl: 0.92, traits: {FoodTrait.sesame}),
  FoodEntry(id: 'coconut_oil', name: 'Coconut oil', keywords: ['coconut oil'], per100g: _n(892, 0, 0, 99.1, 0, 0, 0), densityGPerMl: 0.92),
  FoodEntry(id: 'mayonnaise', name: 'Mayonnaise', keywords: ['mayonnaise', 'mayo', 'aioli'], per100g: _n(680, 1.0, 0.6, 74.9, 0, 0.6, 635), densityGPerMl: 0.93, traits: {FoodTrait.egg}),

  // --- Sweeteners & baking -------------------------------------------------
  FoodEntry(id: 'sugar', name: 'Sugar', keywords: ['sugar', 'granulated sugar', 'white sugar', 'caster sugar', 'superfine sugar', 'cane sugar'], per100g: _n(387, 0, 100, 0, 0, 99.8, 1), densityGPerMl: 0.85),
  FoodEntry(id: 'sugar_brown', name: 'Brown sugar', keywords: ['brown sugar', 'light brown sugar', 'dark brown sugar', 'muscovado', 'demerara sugar', 'coconut sugar'], per100g: _n(380, 0.1, 98.1, 0, 0, 97.0, 28), densityGPerMl: 0.93),
  FoodEntry(id: 'sugar_powdered', name: 'Powdered sugar', keywords: ['powdered sugar', 'icing sugar', 'confectioners sugar'], per100g: _n(389, 0, 99.8, 0, 0, 97.8, 2), densityGPerMl: 0.51),
  FoodEntry(id: 'honey', name: 'Honey', keywords: ['honey'], per100g: _n(304, 0.3, 82.4, 0, 0.2, 82.1, 4), densityGPerMl: 1.42, traits: {FoodTrait.animalDerived}),
  FoodEntry(id: 'maple_syrup', name: 'Maple syrup', keywords: ['maple syrup', 'syrup', 'agave', 'agave syrup', 'golden syrup'], per100g: _n(260, 0, 67.0, 0.1, 0, 60.5, 12), densityGPerMl: 1.33),
  FoodEntry(id: 'chocolate_dark', name: 'Dark chocolate', keywords: ['dark chocolate', 'bittersweet chocolate', 'chocolate'], per100g: _n(598, 7.8, 45.9, 42.6, 10.9, 24.0, 20), densityGPerMl: 0.71),
  FoodEntry(id: 'chocolate_chips', name: 'Chocolate chips', keywords: ['chocolate chip', 'semisweet chocolate', 'milk chocolate', 'chocolate chunk'], per100g: _n(479, 4.2, 63.1, 30.0, 5.9, 54.5, 11), densityGPerMl: 0.71, traits: {FoodTrait.dairy}),
  FoodEntry(id: 'cocoa', name: 'Cocoa powder', keywords: ['cocoa', 'cocoa powder', 'cacao powder'], per100g: _n(228, 19.6, 57.9, 13.7, 37.0, 1.8, 21), densityGPerMl: 0.37),
  FoodEntry(id: 'baking_powder', name: 'Baking powder', keywords: ['baking powder'], per100g: _n(53, 0, 27.7, 0, 0.2, 0, 10600), densityGPerMl: 0.93, isTrace: true),
  FoodEntry(id: 'baking_soda', name: 'Baking soda', keywords: ['baking soda', 'bicarbonate of soda', 'bicarb'], per100g: _n(0, 0, 0, 0, 0, 0, 27360), densityGPerMl: 0.93, isTrace: true),
  FoodEntry(id: 'yeast', name: 'Yeast', keywords: ['yeast', 'active dry yeast', 'instant yeast', 'fresh yeast'], per100g: _n(325, 40.4, 41.2, 7.6, 26.9, 0, 51), densityGPerMl: 0.63, isTrace: true),
  FoodEntry(id: 'vanilla', name: 'Vanilla extract', keywords: ['vanilla', 'vanilla extract', 'vanilla bean', 'vanilla paste'], per100g: _n(288, 0.1, 12.7, 0.1, 0, 12.7, 9), densityGPerMl: 0.88, isTrace: true, traits: {FoodTrait.alcohol}),
  FoodEntry(id: 'gelatin', name: 'Gelatin', keywords: ['gelatin', 'gelatine'], per100g: _n(335, 85.6, 0, 0.1, 0, 0, 196), densityGPerMl: 0.6, traits: {FoodTrait.animalDerived}),

  // --- Meat, poultry & seafood ---------------------------------------------
  FoodEntry(id: 'chicken_breast', name: 'Chicken breast', keywords: ['chicken breast', 'chicken breast fillet', 'chicken tender'], per100g: _n(120, 22.5, 0, 2.6, 0, 0, 45), pieceGrams: 175, traits: {FoodTrait.meat, FoodTrait.poultry}),
  FoodEntry(id: 'chicken_thigh', name: 'Chicken thigh', keywords: ['chicken thigh', 'chicken leg', 'chicken drumstick'], per100g: _n(121, 19.7, 0, 4.1, 0, 0, 95), pieceGrams: 110, traits: {FoodTrait.meat, FoodTrait.poultry}),
  FoodEntry(id: 'chicken', name: 'Chicken', keywords: ['chicken', 'turkey', 'ground chicken', 'ground turkey', 'duck'], per100g: _n(119, 21.4, 0, 3.1, 0, 0, 77), pieceGrams: 175, traits: {FoodTrait.meat, FoodTrait.poultry}),
  FoodEntry(id: 'beef_ground', name: 'Ground beef (85% lean)', keywords: ['ground beef', 'minced beef', 'beef mince', 'mince', 'hamburger'], per100g: _n(215, 18.6, 0, 15.0, 0, 0, 66), traits: {FoodTrait.meat}),
  FoodEntry(id: 'beef', name: 'Beef', keywords: ['beef', 'steak', 'sirloin', 'ribeye', 'flank steak', 'brisket', 'chuck', 'short rib', 'veal', 'lamb'], per100g: _n(176, 20.0, 0, 10.0, 0, 0, 60), pieceGrams: 225, traits: {FoodTrait.meat}),
  FoodEntry(id: 'pork', name: 'Pork', keywords: ['pork', 'pork loin', 'pork chop', 'pork tenderloin', 'pork shoulder'], per100g: _n(143, 21.0, 0, 5.9, 0, 0, 50), pieceGrams: 200, traits: {FoodTrait.meat}),
  FoodEntry(id: 'pork_ground', name: 'Ground pork', keywords: ['ground pork', 'minced pork', 'sausage', 'chorizo', 'italian sausage'], per100g: _n(263, 16.9, 0, 21.2, 0, 0, 56), pieceGrams: 75, traits: {FoodTrait.meat}),
  FoodEntry(id: 'bacon', name: 'Bacon', keywords: ['bacon', 'pancetta', 'guanciale', 'prosciutto', 'ham'], per100g: _n(417, 12.6, 1.3, 39.7, 0, 0, 833), pieceGrams: 23, sliceGrams: 23, traits: {FoodTrait.meat}),
  FoodEntry(id: 'salmon', name: 'Salmon', keywords: ['salmon', 'salmon fillet', 'trout', 'smoked salmon'], per100g: _n(208, 20.4, 0, 13.4, 0, 0, 59), pieceGrams: 170, traits: {FoodTrait.fish}),
  FoodEntry(id: 'white_fish', name: 'White fish', keywords: ['cod', 'tilapia', 'haddock', 'halibut', 'sea bass', 'white fish', 'fish', 'fish fillet', 'snapper'], per100g: _n(82, 17.8, 0, 0.7, 0, 0, 54), pieceGrams: 170, traits: {FoodTrait.fish}),
  FoodEntry(id: 'tuna_canned', name: 'Tuna (canned in water)', keywords: ['tuna', 'canned tuna', 'tuna in water'], per100g: _n(116, 25.5, 0, 0.8, 0, 0, 247), canGrams: 120, traits: {FoodTrait.fish}),
  FoodEntry(id: 'anchovy', name: 'Anchovies', keywords: ['anchovy', 'anchovy fillet'], per100g: _n(210, 28.9, 0, 9.7, 0, 0, 3668), pieceGrams: 4, traits: {FoodTrait.fish}),
  FoodEntry(id: 'shrimp', name: 'Shrimp', keywords: ['shrimp', 'prawn', 'scampi'], per100g: _n(85, 20.1, 0, 0.5, 0, 0, 119), pieceGrams: 13, traits: {FoodTrait.shellfish}),
  FoodEntry(id: 'shellfish', name: 'Shellfish', keywords: ['crab', 'lobster', 'mussel', 'clam', 'scallop', 'oyster', 'squid', 'calamari'], per100g: _n(86, 17.0, 2.5, 1.0, 0, 0, 300), pieceGrams: 20, traits: {FoodTrait.shellfish}),

  // --- Plant proteins, legumes, nuts & seeds --------------------------------
  FoodEntry(id: 'tofu', name: 'Firm tofu', keywords: ['tofu', 'firm tofu', 'silken tofu', 'extra firm tofu'], per100g: _n(144, 15.8, 4.3, 8.7, 2.3, 0.6, 14), pieceGrams: 400, traits: {FoodTrait.soy}),
  FoodEntry(id: 'tempeh', name: 'Tempeh', keywords: ['tempeh'], per100g: _n(192, 20.3, 7.6, 10.8, 0, 0, 9), traits: {FoodTrait.soy}),
  FoodEntry(id: 'edamame', name: 'Edamame', keywords: ['edamame', 'soybean'], per100g: _n(121, 11.9, 8.9, 5.2, 5.2, 2.2, 6), densityGPerMl: 0.65, traits: {FoodTrait.soy}),
  FoodEntry(id: 'chickpeas', name: 'Chickpeas (canned, drained)', keywords: ['chickpea', 'garbanzo', 'garbanzo bean'], per100g: _n(139, 7.0, 22.5, 2.8, 7.6, 3.7, 246), densityGPerMl: 0.66, canGrams: 240),
  FoodEntry(id: 'beans', name: 'Beans (canned, drained)', keywords: ['bean', 'black bean', 'kidney bean', 'cannellini bean', 'pinto bean', 'white bean', 'navy bean', 'butter bean'], per100g: _n(91, 6.0, 16.6, 0.3, 6.9, 0.2, 300), densityGPerMl: 0.72, canGrams: 240),
  FoodEntry(id: 'lentils', name: 'Lentils (dry)', keywords: ['lentil', 'red lentil', 'green lentil', 'split pea'], per100g: _n(352, 24.6, 63.4, 1.1, 10.7, 2.0, 6), densityGPerMl: 0.81),
  FoodEntry(id: 'almonds', name: 'Almonds', keywords: ['almond', 'nut', 'mixed nut', 'hazelnut', 'pistachio', 'macadamia', 'pecan', 'almond flour', 'ground almond'], per100g: _n(579, 21.2, 21.6, 49.9, 12.5, 4.4, 1), densityGPerMl: 0.6, traits: {FoodTrait.treeNut}),
  FoodEntry(id: 'walnuts', name: 'Walnuts', keywords: ['walnut'], per100g: _n(654, 15.2, 13.7, 65.2, 6.7, 2.6, 2), densityGPerMl: 0.49, traits: {FoodTrait.treeNut}),
  FoodEntry(id: 'cashews', name: 'Cashews', keywords: ['cashew'], per100g: _n(553, 18.2, 30.2, 43.9, 3.3, 5.9, 12), densityGPerMl: 0.58, traits: {FoodTrait.treeNut}),
  FoodEntry(id: 'pine_nuts', name: 'Pine nuts', keywords: ['pine nut', 'pignoli'], per100g: _n(673, 13.7, 13.1, 68.4, 3.7, 3.6, 2), densityGPerMl: 0.57, traits: {FoodTrait.treeNut}),
  FoodEntry(id: 'peanuts', name: 'Peanuts', keywords: ['peanut', 'roasted peanut'], per100g: _n(567, 25.8, 16.1, 49.2, 8.5, 4.7, 18), densityGPerMl: 0.6, traits: {FoodTrait.peanut}),
  FoodEntry(id: 'peanut_butter', name: 'Peanut butter', keywords: ['peanut butter'], per100g: _n(588, 25.1, 20.0, 50.4, 6.0, 9.2, 459), densityGPerMl: 1.08, traits: {FoodTrait.peanut}),
  FoodEntry(id: 'tahini', name: 'Tahini', keywords: ['tahini', 'sesame paste'], per100g: _n(595, 17.0, 21.2, 53.8, 9.3, 0.5, 115), densityGPerMl: 1.01, traits: {FoodTrait.sesame}),
  FoodEntry(id: 'sesame_seeds', name: 'Sesame seeds', keywords: ['sesame seed', 'sesame'], per100g: _n(573, 17.7, 23.5, 49.7, 11.8, 0.3, 11), densityGPerMl: 0.61, traits: {FoodTrait.sesame}),
  FoodEntry(id: 'seeds', name: 'Seeds', keywords: ['chia seed', 'flaxseed', 'flax seed', 'pumpkin seed', 'sunflower seed', 'hemp seed', 'pepita'], per100g: _n(520, 20.0, 30.0, 40.0, 25.0, 1.5, 12), densityGPerMl: 0.65),
  FoodEntry(id: 'coconut_milk', name: 'Coconut milk (canned)', keywords: ['coconut milk', 'coconut cream'], per100g: _n(197, 2.0, 2.8, 21.3, 0, 3.3, 13), densityGPerMl: 0.98, canGrams: 400),

  // --- Vegetables -----------------------------------------------------------
  FoodEntry(id: 'onion', name: 'Onion', keywords: ['onion', 'yellow onion', 'white onion', 'red onion', 'sweet onion', 'shallot'], per100g: _n(40, 1.1, 9.3, 0.1, 1.7, 4.2, 4), densityGPerMl: 0.68, pieceGrams: 110),
  FoodEntry(id: 'scallion', name: 'Scallions', keywords: ['scallion', 'green onion', 'spring onion', 'chive', 'leek'], per100g: _n(32, 1.8, 7.3, 0.2, 2.6, 2.3, 16), densityGPerMl: 0.42, pieceGrams: 15, bunchGrams: 100),
  FoodEntry(id: 'garlic', name: 'Garlic', keywords: ['garlic', 'garlic clove', 'minced garlic'], per100g: _n(149, 6.4, 33.1, 0.5, 2.1, 1.0, 17), densityGPerMl: 0.61, pieceGrams: 3, cloveGrams: 3),
  FoodEntry(id: 'ginger', name: 'Ginger', keywords: ['ginger', 'fresh ginger', 'ginger root'], per100g: _n(80, 1.8, 17.8, 0.8, 2.0, 1.7, 13), densityGPerMl: 0.4, pieceGrams: 15),
  FoodEntry(id: 'tomato', name: 'Tomato', keywords: ['tomato', 'heirloom tomato', 'roma tomato', 'plum tomato', 'vine tomato'], per100g: _n(18, 0.9, 3.9, 0.2, 1.2, 2.6, 5), densityGPerMl: 0.76, pieceGrams: 123, canGrams: 400),
  FoodEntry(id: 'tomato_cherry', name: 'Cherry tomatoes', keywords: ['cherry tomato', 'grape tomato'], per100g: _n(18, 0.9, 3.9, 0.2, 1.2, 2.6, 5), densityGPerMl: 0.62, pieceGrams: 17),
  FoodEntry(id: 'tomato_canned', name: 'Canned tomatoes', keywords: ['canned tomato', 'crushed tomato', 'diced tomato', 'whole peeled tomato', 'san marzano', 'san marzano tomato', 'tomato puree', 'passata', 'chopped tomato'], per100g: _n(16, 0.8, 3.5, 0.3, 1.9, 2.4, 115), densityGPerMl: 1.03, canGrams: 400),
  FoodEntry(id: 'tomato_paste', name: 'Tomato paste', keywords: ['tomato paste', 'tomato concentrate'], per100g: _n(82, 4.3, 18.9, 0.5, 4.1, 12.2, 59), densityGPerMl: 1.08, canGrams: 170),
  FoodEntry(id: 'tomato_sauce', name: 'Tomato sauce', keywords: ['tomato sauce', 'marinara', 'marinara sauce', 'pasta sauce'], per100g: _n(29, 1.3, 5.3, 0.5, 1.5, 3.6, 474), densityGPerMl: 1.04, canGrams: 425),
  FoodEntry(id: 'carrot', name: 'Carrot', keywords: ['carrot', 'baby carrot'], per100g: _n(41, 0.9, 9.6, 0.2, 2.8, 4.7, 69), densityGPerMl: 0.54, pieceGrams: 61),
  FoodEntry(id: 'celery', name: 'Celery', keywords: ['celery', 'celery stalk', 'celery rib'], per100g: _n(14, 0.7, 3.0, 0.2, 1.6, 1.3, 80), densityGPerMl: 0.51, pieceGrams: 40, bunchGrams: 450),
  FoodEntry(id: 'bell_pepper', name: 'Bell pepper', keywords: ['bell pepper', 'red pepper', 'green pepper', 'yellow pepper', 'capsicum', 'sweet pepper'], per100g: _n(31, 1.0, 6.0, 0.3, 2.1, 4.2, 4), densityGPerMl: 0.63, pieceGrams: 119),
  FoodEntry(id: 'chili', name: 'Chili pepper', keywords: ['jalapeno', 'jalapeno pepper', 'chili', 'chile', 'chili pepper', 'serrano', 'thai chili', 'bird eye chili', 'habanero'], per100g: _n(29, 0.9, 6.5, 0.4, 2.8, 4.1, 3), densityGPerMl: 0.55, pieceGrams: 14),
  FoodEntry(id: 'spinach', name: 'Spinach', keywords: ['spinach', 'baby spinach'], per100g: _n(23, 2.9, 3.6, 0.4, 2.2, 0.4, 79), densityGPerMl: 0.13, bunchGrams: 340),
  FoodEntry(id: 'leafy_greens', name: 'Leafy greens', keywords: ['kale', 'chard', 'swiss chard', 'collard green', 'arugula', 'rocket', 'mixed green', 'salad green', 'watercress', 'bok choy', 'pak choi'], per100g: _n(35, 2.9, 4.4, 1.5, 4.1, 1.0, 53), densityGPerMl: 0.15, bunchGrams: 200),
  FoodEntry(id: 'lettuce', name: 'Lettuce', keywords: ['lettuce', 'romaine', 'iceberg', 'butter lettuce', 'little gem'], per100g: _n(17, 1.2, 3.3, 0.3, 2.1, 1.2, 8), densityGPerMl: 0.2, pieceGrams: 600),
  FoodEntry(id: 'cabbage', name: 'Cabbage', keywords: ['cabbage', 'red cabbage', 'napa cabbage', 'savoy cabbage', 'coleslaw mix'], per100g: _n(25, 1.3, 5.8, 0.1, 2.5, 3.2, 18), densityGPerMl: 0.3, pieceGrams: 900),
  FoodEntry(id: 'broccoli', name: 'Broccoli', keywords: ['broccoli', 'broccolini', 'cauliflower', 'brussels sprout'], per100g: _n(34, 2.8, 6.6, 0.4, 2.6, 1.7, 33), densityGPerMl: 0.39, pieceGrams: 300),
  FoodEntry(id: 'mushroom', name: 'Mushrooms', keywords: ['mushroom', 'cremini', 'button mushroom', 'shiitake', 'portobello', 'oyster mushroom', 'porcini', 'chanterelle'], per100g: _n(22, 3.1, 3.3, 0.3, 1.0, 2.0, 5), densityGPerMl: 0.3, pieceGrams: 18),
  FoodEntry(id: 'zucchini', name: 'Zucchini', keywords: ['zucchini', 'courgette', 'summer squash', 'yellow squash'], per100g: _n(17, 1.2, 3.1, 0.3, 1.0, 2.5, 8), densityGPerMl: 0.53, pieceGrams: 196),
  FoodEntry(id: 'eggplant', name: 'Eggplant', keywords: ['eggplant', 'aubergine'], per100g: _n(25, 1.0, 5.9, 0.2, 3.0, 3.5, 2), densityGPerMl: 0.35, pieceGrams: 450),
  FoodEntry(id: 'cucumber', name: 'Cucumber', keywords: ['cucumber'], per100g: _n(15, 0.7, 3.6, 0.1, 0.5, 1.7, 2), densityGPerMl: 0.55, pieceGrams: 250),
  FoodEntry(id: 'corn', name: 'Sweet corn', keywords: ['corn', 'sweet corn', 'corn kernel', 'sweetcorn'], per100g: _n(86, 3.3, 18.7, 1.4, 2.0, 6.3, 15), densityGPerMl: 0.61, pieceGrams: 100, canGrams: 280),
  FoodEntry(id: 'peas', name: 'Green peas', keywords: ['pea', 'green pea', 'frozen pea', 'snow pea', 'sugar snap pea'], per100g: _n(81, 5.4, 14.5, 0.4, 5.7, 5.7, 5), densityGPerMl: 0.61),
  FoodEntry(id: 'green_beans', name: 'Green beans', keywords: ['green bean', 'string bean', 'haricot vert', 'asparagus'], per100g: _n(31, 1.8, 7.0, 0.2, 2.7, 3.3, 6), densityGPerMl: 0.47, bunchGrams: 450),
  FoodEntry(id: 'squash', name: 'Winter squash', keywords: ['butternut squash', 'pumpkin', 'acorn squash', 'squash', 'kabocha'], per100g: _n(45, 1.0, 11.7, 0.1, 2.0, 2.2, 4), densityGPerMl: 0.6, pieceGrams: 1000),
  FoodEntry(id: 'avocado', name: 'Avocado', keywords: ['avocado'], per100g: _n(160, 2.0, 8.5, 14.7, 6.7, 0.7, 7), densityGPerMl: 0.95, pieceGrams: 150),
  FoodEntry(id: 'olives', name: 'Olives', keywords: ['olive', 'kalamata olive', 'black olive', 'green olive', 'caper'], per100g: _n(115, 0.8, 6.3, 10.7, 3.2, 0, 735), densityGPerMl: 0.6, pieceGrams: 4),
  FoodEntry(id: 'seaweed', name: 'Nori / seaweed', keywords: ['nori', 'seaweed', 'kombu', 'wakame', 'nori sheet'], per100g: _n(35, 5.8, 5.1, 0.3, 0.3, 0.5, 48), pieceGrams: 3, isTrace: true),

  // --- Fruit ----------------------------------------------------------------
  FoodEntry(id: 'lemon', name: 'Lemon', keywords: ['lemon', 'meyer lemon'], per100g: _n(29, 1.1, 9.3, 0.3, 2.8, 2.5, 2), pieceGrams: 58),
  FoodEntry(id: 'lemon_juice', name: 'Lemon juice', keywords: ['lemon juice', 'lime juice', 'citrus juice'], per100g: _n(22, 0.4, 6.9, 0.2, 0.3, 2.5, 1), densityGPerMl: 1.03),
  FoodEntry(id: 'citrus_zest', name: 'Citrus zest', keywords: ['lemon zest', 'lime zest', 'orange zest', 'zest', 'lemon peel'], per100g: _n(47, 1.5, 16.0, 0.3, 10.6, 4.2, 6), densityGPerMl: 0.4, isTrace: true),
  FoodEntry(id: 'lime', name: 'Lime', keywords: ['lime', 'key lime'], per100g: _n(30, 0.7, 10.5, 0.2, 2.8, 1.7, 2), pieceGrams: 67),
  FoodEntry(id: 'orange', name: 'Orange', keywords: ['orange', 'clementine', 'mandarin', 'tangerine', 'blood orange'], per100g: _n(47, 0.9, 11.8, 0.1, 2.4, 9.4, 0), pieceGrams: 131),
  FoodEntry(id: 'orange_juice', name: 'Orange juice', keywords: ['orange juice', 'juice'], per100g: _n(45, 0.7, 10.4, 0.2, 0.2, 8.4, 1), densityGPerMl: 1.04),
  FoodEntry(id: 'apple', name: 'Apple', keywords: ['apple', 'granny smith apple', 'pear'], per100g: _n(52, 0.3, 13.8, 0.2, 2.4, 10.4, 1), densityGPerMl: 0.53, pieceGrams: 182),
  FoodEntry(id: 'banana', name: 'Banana', keywords: ['banana', 'plantain'], per100g: _n(89, 1.1, 22.8, 0.3, 2.6, 12.2, 1), densityGPerMl: 0.95, pieceGrams: 118),
  FoodEntry(id: 'strawberry', name: 'Strawberries', keywords: ['strawberry'], per100g: _n(32, 0.7, 7.7, 0.3, 2.0, 4.9, 1), densityGPerMl: 0.64, pieceGrams: 12),
  FoodEntry(id: 'blueberry', name: 'Blueberries', keywords: ['blueberry'], per100g: _n(57, 0.7, 14.5, 0.3, 2.4, 10.0, 1), densityGPerMl: 0.63),
  FoodEntry(id: 'berries', name: 'Mixed berries', keywords: ['berry', 'mixed berry', 'raspberry', 'blackberry', 'wild berry', 'cherry', 'cranberry'], per100g: _n(47, 0.9, 11.4, 0.4, 3.6, 6.4, 1), densityGPerMl: 0.59),
  FoodEntry(id: 'mango', name: 'Mango', keywords: ['mango', 'pineapple', 'papaya', 'peach', 'nectarine', 'apricot', 'plum'], per100g: _n(60, 0.8, 15.0, 0.4, 1.6, 13.7, 1), densityGPerMl: 0.69, pieceGrams: 200),
  FoodEntry(id: 'grapes', name: 'Grapes', keywords: ['grape'], per100g: _n(69, 0.7, 18.1, 0.2, 0.9, 15.5, 2), densityGPerMl: 0.64, pieceGrams: 5),
  FoodEntry(id: 'raisins', name: 'Raisins & dried fruit', keywords: ['raisin', 'dried fruit', 'date', 'dried cranberry', 'dried apricot', 'prune', 'fig'], per100g: _n(299, 3.1, 79.2, 0.5, 3.7, 59.2, 11), densityGPerMl: 0.65, pieceGrams: 8),

  // --- Sauces, condiments & liquids ------------------------------------------
  FoodEntry(id: 'soy_sauce', name: 'Soy sauce', keywords: ['soy sauce', 'tamari', 'shoyu', 'light soy sauce', 'dark soy sauce'], per100g: _n(53, 8.1, 4.9, 0.6, 0.8, 0.4, 5493), densityGPerMl: 1.08, traits: {FoodTrait.soy, FoodTrait.gluten}),
  FoodEntry(id: 'fish_sauce', name: 'Fish sauce', keywords: ['fish sauce'], per100g: _n(35, 5.1, 3.6, 0, 0, 3.6, 7851), densityGPerMl: 1.2, traits: {FoodTrait.fish}),
  FoodEntry(id: 'oyster_sauce', name: 'Oyster sauce', keywords: ['oyster sauce', 'hoisin', 'hoisin sauce', 'teriyaki sauce'], per100g: _n(51, 1.4, 11.0, 0.3, 0.3, 0, 2733), densityGPerMl: 1.15, traits: {FoodTrait.shellfish}),
  FoodEntry(id: 'miso', name: 'Miso', keywords: ['miso', 'miso paste', 'white miso', 'red miso'], per100g: _n(198, 12.8, 25.4, 6.0, 5.4, 6.2, 3728), densityGPerMl: 1.16, traits: {FoodTrait.soy}),
  FoodEntry(id: 'vinegar', name: 'Vinegar', keywords: ['vinegar', 'white vinegar', 'rice vinegar', 'apple cider vinegar', 'red wine vinegar', 'white wine vinegar', 'sherry vinegar', 'mirin'], per100g: _n(21, 0, 0.9, 0, 0, 0.4, 5), densityGPerMl: 1.01, isTrace: true),
  FoodEntry(id: 'balsamic', name: 'Balsamic vinegar', keywords: ['balsamic', 'balsamic vinegar', 'balsamic glaze'], per100g: _n(88, 0.5, 17.0, 0, 0, 15.0, 23), densityGPerMl: 1.06),
  FoodEntry(id: 'mustard', name: 'Mustard', keywords: ['mustard', 'dijon', 'dijon mustard', 'whole grain mustard', 'yellow mustard'], per100g: _n(60, 3.7, 5.8, 3.3, 4.0, 0.9, 1104), densityGPerMl: 1.01),
  FoodEntry(id: 'ketchup', name: 'Ketchup', keywords: ['ketchup', 'catsup', 'bbq sauce', 'barbecue sauce'], per100g: _n(101, 1.0, 27.4, 0.1, 0.3, 21.3, 907), densityGPerMl: 1.15),
  FoodEntry(id: 'hot_sauce', name: 'Hot sauce', keywords: ['hot sauce', 'sriracha', 'tabasco', 'chili sauce', 'gochujang', 'harissa', 'chili paste', 'curry paste', 'spice paste', 'red curry paste', 'green curry paste', 'worcestershire', 'worcestershire sauce'], per100g: _n(60, 1.5, 9.0, 1.5, 1.0, 6.0, 2100), densityGPerMl: 1.05, isTrace: true),
  FoodEntry(id: 'broth_chicken', name: 'Chicken broth', keywords: ['chicken broth', 'chicken stock', 'bone broth', 'beef broth', 'beef stock', 'stock', 'broth'], per100g: _n(15, 2.0, 0.4, 0.5, 0, 0.2, 343), densityGPerMl: 1.0, traits: {FoodTrait.meat}),
  FoodEntry(id: 'broth_veg', name: 'Vegetable broth', keywords: ['vegetable broth', 'vegetable stock', 'dashi', 'dashi stock'], per100g: _n(8, 0.2, 1.4, 0.1, 0, 0.6, 300), densityGPerMl: 1.0),
  FoodEntry(id: 'wine', name: 'Wine', keywords: ['wine', 'white wine', 'red wine', 'dry white wine', 'sake', 'beer'], per100g: _n(83, 0.1, 2.6, 0, 0, 1.0, 5), densityGPerMl: 0.99, traits: {FoodTrait.alcohol}),
  FoodEntry(id: 'water', name: 'Water', keywords: ['water', 'ice', 'warm water', 'cold water', 'boiling water', 'ice water', 'pasta water'], per100g: _n(0, 0, 0, 0, 0, 0, 0), densityGPerMl: 1.0, isTrace: true),

  // --- Herbs, spices & seasoning (trace) ---------------------------------------
  FoodEntry(id: 'salt', name: 'Salt', keywords: ['salt', 'sea salt', 'kosher salt', 'table salt', 'flaky salt', 'flaky sea salt', 'fleur de sel'], per100g: _n(0, 0, 0, 0, 0, 0, 38758), densityGPerMl: 1.22, isTrace: true),
  FoodEntry(id: 'black_pepper', name: 'Black pepper', keywords: ['pepper', 'black pepper', 'peppercorn', 'white pepper', 'cracked black pepper'], per100g: _n(251, 10.4, 64.0, 3.3, 25.3, 0.6, 20), densityGPerMl: 0.47, isTrace: true),
  FoodEntry(id: 'chili_flakes', name: 'Chili flakes', keywords: ['red pepper flake', 'chili flake', 'crushed red pepper', 'cayenne', 'cayenne pepper', 'chili powder', 'paprika', 'smoked paprika', 'gochugaru'], per100g: _n(318, 12.0, 56.6, 17.3, 27.2, 10.3, 30), densityGPerMl: 0.45, isTrace: true),
  FoodEntry(id: 'ground_spice', name: 'Ground spices', keywords: ['cumin', 'coriander', 'turmeric', 'cinnamon', 'nutmeg', 'curry powder', 'garam masala', 'allspice', 'ground clove', 'cardamom', 'five spice', 'garlic powder', 'onion powder', 'spice', 'ground ginger', 'star anise', 'saffron', 'fennel seed', 'mustard seed'], per100g: _n(300, 12.0, 55.0, 10.0, 30.0, 5.0, 50), densityGPerMl: 0.5, isTrace: true),
  FoodEntry(id: 'dried_herbs', name: 'Dried herbs', keywords: ['dried oregano', 'oregano', 'dried thyme', 'italian seasoning', 'herbes de provence', 'dried basil', 'bay leaf', 'dried herb', 'za atar', 'sumac'], per100g: _n(265, 9.0, 68.9, 4.3, 42.5, 4.1, 25), densityGPerMl: 0.2, pieceGrams: 0.2, isTrace: true),
  FoodEntry(id: 'fresh_herbs', name: 'Fresh herbs', keywords: ['basil', 'parsley', 'cilantro', 'coriander leaf', 'mint', 'dill', 'thyme', 'rosemary', 'sage', 'tarragon', 'chervil', 'fresh herb', 'herb', 'basil leaf', 'microgreen'], per100g: _n(36, 3.0, 6.3, 0.8, 3.3, 0.9, 56), densityGPerMl: 0.1, pieceGrams: 0.5, bunchGrams: 30, isTrace: true),
]);
