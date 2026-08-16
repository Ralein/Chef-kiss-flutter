import 'package:recipe_domain/recipe_domain.dart';
import '../domain/illustration_asset.dart';

class IllustrationMatcher {
  static const List<IllustrationAsset> catalog = [
    IllustrationAsset(
      id: 'asset_pasta',
      canonicalKey: 'pasta',
      displayName: 'Pasta & Noodles',
      matchKeywords: ['pasta', 'spaghetti', 'noodle', 'fettuccine', 'carbonara', 'lasagna', 'ramen', 'penne', 'macaroni'],
      iconCodePoint: 0xe517, // Icons.ramen_dining
      category: 'pasta',
    ),
    IllustrationAsset(
      id: 'asset_bread',
      canonicalKey: 'bread',
      displayName: 'Bread & Baking',
      matchKeywords: ['bread', 'focaccia', 'sourdough', 'loaf', 'toast', 'bake', 'cake', 'cookie', 'croissant', 'muffin', 'pie'],
      iconCodePoint: 0xe0c6, // Icons.bakery_dining
      category: 'baking',
    ),
    IllustrationAsset(
      id: 'asset_soup',
      canonicalKey: 'soup',
      displayName: 'Soups & Stews',
      matchKeywords: ['soup', 'stew', 'chowder', 'broth', 'bisque', 'chili', 'curry'],
      iconCodePoint: 0xe5e1, // Icons.soup_kitchen
      category: 'soup',
    ),
    IllustrationAsset(
      id: 'asset_salad',
      canonicalKey: 'salad',
      displayName: 'Fresh Greens & Salads',
      matchKeywords: ['salad', 'greens', 'lettuce', 'herb', 'slaw', 'arugula', 'spinach', 'kale'],
      iconCodePoint: 0xe212, // Icons.eco
      category: 'salad',
    ),
    IllustrationAsset(
      id: 'asset_eggs',
      canonicalKey: 'eggs',
      displayName: 'Eggs & Breakfast',
      matchKeywords: ['egg', 'eggs', 'shakshuka', 'omelet', 'frittata', 'benedict', 'pancake', 'waffle'],
      iconCodePoint: 0xe21b, // Icons.egg_alt
      category: 'breakfast',
    ),
    IllustrationAsset(
      id: 'asset_grill',
      canonicalKey: 'grill',
      displayName: 'Roast & Grill',
      matchKeywords: ['roast', 'grill', 'chicken', 'steak', 'pork', 'beef', 'salmon', 'burger', 'barbecue', 'bbq'],
      iconCodePoint: 0xe472, // Icons.outdoor_grill
      category: 'mains',
    ),
  ];

  /// Finds the best matching illustration asset for a given recipe
  IllustrationAsset matchRecipe(Recipe recipe) {
    final titleLower = recipe.title.toLowerCase();
    final summaryLower = recipe.summary?.toLowerCase() ?? '';
    final ingredientsText = recipe.ingredients.map((i) => i.displayName.toLowerCase()).join(' ');

    IllustrationAsset? bestAsset;
    int maxScore = 0;

    for (final asset in catalog) {
      int score = 0;
      for (final kw in asset.matchKeywords) {
        if (titleLower.contains(kw)) score += 10;
        if (summaryLower.contains(kw)) score += 3;
        if (ingredientsText.contains(kw)) score += 1;
      }
      if (score > maxScore) {
        maxScore = score;
        bestAsset = asset;
      }
    }

    return bestAsset ?? catalog.first;
  }
}
