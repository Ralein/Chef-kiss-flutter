import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'recipe_image.dart';

/// Picks hand-drawn doodles and postage stamps for food names, so logs,
/// scans and empty pages get illustrations that match what's on the plate.
class FoodArt {
  FoodArt._();

  /// Keyword → doodle id. More specific phrases come first.
  static const _doodles = <(String, String)>[
    ('avocado toast', 'food-avocado-toast'),
    ('french toast', 'food-french-toast'),
    ('hot dog', 'food-hotdog'),
    ('ice cream', 'food-ice-cream'),
    ('iced coffee', 'food-iced-coffee'),
    ('iced latte', 'food-iced-coffee'),
    ('bubble tea', 'food-boba'),
    ('spring roll', 'food-spring-roll'),
    ('pad thai', 'food-pad-thai'),
    ('dim sum', 'food-dimsum-dish'),
    ('cinnamon roll', 'food-cinnamon-roll'),
    ('english muffin', 'food-english-muffin'),
    ('boiled egg', 'food-hard-egg'),
    ('hard egg', 'food-hard-egg'),
    ('bell pepper', 'food-bell-pepper'),
    ('fortune cookie', 'food-fortune-cookie'),
    ('wine bottle', 'food-wine-bottle'),
    ('pizza', 'food-pizza-slice'),
    ('burger', 'food-burger'),
    ('fries', 'food-fries'),
    ('taco', 'food-taco'),
    ('burrito', 'food-burrito'),
    ('steak', 'food-steak'),
    ('beef', 'food-steak'),
    ('chicken', 'food-chicken-leg'),
    ('drumstick', 'food-chicken-leg'),
    ('salmon', 'food-salmon-fillet'),
    ('fish', 'food-salmon-fillet'),
    ('cheese', 'food-cheese-wedge'),
    ('ham', 'food-ham-roast'),
    ('shawarma', 'food-shawarma'),
    ('kebab', 'food-skewer'),
    ('skewer', 'food-skewer'),
    ('yakitori', 'food-skewer'),
    ('wrap', 'food-shawarma'),
    ('sandwich', 'food-club-sandwich'),
    ('paella', 'food-paella'),
    ('risotto', 'food-paella'),
    ('ramen', 'food-ramen-dish'),
    ('noodle', 'food-ramen-dish'),
    ('pho', 'food-ramen-dish'),
    ('soup', 'food-soup-bowl'),
    ('stew', 'food-soup-bowl'),
    ('broth', 'food-soup-bowl'),
    ('curry', 'food-soup-bowl'),
    ('chili con', 'food-soup-bowl'),
    ('nigiri', 'food-sushi-nigiri'),
    ('maki', 'food-maki-roll'),
    ('sushi', 'food-sushi-set'),
    ('dumpling', 'food-dimsum-dish'),
    ('gyoza', 'food-gyoza-dish'),
    ('bao', 'food-bao-dish'),
    ('onigiri', 'food-onigiri-dish'),
    ('rice', 'food-onigiri-dish'),
    ('takoyaki', 'food-takoyaki-dish'),
    ('tempura', 'food-tempura-dish'),
    ('bento', 'food-bento-dish'),
    ('bibimbap', 'food-bibimbap-dish'),
    ('edamame', 'food-edamame-dish'),
    ('matcha', 'food-matcha-dish'),
    ('donut', 'food-donut'),
    ('doughnut', 'food-donut'),
    ('cupcake', 'food-cupcake'),
    ('cake', 'food-cake-slice'),
    ('macaron', 'food-macaron'),
    ('sundae', 'food-sundae'),
    ('popsicle', 'food-popsicle'),
    ('chocolate', 'food-chocolate'),
    ('cookie', 'food-cookie'),
    ('muffin', 'food-muffin'),
    ('crêpe', 'food-crepe'),
    ('crepe', 'food-crepe'),
    ('flan', 'food-flan'),
    ('churro', 'food-churros'),
    ('tart', 'food-tart'),
    ('pie', 'food-tart'),
    ('gingerbread', 'food-gingerbread'),
    ('croissant', 'food-croissant'),
    ('baguette', 'food-baguette'),
    ('sourdough', 'food-sourdough'),
    ('bagel', 'food-bagel'),
    ('pancake', 'food-pancakes'),
    ('waffle', 'food-waffle-plate'),
    ('croque', 'food-croque'),
    ('brioche', 'food-brioche'),
    ('pita', 'food-pita'),
    ('pretzel', 'food-pretzel'),
    ('cereal', 'food-cereal'),
    ('granola', 'food-cereal'),
    ('oat', 'food-cereal'),
    ('porridge', 'food-cereal'),
    ('toast', 'food-honey-toast'),
    ('bread', 'food-bread-loaf'),
    ('loaf', 'food-bread-loaf'),
    ('breakfast', 'food-breakfast-plate'),
    ('eggplant', 'food-eggplant'),
    ('aubergine', 'food-eggplant'),
    ('egg', 'food-fried-egg'),
    ('omelet', 'food-fried-egg'),
    ('beer', 'food-beer-mug'),
    ('latte', 'food-coffee-cup'),
    ('coffee', 'food-coffee-cup'),
    ('espresso', 'food-coffee-cup'),
    ('cappuccino', 'food-coffee-cup'),
    ('boba', 'food-boba'),
    ('wine', 'food-wine-glass'),
    ('tea', 'food-teapot'),
    ('milk', 'food-milk-carton'),
    ('coconut', 'food-coconut-drink'),
    ('smoothie', 'food-coconut-drink'),
    ('tomato', 'food-tomato'),
    ('pasta', 'food-tomato'),
    ('spaghetti', 'food-tomato'),
    ('basil', 'food-basil'),
    ('pesto', 'food-basil'),
    ('salad', 'food-basil'),
    ('greens', 'food-basil'),
    ('garlic', 'food-garlic'),
    ('avocado', 'food-avocado'),
    ('guacamole', 'food-avocado'),
    ('lemon', 'food-lemon'),
    ('lime', 'food-lime'),
    ('chili', 'food-chili'),
    ('chilli', 'food-chili'),
    ('jalape', 'food-chili'),
    ('pepper', 'food-bell-pepper'),
    ('mushroom', 'food-mushroom'),
    ('carrot', 'food-carrot'),
    ('broccoli', 'food-broccoli'),
    ('strawberr', 'food-strawberry'),
    ('berry', 'food-strawberry'),
    ('apple', 'food-apple'),
    ('banana', 'food-banana'),
  ];

  static const _stamps = <(String, String)>[
    ('pizza', 'postage-pizza'),
    ('sushi', 'postage-sushi'),
    ('maki', 'postage-sushi'),
    ('taco', 'postage-taco'),
    ('burrito', 'postage-taco'),
    ('ramen', 'postage-ramen'),
    ('noodle', 'postage-ramen'),
    ('croissant', 'postage-croissant'),
    ('baguette', 'postage-baguette'),
    ('bread', 'postage-baguette'),
    ('sourdough', 'postage-baguette'),
    ('cheese', 'postage-cheese'),
    ('wine', 'postage-wine'),
    ('chili', 'postage-chili'),
    ('mushroom', 'postage-mushroom'),
    ('lemon', 'postage-lemon'),
    ('avocado', 'postage-avocado'),
    ('espresso', 'postage-espresso'),
    ('coffee', 'postage-espresso'),
    ('latte', 'postage-espresso'),
    ('honey', 'postage-honey'),
    ('strawberr', 'postage-strawberry'),
    ('berry', 'postage-strawberry'),
    ('crêpe', 'postage-strawberry'),
    ('crepe', 'postage-strawberry'),
    ('basil', 'postage-basil'),
    ('pesto', 'postage-basil'),
    ('salad', 'postage-basil'),
    ('olive', 'postage-oliveoil'),
    ('tomato', 'postage-tomato'),
    ('pasta', 'postage-tomato'),
    ('spaghetti', 'postage-tomato'),
    ('egg', 'postage-skillet'),
    ('fried', 'postage-skillet'),
    ('steak', 'postage-skillet'),
    ('chicken', 'postage-skillet'),
  ];

  static final _patterns = <String, RegExp>{};

  /// Keywords match at the start of a word, so "tacos" finds taco but
  /// "steamed" doesn't find tea.
  static String? _match(List<(String, String)> table, Iterable<String> texts) {
    for (final raw in texts) {
      final text = raw.toLowerCase();
      for (final (keyword, id) in table) {
        final pattern = _patterns.putIfAbsent(keyword, () => RegExp('(^|[^a-zà-ÿ])${RegExp.escape(keyword)}'));
        if (pattern.hasMatch(text)) return id;
      }
    }
    return null;
  }

  /// A doodle for the first of [texts] that mentions a known food, or null.
  static String? doodleFor(Iterable<String> texts) => _match(_doodles, texts);

  /// A postage stamp for the first of [texts] that mentions a known food.
  static String stampFor(Iterable<String> texts) => _match(_stamps, texts) ?? 'postage-skillet';

  /// A stable "random" doodle for things with no recognisable food.
  static String fallbackDoodle(String seed) {
    const friendly = ['food-whisk', 'food-tomato', 'food-basil', 'food-lemon', 'food-croissant', 'food-teapot'];
    return friendly[seed.hashCode.abs() % friendly.length];
  }
}

/// A single doodle, sized and tilted.
class FoodDoodle extends StatelessWidget {
  final String id;
  final double size;
  final double rotation;
  final String? semanticLabel;
  const FoodDoodle({super.key, required this.id, this.size = 48, this.rotation = 0, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final art = SizedBox.square(
      dimension: size,
      child: SvgFoodDoodleWidget(id: id, size: size, rotation: rotation),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: art)
        : Semantics(image: true, label: semanticLabel, child: art);
  }
}

/// A meal's photo, or a simple utensils icon when there is none. Fills its
/// parent. [homeCooked] adds a small chef-hat badge (meals cooked from your
/// own recipes).
class FoodPicture extends StatelessWidget {
  final String? imagePath;
  final String title;
  final bool homeCooked;
  final double radius;
  const FoodPicture({super.key, required this.imagePath, required this.title, this.homeCooked = false, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return LayoutBuilder(builder: (context, box) {
      final side = math.min(box.maxWidth, box.maxHeight);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: hasImage
                  ? RecipeImage(source: imagePath, placeholderIcon: LucideIcons.utensils)
                  : ColoredBox(
                      color: c.surfaceRaised,
                      child: Center(child: Icon(LucideIcons.utensils, size: side * 0.4, color: c.contentSecondary)),
                    ),
            ),
          ),
          if (homeCooked)
            Positioned(
              right: -4,
              bottom: -4,
              child: Tooltip(
                message: 'Cooked from your recipe',
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: c.accentHerb,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surfacePaper, width: 2),
                  ),
                  child: Icon(LucideIcons.chefHat, size: math.max(11, side * 0.2), color: c.onAccent),
                ),
              ),
            ),
        ],
      );
    });
  }
}
