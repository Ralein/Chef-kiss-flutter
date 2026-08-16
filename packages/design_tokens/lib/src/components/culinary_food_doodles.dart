// GENERATED PIXEL-PERFECT VECTOR SVG CATALOG
// 100% exact parity with Next.js CulinaryFoodDoodles.tsx

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'culinary_postage_stamps.dart';

class SvgFoodDoodleWidget extends StatelessWidget {
  final String id;
  final double size;
  final double rotation;
  final Color? color;

  const SvgFoodDoodleWidget({
    super.key,
    required this.id,
    this.size = 56,
    this.rotation = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rawSvg = rawFoodDoodleSvgMap[id] ?? rawFoodDoodleSvgMap['food-donut']!;
    return Transform.rotate(
      angle: rotation * (math.pi / 180),
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.string(
          rawSvg,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

final List<CulinaryStampDef> foodDoodleDefs = [
  CulinaryStampDef(
    id: 'food-donut',
    name: 'Strawberry Donut',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-donut', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-cake-slice',
    name: 'Layer Cake Slice',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-cake-slice', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-cupcake',
    name: 'Cherry Cupcake',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-cupcake', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-macaron',
    name: 'Macaron Duo',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-macaron', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-ice-cream',
    name: 'Ice Cream Cone',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-ice-cream', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-sundae',
    name: 'Sundae Glass',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-sundae', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-popsicle',
    name: 'Matcha Ice Pop',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-popsicle', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-chocolate',
    name: 'Chocolate Bar',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-chocolate', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-cookie',
    name: 'Chocolate Chip Cookie',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-cookie', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-cinnamon-roll',
    name: 'Cinnamon Roll',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-cinnamon-roll', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-muffin',
    name: 'Blueberry Muffin',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-muffin', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-crepe',
    name: 'Berry Crêpe',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-crepe', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-flan',
    name: 'Caramel Flan',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-flan', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-churros',
    name: 'Churros & Dip',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-churros', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-tart',
    name: 'Fruit Custard Tart',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-tart', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-gingerbread',
    name: 'Gingerbread Man',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-gingerbread', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-honey-toast',
    name: 'Honey Butter Toast',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-honey-toast', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-croissant',
    name: 'Flaky Croissant',
    category: 'doodle',
    defaultRotation: -5,
    builder: ({double size = 56, double rotation = -5}) => SvgFoodDoodleWidget(id: 'food-croissant', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-baguette',
    name: 'French Baguette',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-baguette', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-sourdough',
    name: 'Sourdough Boule',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-sourdough', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-bagel',
    name: 'Everything Bagel',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-bagel', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-avocado-toast',
    name: 'Avocado Egg Toast',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-avocado-toast', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-pancakes',
    name: 'Pancake Stack',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-pancakes', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-waffle-plate',
    name: 'Waffle on Plate',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-waffle-plate', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-english-muffin',
    name: 'Breakfast McMuffin',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-english-muffin', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-french-toast',
    name: 'Berry French Toast',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-french-toast', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-croque',
    name: 'Croque Monsieur',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-croque', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-brioche',
    name: 'Butter Brioche',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-brioche', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-pita',
    name: 'Pita Pocket',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-pita', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-pretzel',
    name: 'Bavarian Brezel',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-pretzel', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-hard-egg',
    name: 'Hard Boiled Egg',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-hard-egg', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-cereal',
    name: 'Cereal & Berries',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-cereal', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-club-sandwich',
    name: 'Toasted Club Sandwich',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-club-sandwich', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-bread-loaf',
    name: 'Artisan Bread Loaf',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-bread-loaf', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-pizza-slice',
    name: 'Pizza Slice',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-pizza-slice', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-burger',
    name: 'Sesame Cheeseburger',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-burger', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-fries',
    name: 'Crispy French Fries',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-fries', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-hotdog',
    name: 'Classic Hot Dog',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-hotdog', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-taco',
    name: 'Crispy Street Taco',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-taco', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-burrito',
    name: 'Loaded Burrito',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-burrito', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-steak',
    name: 'Grilled Ribeye Steak',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-steak', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-chicken-leg',
    name: 'Roasted Drumstick',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-chicken-leg', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-salmon-fillet',
    name: 'Seared Salmon Fillet',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-salmon-fillet', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-fried-egg',
    name: 'Sunny Fried Egg',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-fried-egg', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-cheese-wedge',
    name: 'Swiss Cheese Wedge',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-cheese-wedge', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-breakfast-plate',
    name: 'Breakfast Plate',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-breakfast-plate', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-ham-roast',
    name: 'Glazed Ham Roast',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-ham-roast', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-shawarma',
    name: 'Shawarma Doner Wrap',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-shawarma', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-sub-sandwich',
    name: 'Submarine Sandwich',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-sub-sandwich', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-skewer',
    name: 'Yakitori Kebab',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-skewer', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-paella',
    name: 'Spanish Paella Pan',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-paella', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-soup-bowl',
    name: 'Warm Soup Bowl',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-soup-bowl', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-ramen-dish',
    name: 'Tokyo Craft Ramen',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-ramen-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-sushi-set',
    name: 'Bento Sushi Platter',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-sushi-set', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-sushi-nigiri',
    name: 'Salmon Nigiri',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-sushi-nigiri', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-maki-roll',
    name: 'California Maki Roll',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-maki-roll', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-dimsum-dish',
    name: 'Dim Sum Dumplings',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-dimsum-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-gyoza-dish',
    name: 'Pan-Fried Gyoza',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-gyoza-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-bao-dish',
    name: 'Steamed Bao Bun',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-bao-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-onigiri-dish',
    name: 'Nori Onigiri',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-onigiri-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-takoyaki-dish',
    name: 'Takoyaki Boat',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-takoyaki-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-tempura-dish',
    name: 'Crispy Tempura',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-tempura-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-taiyaki-dish',
    name: 'Taiyaki Waffle',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-taiyaki-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-fortune-cookie',
    name: 'Fortune Cookie',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-fortune-cookie', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-spring-roll',
    name: 'Crispy Spring Rolls',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-spring-roll', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-bento-dish',
    name: 'Bento Box Meal',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-bento-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-pad-thai',
    name: 'Pad Thai Noodle Box',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-pad-thai', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-bibimbap-dish',
    name: 'Korean Bibimbap',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-bibimbap-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-edamame-dish',
    name: 'Steamed Edamame',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-edamame-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-matcha-dish',
    name: 'Ceremonial Matcha Bowl',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-matcha-dish', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-tomato',
    name: 'Vine Tomato',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-tomato', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-basil',
    name: 'Genovese Basil',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-basil', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-garlic',
    name: 'Garlic Bulb',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-garlic', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-avocado',
    name: 'Hass Avocado',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-avocado', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-lemon',
    name: 'Meyer Lemon',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-lemon', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-lime',
    name: 'Lime Slice',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-lime', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-chili',
    name: 'Chili Pepper',
    category: 'doodle',
    defaultRotation: -6,
    builder: ({double size = 56, double rotation = -6}) => SvgFoodDoodleWidget(id: 'food-chili', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-bell-pepper',
    name: 'Bell Pepper',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-bell-pepper', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-eggplant',
    name: 'Aubergine Eggplant',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-eggplant', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-mushroom',
    name: 'Porcini Mushroom',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-mushroom', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-carrot',
    name: 'Orange Carrot',
    category: 'doodle',
    defaultRotation: -5,
    builder: ({double size = 56, double rotation = -5}) => SvgFoodDoodleWidget(id: 'food-carrot', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-broccoli',
    name: 'Broccoli Floret',
    category: 'doodle',
    defaultRotation: 4,
    builder: ({double size = 56, double rotation = 4}) => SvgFoodDoodleWidget(id: 'food-broccoli', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-strawberry',
    name: 'Sweet Strawberry',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-strawberry', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-apple',
    name: 'Crisp Apple',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-apple', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-banana',
    name: 'Cavendish Banana',
    category: 'doodle',
    defaultRotation: -5,
    builder: ({double size = 56, double rotation = -5}) => SvgFoodDoodleWidget(id: 'food-banana', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-beer-mug',
    name: 'Frothy Beer Mug',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-beer-mug', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-coffee-cup',
    name: 'Hot Coffee Mug',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-coffee-cup', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-iced-coffee',
    name: 'Iced Latte Cup',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-iced-coffee', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-boba',
    name: 'Boba Bubble Tea',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-boba', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-wine-glass',
    name: 'Merlot Wine Glass',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-wine-glass', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-wine-bottle',
    name: 'Vintage Wine Bottle',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-wine-bottle', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-teapot',
    name: 'Herbal Teapot',
    category: 'doodle',
    defaultRotation: -4,
    builder: ({double size = 56, double rotation = -4}) => SvgFoodDoodleWidget(id: 'food-teapot', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-milk-carton',
    name: 'Dairy Milk Carton',
    category: 'doodle',
    defaultRotation: 3,
    builder: ({double size = 56, double rotation = 3}) => SvgFoodDoodleWidget(id: 'food-milk-carton', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-coconut-drink',
    name: 'Tropical Coconut',
    category: 'doodle',
    defaultRotation: -3,
    builder: ({double size = 56, double rotation = -3}) => SvgFoodDoodleWidget(id: 'food-coconut-drink', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-whisk',
    name: 'Balloon Whisk',
    category: 'doodle',
    defaultRotation: 5,
    builder: ({double size = 56, double rotation = 5}) => SvgFoodDoodleWidget(id: 'food-whisk', size: size, rotation: rotation),
  ),
  CulinaryStampDef(
    id: 'food-chef-knife',
    name: 'Chef Knife',
    category: 'doodle',
    defaultRotation: -6,
    builder: ({double size = 56, double rotation = -6}) => SvgFoodDoodleWidget(id: 'food-chef-knife', size: size, rotation: rotation),
  ),
];

final Map<String, String> rawFoodDoodleSvgMap = {
  'food-donut': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="32" r="22" fill="#E89A6C" />
      <path
        d="M32 11C43.6 11 53 20.4 53 32C53 34.8 51.9 36 50.2 34.9C48.3 33.6 45.9 35.2 43.7 37.4C41.6 39.5 39.3 37.2 36.6 38.5C33.9 39.8 32.8 43.4 30.4 43.5C28.1 43.6 26.2 40 23.7 40.8C21.2 41.6 19.4 45.2 16.9 44.2C14.5 43.2 14.4 38.6 12.5 37C11 35.7 11 33.8 11 32C11 20.4 20.4 11 32 11Z"
        fill="#E85A65"
      />
      <circle cx="32" cy="32" r="7.5" fill="#FAF7F2" />
      <circle cx="32" cy="32" r="7.5" fill="none" stroke="#D98A5C" stroke-width="1" stroke-opacity="0.4" />
      <rect x="21.5" y="15.5" width="4.2" height="1.9" rx="0.95" transform="rotate(25 21.5 15.5)" fill="#FFFFFF" />
      <rect x="36.5" y="14.5" width="4.2" height="1.9" rx="0.95" transform="rotate(-35 36.5 14.5)" fill="#FBD46D" />
      <rect x="44.5" y="23.5" width="4.2" height="1.9" rx="0.95" transform="rotate(45 44.5 23.5)" fill="#68C2A0" />
      <rect x="17.5" y="25.5" width="4.2" height="1.9" rx="0.95" transform="rotate(-20 17.5 25.5)" fill="#FFFFFF" />
      <rect x="42.5" y="34.5" width="4.2" height="1.9" rx="0.95" transform="rotate(15 42.5 34.5)" fill="#FFFFFF" />
      <rect x="21.5" y="38.5" width="4.2" height="1.9" rx="0.95" transform="rotate(-60 21.5 38.5)" fill="#FBD46D" />
      <ellipse cx="23" cy="18" rx="3" ry="1.6" transform="rotate(-30 23 18)" fill="#FFFFFF" fill-opacity="0.35" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-cake-slice': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <ellipse cx="33" cy="52.3" rx="23" ry="3.6" fill="#6F3A38" fill-opacity="0.16" />

      
      <path d="M12 32L53 21V48C53 50 51.4 51 49.6 51H14.4C13.1 51 12 50 12 48V32Z" fill="#F6CA9B" stroke="#9C5A45" stroke-width="1.15" />
      <path d="M12 39L53 28V34L12 45V39Z" fill="#FFF7EF" />
      <path d="M12 39L53 28" stroke="#EAA1A4" stroke-width="2.5" stroke-linecap="round" />
      <path d="M12 45L53 34V39L12 50V45Z" fill="#EFA1A7" />
      <path d="M12 45L53 34" stroke="#C96877" stroke-width="1" stroke-opacity="0.58" />

      
      <path d="M18 35L20 34.5M23 47L25 46.5M45 42L47 41.5M47 25L49 24.5" stroke="#D99167" stroke-width="1.1" stroke-linecap="round" />
      <circle cx="19" cy="43" r="0.85" fill="#D99167" fill-opacity="0.72" />
      <circle cx="47" cy="46" r="0.85" fill="#D99167" fill-opacity="0.72" />

      
      <path d="M10 30L34.5 8.5C35.4 7.7 36.7 7.8 37.6 8.7L54.5 19.5L53 23L14 34L10 30Z" fill="#F8B9C8" stroke="#A95267" stroke-width="1.15" stroke-linejoin="round" />
      <path d="M13.2 30.1C17 28.2 17.2 32 21 30C24.7 28 25.1 31.9 28.8 29.9C32.5 27.9 33 31.7 36.6 29.6C40.2 27.5 40.9 31.2 44.4 29.2C47.9 27.2 49.2 29 52 26.6" stroke="#FFF5F7" stroke-width="2.5" stroke-linecap="round" fill="none" />
      <path d="M14 31.6L51.8 21.5" stroke="#E987A2" stroke-width="1" stroke-opacity="0.7" stroke-linecap="round" />

      
      <circle cx="32" cy="12" r="4.6" fill="#C92D3D" stroke="#8F2630" stroke-width="0.75" />
      <ellipse cx="30.4" cy="10.5" rx="1.35" ry="0.9" fill="#FFABB3" fill-opacity="0.82" />
      <path d="M33 8C34.4 4.7 37.3 3.5 39.6 4.5" stroke="#537747" stroke-width="1.25" stroke-linecap="round" fill="none" />
      <path d="M39 9C41.8 7 44.1 9 42.2 11.2C40.7 11.6 39.5 10.6 39 9Z" fill="#72A950" />
      <circle cx="42.5" cy="18" r="3.2" fill="#556EAE" stroke="#384E86" stroke-width="0.65" />
      <circle cx="41.5" cy="17" r="0.75" fill="#FFFFFF" fill-opacity="0.82" />
      <path d="M23.4 21.4C22.4 17.8 24.3 15.3 27.5 16.6C30.7 18 29.1 22.2 26.3 22.7C25.1 22.8 24.1 22.4 23.4 21.4Z" fill="#FFFDF8" stroke="#E7D9CF" stroke-width="0.65" />
      <path d="M25 19.6C26.1 18.8 27 19.7 27.4 20.7" stroke="#F3DCE1" stroke-width="0.85" stroke-linecap="round" fill="none" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(-0.5 9.0) translate(32 34) scale(0.82) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-cupcake': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="18,52 46,52 50,34 14,34" fill="#D99726" />
      <line x1="22" y1="34" x2="24" y2="52" stroke="#B86A1D" stroke-width="1.2" />
      <line x1="32" y1="34" x2="32" y2="52" stroke="#B86A1D" stroke-width="1.2" />
      <line x1="42" y1="34" x2="40" y2="52" stroke="#B86A1D" stroke-width="1.2" />
      <ellipse cx="32" cy="34" rx="18" ry="6" fill="#C47D1E" />
      <ellipse cx="32" cy="33" rx="18" ry="7" fill="#F8B4C0" />
      <ellipse cx="32" cy="26" rx="14" ry="6.5" fill="#FBEFF1" />
      <ellipse cx="32" cy="19.5" rx="9.5" ry="5" fill="#F8B4C0" />
      <circle cx="32" cy="14" r="4.5" fill="#E22E3E" />
      <ellipse cx="30.5" cy="12.5" rx="1.3" ry="0.9" fill="#F2564F" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-macaron': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="16" y="15.5" width="32" height="7.5" rx="3.75" fill="#F8B4C0" />
      <path d="M16 20C21 22.5 43 22.5 48 20" stroke="#EFA0AE" stroke-width="0.8" fill="none" stroke-opacity="0.6" />
      <rect x="18" y="22" width="28" height="3" rx="1.5" fill="#FAF7F2" />
      <rect x="16" y="23.5" width="32" height="7.5" rx="3.75" fill="#F8B4C0" />
      <rect x="14" y="33.5" width="36" height="7.5" rx="3.75" fill="#A8D8B9" />
      <path d="M14 38C21 40.5 43 40.5 50 38" stroke="#8FC7A3" stroke-width="0.8" fill="none" stroke-opacity="0.6" />
      <rect x="16" y="40" width="32" height="3" rx="1.5" fill="#68A348" />
      <rect x="14" y="41.5" width="36" height="7.5" rx="3.75" fill="#A8D8B9" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-ice-cream': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="32,58 18,34 46,34" fill="#D99726" />
      <line x1="23.3" y1="42" x2="40.7" y2="42" stroke="#B86A1D" stroke-width="1" />
      <line x1="27.3" y1="49" x2="36.7" y2="49" stroke="#B86A1D" stroke-width="1" />
      <line x1="24.7" y1="38" x2="39.3" y2="38" stroke="#B86A1D" stroke-width="1" />
      <ellipse cx="32" cy="34" rx="14" ry="5" fill="#FBEFF1" />
      <circle cx="25" cy="27" r="9.5" fill="#F8B4C0" />
      <circle cx="39" cy="27" r="9.5" fill="#F4CA38" />
      <circle cx="32" cy="18.5" r="10" fill="#FBEFF1" />
      <ellipse cx="27" cy="14.5" rx="3" ry="2" transform="rotate(-25 27 14.5)" fill="#FFFFFF" fill-opacity="0.5" />
      <circle cx="32" cy="7.5" r="3.5" fill="#C8281E" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-sundae': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M20 28C20 40 28 46.5 32 46.5C36 46.5 44 40 44 28H20Z" fill="#E8ECEB" stroke="#D3DCDB" stroke-width="1.5" />
      <path d="M23 30C23.5 38 29 43.5 32 44" stroke="#FFFFFF" stroke-width="1" stroke-opacity="0.6" fill="none" />
      <rect x="30.2" y="46.3" width="3.6" height="8" fill="#D3DCDB" />
      <ellipse cx="32" cy="54" rx="10" ry="3" fill="#D3DCDB" />
      <ellipse cx="32" cy="28" rx="12" ry="5" fill="#7A4B29" />
      <circle cx="26.5" cy="21.5" r="7.2" fill="#FBEFF1" />
      <circle cx="37.5" cy="21.5" r="7.2" fill="#F8B4C0" />
      <circle cx="32" cy="14" r="3.2" fill="#C8281E" />
      <line x1="42" y1="11" x2="48.5" y2="28" stroke="#D99726" stroke-width="2.5" stroke-linecap="round" />
      <line x1="42" y1="11" x2="48.5" y2="28" stroke="#F4CA38" stroke-width="0.8" stroke-linecap="round" stroke-opacity="0.7" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-popsicle': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="29" y="44" width="6" height="16" rx="3" fill="#D9B382" />
      <line x1="30.5" y1="47" x2="30.5" y2="57" stroke="#C29B6B" stroke-width="0.7" />
      <rect x="20" y="9" width="24" height="37" rx="9" fill="#72B338" />
      <path d="M22 13C21 20 21 34 22 41" stroke="#8AC553" stroke-width="2" stroke-linecap="round" fill="none" stroke-opacity="0.6" />
      <line x1="27" y1="14" x2="27" y2="40" stroke="#5A9429" stroke-width="2.4" stroke-linecap="round" />
      <line x1="37" y1="14" x2="37" y2="40" stroke="#5A9429" stroke-width="2.4" stroke-linecap="round" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-chocolate': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="16" y="14" width="32" height="40" rx="3" fill="#52321A" />
      <rect x="19" y="17" width="12" height="10" rx="1.5" fill="#6F4827" />
      <rect x="33" y="17" width="12" height="10" rx="1.5" fill="#6F4827" />
      <rect x="19" y="29" width="12" height="10" rx="1.5" fill="#6F4827" />
      <rect x="33" y="29" width="12" height="10" rx="1.5" fill="#6F4827" />
      <rect x="19" y="41" width="12" height="10" rx="1.5" fill="#6F4827" />
      <rect x="33" y="41" width="12" height="10" rx="1.5" fill="#6F4827" />
      <rect x="20" y="18" width="10" height="2.5" rx="1.25" fill="#7E5A34" fill-opacity="0.7" />
      <rect x="34" y="18" width="10" height="2.5" rx="1.25" fill="#7E5A34" fill-opacity="0.7" />
      <polygon points="14,38 50,34 50,56 14,56" fill="#C8281E" />
      <polygon points="14,38 50,34 50,40 14,44" fill="#E8ECEB" />
      <polygon points="14,44 50,40 50,42 14,46" fill="#C8D2D0" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-cookie': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="32" r="22" fill="#B97038" stroke="#70411E" stroke-width="1.35" />
      <circle cx="32" cy="31" r="20" fill="#DDA55E" />
      <path d="M15 28C18 20 26 14 34 14" stroke="#F5CD91" stroke-width="2.1" stroke-linecap="round" fill="none" stroke-opacity="0.8" />
      <path d="M18 43C23 48 33 51 41 47" stroke="#B9793C" stroke-width="1.1" stroke-linecap="round" fill="none" stroke-opacity="0.66" />
      <circle cx="21" cy="24" r="3.1" fill="#4A2B17" /><circle cx="20" cy="23" r="0.8" fill="#8B5C35" />
      <circle cx="38" cy="23" r="3.5" fill="#4A2B17" /><circle cx="37" cy="22" r="0.9" fill="#8B5C35" />
      <circle cx="29" cy="33" r="3.2" fill="#4A2B17" /><circle cx="28" cy="32" r="0.75" fill="#8B5C35" />
      <circle cx="42" cy="38" r="2.7" fill="#4A2B17" /><circle cx="19.5" cy="42" r="2.5" fill="#4A2B17" />
      <circle cx="32" cy="46" r="2.25" fill="#4A2B17" /><circle cx="34" cy="17" r="1.25" fill="#B9793C" />
      <circle cx="25" cy="17" r="1" fill="#B9793C" /><circle cx="35" cy="40" r="0.9" fill="#B9793C" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-cinnamon-roll': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="34" rx="20" ry="16" fill="#D99726" stroke="#8C5C1A" stroke-width="1.5" />
      <path
        d="M32 25C37.5 25 43 28.5 43 34C43 41.5 35.8 45 28.5 45C21 45 17 37.7 17 32C17 22.8 26.3 19 33.5 19"
        stroke="#6F361E"
        stroke-width="3.3"
        stroke-linecap="round"
        fill="none"
      />
      <ellipse cx="32" cy="30" rx="8" ry="4" fill="#FFFDF8" fill-opacity="0.85" />
      <path d="M20 40C24 44 30 46 34 45" stroke="#F2C27D" stroke-width="1.2" stroke-linecap="round" fill="none" stroke-opacity="0.7" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-muffin': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="18,52 46,52 50,34 14,34" fill="#C47D31" />
      <line x1="22" y1="34" x2="24" y2="52" stroke="#A8681F" stroke-width="1" />
      <line x1="42" y1="34" x2="40" y2="52" stroke="#A8681F" stroke-width="1" />
      <ellipse cx="32" cy="34" rx="18" ry="7" fill="#E5A352" />
      <path d="M14 33C13 24.5 20.5 18.5 32 18.5C43.5 18.5 51 24.5 50 33C42 30.5 22 30.5 14 33Z" fill="#F4BA42" />
      <circle cx="24" cy="25" r="2.5" fill="#2E4A7A" />
      <circle cx="34" cy="23" r="2.5" fill="#2E4A7A" />
      <circle cx="42" cy="27.5" r="2" fill="#2E4A7A" />
      <circle cx="29" cy="29" r="1.8" fill="#2E4A7A" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-crepe': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <polygon points="32,60 14,24 50,24" fill="#E8DDD0" stroke="#D3C7B6" stroke-width="1" />
      <polygon points="32,60 32,24 50,24" fill="#DDD0BF" />
      <path d="M14 24Q32 28 50 24" stroke="#C8BCAB" stroke-width="1" fill="none" />

      
      <polygon points="32,54 10,16 54,16" fill="#F4CB6C" stroke="#D99726" stroke-width="1.2" />
      <path d="M10 16Q32 11 54 16L32 54Z" fill="#FDE7A4" />
      <path d="M10 16Q32 20 54 16" stroke="#D99726" stroke-width="1.2" fill="none" />
      
      <ellipse cx="26" cy="32" rx="3.5" ry="1.8" transform="rotate(35 26 32)" fill="#D98A38" fill-opacity="0.45" />
      <ellipse cx="38" cy="36" rx="3" ry="1.5" transform="rotate(-30 38 36)" fill="#D98A38" fill-opacity="0.45" />
      <ellipse cx="30" cy="44" rx="2.5" ry="1.2" transform="rotate(15 30 44)" fill="#D98A38" fill-opacity="0.45" />

      
      <circle cx="24" cy="15" r="7" fill="#FFFDF8" stroke="#EAE2D5" stroke-width="0.8" />
      <circle cx="34" cy="13" r="8" fill="#FFFDF8" stroke="#EAE2D5" stroke-width="0.8" />
      <circle cx="43" cy="16" r="6.5" fill="#FFFDF8" stroke="#EAE2D5" stroke-width="0.8" />
      <circle cx="29" cy="9" r="6" fill="#FFFFFF" />
      <ellipse cx="30" cy="8" rx="2.5" ry="1.2" fill="#FAF5ED" />

      
      <path d="M18 10C16 4 24 2 27 7L24 14Z" fill="#E22E3E" stroke="#B81D2C" stroke-width="0.8" />
      <path d="M19 9C18 5 23 4 25 7L23 12Z" fill="#F2564F" />
      <circle cx="21" cy="7.5" r="0.4" fill="#FEF8EB" />
      <circle cx="23" cy="9.5" r="0.4" fill="#FEF8EB" />

      
      <circle cx="38" cy="9" r="3.6" fill="#2E4A7A" />
      <circle cx="38" cy="9" r="2.8" fill="#3D63A3" />
      <circle cx="37" cy="8" r="0.9" fill="#FFFFFF" fill-opacity="0.85" />

      <circle cx="44" cy="13" r="3.2" fill="#2E4A7A" />
      <circle cx="44" cy="13" r="2.4" fill="#3D63A3" />
      <circle cx="43.2" cy="12.2" r="0.8" fill="#FFFFFF" fill-opacity="0.85" />

      
      <path d="M33 4C31 1 35 0 37 3C37 5 34 5 33 4Z" fill="#4A7A2A" />
      <path d="M35 5C38 3 40 6 38 7C36 7 35 6 35 5Z" fill="#68A348" />

      
      <path
        d="M17 19C24 23 20 27 28 30C36 33 32 37 36 43"
        stroke="#4A2E16"
        stroke-width="2.4"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M17 19C24 23 20 27 28 30C36 33 32 37 36 43"
        stroke="#7A4B29"
        stroke-width="1.1"
        stroke-linecap="round"
        fill="none"
        stroke-opacity="0.75"
      />
      <path
        d="M26 17C31 20 28 25 35 27"
        stroke="#4A2E16"
        stroke-width="2"
        stroke-linecap="round"
        fill="none"
      />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-flan': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      
      <ellipse cx="32" cy="51" rx="25" ry="8" fill="#E8ECEB" stroke="#D3DCDB" stroke-width="1.2" />
      <ellipse cx="32" cy="50.5" rx="22" ry="6.5" fill="#FAF7F2" />
      <ellipse cx="32" cy="50" rx="17" ry="4.5" fill="#D3DCDB" fill-opacity="0.3" />

      
      <ellipse cx="32" cy="49" rx="19" ry="5.5" fill="#9E461A" />
      <ellipse cx="32" cy="48.2" rx="17.5" ry="4.8" fill="#C45A20" />
      <ellipse cx="30" cy="47.5" rx="14" ry="3.5" fill="#E5782A" fill-opacity="0.8" />

      
      <path
        d="M19 46C18 36 21 24 23 23C26 22 38 22 41 23C43 24 46 36 45 46C40 48.5 24 48.5 19 46Z"
        fill="#F5D06A"
        stroke="#D99726"
        stroke-width="1.2"
      />
      
      <path
        d="M20 45C19.2 37 22 25 23.5 24C26 23 30 23 30 24C28 26 25 36 25 45C23 45.5 21 45.5 20 45Z"
        fill="#FFE89E"
        fill-opacity="0.7"
      />
      
      
      <ellipse cx="32" cy="23" rx="9.5" ry="3.8" fill="#6F2808" />
      <ellipse cx="32" cy="22.3" rx="9" ry="3.3" fill="#A84414" />
      <ellipse cx="30.5" cy="21.5" rx="6.5" ry="2.2" fill="#D96620" />
      <ellipse cx="28" cy="21" rx="3.5" ry="1.1" fill="#FFAC68" fill-opacity="0.75" />
    

      
      <path
        d="M24 24C24 28 26 31 25.5 36C25 39 23.5 41 24 44"
        stroke="#8A340E"
        stroke-width="2.4"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M24 24C24 28 26 31 25.5 36C25 39 23.5 41 24 44"
        stroke="#D96620"
        stroke-width="1.1"
        stroke-linecap="round"
        fill="none"
        stroke-opacity="0.8"
      />
      <path
        d="M38 24C38.5 29 37 33 38 38C38.5 41 40 43 39.5 45"
        stroke="#8A340E"
        stroke-width="2.2"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M31 25C31 30 32.5 34 32 39"
        stroke="#A84414"
        stroke-width="1.8"
        stroke-linecap="round"
        fill="none"
      />
      

      
      <ellipse cx="32" cy="18.5" rx="5" ry="2.8" fill="#FFFDF8" stroke="#EAE2D5" stroke-width="0.7" />
      <circle cx="32" cy="16.5" r="3.2" fill="#FFFFFF" />

      
      <circle cx="32" cy="12.5" r="3.8" fill="#B81D2C" />
      <circle cx="32" cy="12.5" r="3.2" fill="#E22E3E" />
      <ellipse cx="30.8" cy="11.2" rx="1.2" ry="0.8" fill="#FFA3A8" />
      <path d="M32 9C33 5 37 3 39 4" stroke="#4A6B53" stroke-width="1.2" stroke-linecap="round" fill="none" />
      
      <path d="M26 15C23 14 24 11 27 12C28 14 27 15 26 15Z" fill="#5A8F34" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-churros': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <line x1="14" y1="52" x2="38" y2="12" stroke="#D99726" stroke-width="7" stroke-linecap="round" />
      <line x1="14" y1="52" x2="38" y2="12" stroke="#FCE59F" stroke-width="2" stroke-linecap="round" />
      <line x1="26" y1="54" x2="50" y2="14" stroke="#D99726" stroke-width="7" stroke-linecap="round" />
      <line x1="26" y1="54" x2="50" y2="14" stroke="#FCE59F" stroke-width="2" stroke-linecap="round" />
      <ellipse cx="44" cy="47" rx="10" ry="7" fill="#52321A" />
      <ellipse cx="44" cy="45" rx="8" ry="5" fill="#3D1A24" />
      <ellipse cx="41" cy="43.5" rx="2.4" ry="1.4" fill="#5A2A38" fill-opacity="0.7" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-tart': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="12,46 52,46 56,36 8,36" fill="#D99726" stroke="#8C5C1A" stroke-width="1.2" />
      <line x1="16" y1="41" x2="49" y2="41" stroke="#B37A1E" stroke-width="0.8" stroke-opacity="0.5" />
      <ellipse cx="32" cy="36" rx="24" ry="7" fill="#FCE59F" />
      <circle cx="24" cy="32" r="4" fill="#E22E3E" />
      <ellipse cx="22.7" cy="30.7" rx="1.1" ry="0.8" fill="#F2564F" />
      <circle cx="32" cy="30" r="4.5" fill="#2E4A7A" />
      <circle cx="40" cy="32" r="4" fill="#68A348" />
      <circle cx="28" cy="36" r="3.5" fill="#F49A68" />
      <circle cx="36" cy="36" r="3.5" fill="#E22E3E" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-gingerbread': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="18" r="8" fill="#A86E45" />
      <rect x="28" y="24" width="8" height="18" rx="4" fill="#A86E45" />
      <line x1="28" y1="28" x2="16" y2="36" stroke="#A86E45" stroke-width="5.5" stroke-linecap="round" />
      <line x1="36" y1="28" x2="48" y2="36" stroke="#A86E45" stroke-width="5.5" stroke-linecap="round" />
      <line x1="29" y1="40" x2="20" y2="54" stroke="#A86E45" stroke-width="5.5" stroke-linecap="round" />
      <line x1="35" y1="40" x2="44" y2="54" stroke="#A86E45" stroke-width="5.5" stroke-linecap="round" />
      <path d="M17 34C22 30 42 30 47 34" stroke="#FFFFFF" stroke-width="1.6" stroke-linecap="round" fill="none" stroke-opacity="0.85" />
      <circle cx="30" cy="17" r="1" fill="#FFF" />
      <circle cx="34" cy="17" r="1" fill="#FFF" />
      <path d="M28 21Q32 23 36 21" stroke="#5A3A1E" stroke-width="1" stroke-linecap="round" fill="none" />
      <ellipse cx="27.2" cy="20.5" rx="1.8" ry="0.8" fill="#F48792" fill-opacity="0.48" />
      <ellipse cx="36.8" cy="20.5" rx="1.8" ry="0.8" fill="#F48792" fill-opacity="0.48" />
      <circle cx="32" cy="30" r="1.5" fill="#E22E3E" />
      <circle cx="32" cy="36" r="1.5" fill="#68A348" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-honey-toast': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="14" y="16" width="36" height="36" rx="6" fill="#F4BA42" stroke="#B86A1D" stroke-width="1.5" />
      <rect x="18" y="20" width="28" height="28" rx="4" fill="#FCE59F" />
      <path d="M20 22Q28 26.5 36 22Q44 26 44 32Q38 36.5 32 34.5Q22 36.5 20 22Z" fill="#D9822B" fill-opacity="0.8" />
      <rect x="28" y="28" width="8" height="6" rx="1.5" fill="#FFF275" stroke="#D99726" stroke-width="1" />
      <ellipse cx="30" cy="30" rx="1.6" ry="1" fill="#FFFFFF" fill-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-croissant': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M8 43C12 28 19 19 28 18C34 12 42 15 46 22C54 22 58 31 56 42C49 39 44 34 39 31C35 37 28 37 24 31C19 36 14 41 8 43Z" fill="#B96D29" stroke="#75421B" stroke-width="1.35" />
      <path d="M11 40C16 26 23 20 30 21C34 16 41 18 43 25C50 24 54 31 53 39C47 36 43 31 39 28C36 34 29 34 25 28C20 33 16 38 11 40Z" fill="#E5A34B" />
      <path d="M20 26C24 25 27 27 29 31M31 20C33 23 34 27 33 32M42 24C40 27 40 30 41 33" stroke="#A65E22" stroke-width="1.45" stroke-linecap="round" fill="none" />
      <path d="M14 35C18 29 20 26 24 24M46 27C50 30 51 34 51 36" stroke="#F8D08A" stroke-width="1.4" stroke-linecap="round" fill="none" stroke-opacity="0.82" />
      <ellipse cx="24" cy="23" rx="3.2" ry="1.45" transform="rotate(-25 24 23)" fill="#FFF0C7" fill-opacity="0.7" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-baguette': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M12 52L52 12C55 9 59 13 56 16L16 56C13 59 9 55 12 52Z" fill="#D99726" stroke="#8C5C1A" stroke-width="1.5" />
      <path d="M14 50L50 14" stroke="#B86A1D" stroke-width="0.8" stroke-opacity="0.4" />
      <line x1="22" y1="44" x2="26" y2="40" stroke="#FCE59F" stroke-width="2" stroke-linecap="round" />
      <line x1="32" y1="34" x2="36" y2="30" stroke="#FCE59F" stroke-width="2" stroke-linecap="round" />
      <line x1="42" y1="24" x2="46" y2="20" stroke="#FCE59F" stroke-width="2" stroke-linecap="round" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-sourdough': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="36" rx="22" ry="16" fill="#D99726" stroke="#8C5C1A" stroke-width="1.5" />
      <path d="M18 30C24.5 23.5 39.5 23.5 46 30" stroke="#52321A" stroke-width="2.4" stroke-linecap="round" fill="none" />
      <path d="M22 44C26 47.5 38 47.5 42 44" stroke="#B37A1E" stroke-width="1" stroke-linecap="round" fill="none" stroke-opacity="0.5" />
      <ellipse cx="32" cy="26" rx="8" ry="4" fill="#FCE59F" stroke="#8C5C1A" stroke-width="1" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-bagel': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="32" r="21" fill="#D99726" stroke="#B86A1D" stroke-width="1.5" />
      <path d="M16 20C22 13 42 13 48 20" stroke="#E9AE55" stroke-width="1.6" stroke-linecap="round" fill="none" stroke-opacity="0.6" />
      <circle cx="32" cy="32" r="8" fill="#FAF7F2" stroke="#B86A1D" stroke-width="1.5" />
      <ellipse cx="28" cy="24" rx="1.5" ry="0.8" fill="#1E1A18" />
      <ellipse cx="38" cy="22" rx="1.5" ry="0.8" fill="#1E1A18" />
      <ellipse cx="44" cy="32" rx="1.5" ry="0.8" fill="#1E1A18" />
      <ellipse cx="20" cy="34" rx="1.5" ry="0.8" fill="#1E1A18" />
      <ellipse cx="34" cy="42" rx="1.5" ry="0.8" fill="#1E1A18" />
      <ellipse cx="24" cy="41" rx="1.3" ry="0.7" fill="#1E1A18" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-avocado-toast': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="14" y="16" width="36" height="36" rx="6" fill="#8C5C1A" />
      <rect x="16" y="18" width="32" height="32" rx="4" fill="#D99726" />
      <path d="M18 24C22.5 19.5 32.5 19.5 44 26C46.5 37.5 40 46 22 46C18 36.5 18 28 18 24Z" fill="#8DB355" />
      <path d="M21 26C26 23 34 23.5 40 27.5" stroke="#7AA347" stroke-width="1" fill="none" stroke-opacity="0.6" />
      <circle cx="32" cy="34" r="8" fill="#FFFDF8" />
      <circle cx="32" cy="34" r="5" fill="#F4A81D" />
      <circle cx="26" cy="26" r="1" fill="#C8281E" />
      <circle cx="38" cy="40" r="1" fill="#C8281E" />
      <circle cx="40" cy="30" r="1" fill="#C8281E" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-pancakes': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <ellipse cx="32" cy="53" rx="25" ry="7" fill="#E2E8F0" stroke="#CBD5E1" stroke-width="1" />
      <ellipse cx="32" cy="52.5" rx="22" ry="5.5" fill="#F8FAFC" />

      
      <ellipse cx="32" cy="46" rx="22" ry="7.5" fill="#D98A38" stroke="#B86A1D" stroke-width="1.2" />
      <ellipse cx="32" cy="45" rx="21" ry="6.5" fill="#F5C77E" />

      
      <ellipse cx="32" cy="38" rx="21" ry="7.5" fill="#D98A38" stroke="#B86A1D" stroke-width="1.2" />
      <ellipse cx="32" cy="37" rx="20" ry="6.5" fill="#F5C77E" />

      
      <ellipse cx="32" cy="30" rx="20" ry="7.5" fill="#D98A38" stroke="#B86A1D" stroke-width="1.2" />
      <ellipse cx="32" cy="29" rx="19" ry="6.5" fill="#FDE68A" />
      <path d="M15 28C20 25 44 25 49 28" stroke="#FEF08A" stroke-width="1.5" fill="none" />

      
      <path
        d="M26 29C26 34 24 37 25 43C25.5 46 27 49 26 51"
        stroke="#9E461A"
        stroke-width="2.8"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M26 29C26 34 24 37 25 43C25.5 46 27 49 26 51"
        stroke="#D97706"
        stroke-width="1.4"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M38 29C38 35 40 38 39 44C38.5 47 37 49 38 51"
        stroke="#9E461A"
        stroke-width="2.5"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M38 29C38 35 40 38 39 44C38.5 47 37 49 38 51"
        stroke="#D97706"
        stroke-width="1.2"
        stroke-linecap="round"
        fill="none"
      />

      
      <rect x="27" y="21" width="10" height="7.5" rx="1.8" fill="#FDE047" stroke="#CA8A04" stroke-width="0.8" />
      <ellipse cx="32" cy="21" rx="5" ry="2" fill="#FEF08A" />
      
      <path d="M29 28C29 31 31 33 33 33" stroke="#FDE047" stroke-width="1.6" stroke-linecap="round" fill="none" />

      
      <circle cx="21" cy="25" r="3.2" fill="#1E3A8A" />
      <circle cx="20.5" cy="24.5" r="0.8" fill="#FFFFFF" fill-opacity="0.8" />

      <circle cx="43" cy="26" r="3.2" fill="#1E3A8A" />
      <circle cx="42.5" cy="25.5" r="0.8" fill="#FFFFFF" fill-opacity="0.8" />

      <circle cx="25" cy="21" r="2.6" fill="#1E3A8A" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-waffle-plate': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <circle cx="32" cy="32" r="23.5" fill="#E2E8F0" stroke="#CBD5E1" stroke-width="1.5" />
      <circle cx="32" cy="32" r="20" fill="#F8FAFC" />
      <circle cx="32" cy="32" r="16.5" fill="#E2E8F0" fill-opacity="0.3" />

      
      <rect x="18" y="18" width="28" height="28" rx="5" transform="rotate(45 32 32)" fill="#D98A38" stroke="#B86A1D" stroke-width="1.2" />
      <rect x="19.5" y="19.5" width="25" height="25" rx="3.5" transform="rotate(45 32 32)" fill="#F5C77E" />

      
      <rect x="25" y="25" width="6" height="6" rx="1.2" fill="#B45309" />
      <rect x="25.5" y="25.5" width="5" height="5" rx="0.8" fill="#D97706" />

      <rect x="33" y="25" width="6" height="6" rx="1.2" fill="#B45309" />
      <rect x="33.5" y="25.5" width="5" height="5" rx="0.8" fill="#D97706" />

      <rect x="25" y="33" width="6" height="6" rx="1.2" fill="#B45309" />
      <rect x="25.5" y="33.5" width="5" height="5" rx="0.8" fill="#D97706" />

      <rect x="33" y="33" width="6" height="6" rx="1.2" fill="#B45309" />
      <rect x="33.5" y="33.5" width="5" height="5" rx="0.8" fill="#D97706" />

      
      <ellipse cx="28" cy="27" rx="1.5" ry="0.8" fill="#FEF08A" />
      <ellipse cx="36" cy="27" rx="1.5" ry="0.8" fill="#FEF08A" />
      <ellipse cx="28" cy="35" rx="1.5" ry="0.8" fill="#FEF08A" />
      <ellipse cx="36" cy="35" rx="1.5" ry="0.8" fill="#FEF08A" />

      
      <ellipse cx="32" cy="31" rx="6" ry="4.5" fill="#FFFDF8" stroke="#E2E8F0" stroke-width="0.8" />
      <circle cx="32" cy="28.5" r="4" fill="#FFFFFF" />

      
      <circle cx="28" cy="25" r="3.2" fill="#E11D48" stroke="#9F1239" stroke-width="0.6" />
      <circle cx="27.5" cy="24.5" r="1" fill="#FDA4AF" />

      <circle cx="36" cy="25" r="3.2" fill="#1E3A8A" />
      <circle cx="35.5" cy="24.5" r="0.8" fill="#FFFFFF" fill-opacity="0.8" />

      
      <path d="M32 23C30 20 33 19 35 21C35 23 33 24 32 23Z" fill="#16A34A" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-english-muffin': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="16" y="44" width="32" height="7" rx="3" fill="#D99726" />
      <rect x="14" y="38" width="36" height="6" rx="2" fill="#8E3B27" />
      <rect x="16" y="32" width="32" height="6" rx="2" fill="#F4A81D" />
      <polygon points="14,32 22,38 30,32" fill="#F9BA2A" />
      <polygon points="34,32 42,38 50,32" fill="#F9BA2A" />
      <rect x="16" y="18" width="32" height="14" rx="6" fill="#F4CA38" stroke="#D99726" stroke-width="1.2" />
      <ellipse cx="24" cy="22" rx="1.3" ry="0.9" fill="#D9B04A" />
      <ellipse cx="34" cy="24" rx="1.3" ry="0.9" fill="#D9B04A" />
      <ellipse cx="40" cy="20" rx="1.3" ry="0.9" fill="#D9B04A" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-french-toast': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="14" y="16" width="36" height="36" rx="6" fill="#C47D31" />
      <rect x="16" y="18" width="32" height="32" rx="4" fill="#E5A352" />
      <line x1="16" y1="18" x2="48" y2="50" stroke="#8C5C1A" stroke-width="1.5" stroke-dasharray="3 3" />
      <rect x="28" y="28" width="8" height="8" fill="#FFF275" rx="1.5" />
      <path d="M28 30L36 30M28 32L36 32" stroke="#F9D06B" stroke-width="0.8" stroke-opacity="0.6" />
      <circle cx="22" cy="24" r="2.5" fill="#C8281E" />
      <circle cx="40" cy="38" r="2.5" fill="#2E4A7A" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-croque': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="14" y="20" width="36" height="32" rx="4" fill="#D6943C" />
      <rect x="16" y="18" width="32" height="30" rx="3" fill="#FCE59F" />
      <path d="M16 24Q32 19.5 48 24V40H16V24Z" fill="#F9BA2A" />
      <path d="M16 24Q32 20 48 24" stroke="#E8A61C" stroke-width="1" fill="none" stroke-opacity="0.5" />
      <rect x="14" y="34" width="36" height="4" fill="#E85A65" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-brioche': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M14 48L18 30H46L50 48H14Z" fill="#D99726" stroke="#8C5C1A" stroke-width="1.2" />
      <line x1="19" y1="44" x2="45" y2="44" stroke="#B37A1E" stroke-width="0.7" stroke-opacity="0.5" />
      <circle cx="32" cy="24" r="12" fill="#F4BA42" stroke="#8C5C1A" stroke-width="1.2" />
      <circle cx="32" cy="14" r="6" fill="#F4BA42" stroke="#8C5C1A" stroke-width="1.2" />
      <ellipse cx="27" cy="19" rx="3" ry="2" transform="rotate(-20 27 19)" fill="#FFDCA8" fill-opacity="0.5" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-pita': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M10 45C11 27 21 17 32 17C43 17 53 27 54 45C44 50 20 50 10 45Z" fill="#D28B37" stroke="#8B541F" stroke-width="1.35" />
      <path d="M13 40C16 27 23 21 32 21C41 21 48 27 51 40C44 37 20 37 13 40Z" fill="#7B432A" />
      <path d="M14 38C19 33 23 37 27 33C31 37 35 32 39 36C43 32 47 35 50 37" stroke="#69A850" stroke-width="4" stroke-linecap="round" fill="none" />
      <circle cx="23" cy="33" r="3.1" fill="#E84B42" /><circle cx="23" cy="33" r="1" fill="#FFE2B8" />
      <circle cx="33" cy="31" r="3.3" fill="#F5C449" /><circle cx="42" cy="34" r="3" fill="#A8593D" />
      <path d="M11 41C20 38 44 38 53 41V45C43 47.5 21 47.5 11 45V41Z" fill="#F5C96C" />
      <path d="M15 44C23 45.8 41 45.8 49 44" stroke="#FFE5A4" stroke-width="1.1" stroke-linecap="round" fill="none" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-pretzel': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M20 20C20 12 32 12 32 22C32 34 14 48 24 52C36 56 46 44 32 32" stroke="#BA722B" stroke-width="6" stroke-linecap="round" fill="none" />
      <path d="M44 20C44 12 32 12 32 22C32 34 50 48 40 52C28 56 18 44 32 32" stroke="#BA722B" stroke-width="6" stroke-linecap="round" fill="none" />
      <path d="M20 20C20 12 32 12 32 22C32 34 14 48 24 52C36 56 46 44 32 32" stroke="#DE984F" stroke-width="3.4" stroke-linecap="round" fill="none" />
      <path d="M44 20C44 12 32 12 32 22C32 34 50 48 40 52C28 56 18 44 32 32" stroke="#DE984F" stroke-width="3.4" stroke-linecap="round" fill="none" />
      <circle cx="18" cy="20" r="1" fill="#FFFFFF" />
      <circle cx="46" cy="20" r="1" fill="#FFFFFF" />
      <circle cx="32" cy="48" r="1" fill="#FFFFFF" />
      <circle cx="25" cy="35" r="0.8" fill="#FFFFFF" />
      <circle cx="39" cy="35" r="0.8" fill="#FFFFFF" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-hard-egg': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="34" rx="16" ry="22" fill="#FFFDF8" stroke="#DFD5C4" stroke-width="1.5" />
      <ellipse cx="27" cy="24" rx="4" ry="6" transform="rotate(-15 27 24)" fill="#FFFFFF" fill-opacity="0.5" />
      <circle cx="32" cy="38" r="9" fill="#F4A81D" />
      <circle cx="30" cy="36" r="3" fill="#F9D342" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-cereal': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M12 28C12 46 22 54 32 54C42 54 52 46 52 28H12Z" fill="#A8D8B9" stroke="#68A348" stroke-width="1.5" />
      <path d="M15 32C17.5 43 25 49.5 32 50" stroke="#FFFFFF" stroke-width="1" stroke-opacity="0.4" fill="none" />
      <ellipse cx="32" cy="28" rx="20" ry="6" fill="#FFFDF8" />
      <circle cx="22" cy="28" r="2.5" fill="#F4BA42" />
      <circle cx="28" cy="27" r="2.5" fill="#E22E3E" />
      <circle cx="36" cy="28" r="2.5" fill="#2E4A7A" />
      <circle cx="42" cy="27" r="2.5" fill="#F4BA42" />
      <line x1="42" y1="14" x2="30" y2="34" stroke="#D3DCDB" stroke-width="2.5" stroke-linecap="round" />
      <line x1="42" y1="14" x2="30" y2="34" stroke="#EEF2F1" stroke-width="0.8" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-club-sandwich': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="16" y="42" width="32" height="6" rx="2" fill="#D6943C" />
      <rect x="14" y="38" width="36" height="4" rx="2" fill="#68B04D" />
      <rect x="16" y="34" width="32" height="4" rx="1.5" fill="#C95A64" />
      <polygon points="16,34 24,38 32,34" fill="#F9BA2A" />
      <polygon points="36,34 44,38 48,34" fill="#F9BA2A" />
      <rect x="16" y="16" width="32" height="16" rx="4" fill="#EAB266" stroke="#D6943C" stroke-width="1.5" />
      <circle cx="24" cy="22" r="1" fill="#C47D31" />
      <circle cx="38" cy="24" r="1" fill="#C47D31" />
      <circle cx="31" cy="20" r="0.8" fill="#C47D31" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-bread-loaf': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="12" y="24" width="40" height="16" rx="8" fill="#D9964A" stroke="#B57429" stroke-width="1.5" />
      <path d="M15 27C20 24 44 24 49 27" stroke="#E9AE60" stroke-width="1" fill="none" stroke-opacity="0.5" />
      <line x1="20" y1="27" x2="20" y2="37" stroke="#FCE59F" stroke-width="2.2" stroke-linecap="round" />
      <line x1="28" y1="27" x2="28" y2="37" stroke="#FCE59F" stroke-width="2.2" stroke-linecap="round" />
      <line x1="36" y1="27" x2="36" y2="37" stroke="#FCE59F" stroke-width="2.2" stroke-linecap="round" />
      <line x1="44" y1="27" x2="44" y2="37" stroke="#FCE59F" stroke-width="2.2" stroke-linecap="round" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-pizza-slice': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <polygon points="32,58 7,16 57,16" fill="#D98A38" stroke="#B86A1D" stroke-width="1.2" />
      <path
        d="M5 16C15 8 49 8 59 16C59 20 54 22 48 20C40 18 24 18 16 20C10 22 5 20 5 16Z"
        fill="#E59C45"
        stroke="#B86A1D"
        stroke-width="1.2"
      />
      
      <circle cx="15" cy="14" r="1.5" fill="#8C4A14" fill-opacity="0.6" />
      <circle cx="32" cy="11" r="1.8" fill="#8C4A14" fill-opacity="0.6" />
      <circle cx="48" cy="14" r="1.5" fill="#8C4A14" fill-opacity="0.6" />

      
      <polygon points="32,54 11,20 53,20" fill="#C8281E" />

      
      <polygon points="32,53 13,22 51,22" fill="#FDE68A" />
      <path d="M13 22Q22 28 32 23Q42 28 51 22" fill="#F59E0B" fill-opacity="0.4" />
      
      <path d="M19 23Q21 34 23 26" fill="#FDE68A" />
      <path d="M43 23Q41 33 39 26" fill="#FDE68A" />

      
      <circle cx="28" cy="29" r="6" fill="#B91C1C" stroke="#7F1D1D" stroke-width="0.8" />
      <circle cx="27.5" cy="28.5" r="5" fill="#DC2626" />
      <ellipse cx="26" cy="27" rx="1.5" ry="1" fill="#FCA5A5" fill-opacity="0.6" />

      <circle cx="39" cy="35" r="5.5" fill="#B91C1C" stroke="#7F1D1D" stroke-width="0.8" />
      <circle cx="38.5" cy="34.5" r="4.5" fill="#DC2626" />
      <ellipse cx="37" cy="33" rx="1.4" ry="0.9" fill="#FCA5A5" fill-opacity="0.6" />

      <circle cx="31" cy="44" r="4.5" fill="#B91C1C" stroke="#7F1D1D" stroke-width="0.8" />
      <circle cx="30.5" cy="43.5" r="3.7" fill="#DC2626" />

      
      <path d="M20 37C18 33 22 30 25 33C25 36 22 38 20 37Z" fill="#16A34A" />
      <path d="M37 23C35 20 39 18 41 20C42 23 39 24 37 23Z" fill="#16A34A" />

      
      <path d="M32 23C30 23 28 26 31 28L33 27C35 25 34 23 32 23Z" fill="#E5E7EB" stroke="#9CA3AF" stroke-width="0.6" />

      
      <circle cx="23" cy="26" r="0.6" fill="#15803D" />
      <circle cx="35" cy="40" r="0.6" fill="#15803D" />
      <circle cx="34" cy="32" r="0.6" fill="#15803D" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-burger': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <path d="M12 44C12 50 20 54 32 54C44 54 52 50 52 44H12Z" fill="#E5A358" stroke="#B86A1D" stroke-width="1.2" />

      
      <rect x="9" y="38" width="46" height="8" rx="4" fill="#4A2818" stroke="#2E160C" stroke-width="1" />
      <line x1="16" y1="40" x2="19" y2="44" stroke="#2E160C" stroke-width="1.5" stroke-linecap="round" />
      <line x1="28" y1="40" x2="31" y2="44" stroke="#2E160C" stroke-width="1.5" stroke-linecap="round" />
      <line x1="40" y1="40" x2="43" y2="44" stroke="#2E160C" stroke-width="1.5" stroke-linecap="round" />

      
      <polygon points="10,38 20,44 26,38 38,46 44,38 54,38 52,35 12,35" fill="#F59E0B" stroke="#D97706" stroke-width="0.8" />
      <polygon points="26,38 32,45 36,38" fill="#FBBF24" />

      
      <rect x="12" y="32" width="40" height="5.5" rx="2.5" fill="#DC2626" stroke="#991B1B" stroke-width="0.8" />
      <circle cx="22" cy="34.5" r="1.3" fill="#FEF08A" />
      <circle cx="32" cy="34.5" r="1.3" fill="#FEF08A" />
      <circle cx="42" cy="34.5" r="1.3" fill="#FEF08A" />

      
      <path
        d="M8 32C12 28 16 33 20 29C24 33 28 29 32 32C36 29 40 33 44 29C48 33 52 28 56 32H8Z"
        fill="#22C55E"
        stroke="#15803D"
        stroke-width="0.8"
      />
      <path d="M12 30C20 32 44 32 52 30" stroke="#86EFAC" stroke-width="1" fill="none" />

      
      <circle cx="17" cy="34.5" r="2.15" fill="#80B653" stroke="#4F7C31" stroke-width="0.55" />
      <circle cx="47" cy="34.5" r="2.15" fill="#80B653" stroke="#4F7C31" stroke-width="0.55" />
      <path d="M14 36C17 38 20 37 22 36M42 36C45 38 48 37 50 36" stroke="#F8CD5D" stroke-width="1.1" stroke-linecap="round" fill="none" />

      
      <ellipse cx="32" cy="22" rx="21" ry="14" fill="#E5A358" stroke="#B86A1D" stroke-width="1.2" />
      <path d="M15 19C21 12 43 12 49 19" stroke="#F5C77E" stroke-width="2.2" stroke-linecap="round" fill="none" stroke-opacity="0.8" />

      
      <ellipse cx="23" cy="14" rx="1.2" ry="2" transform="rotate(35 23 14)" fill="#FFFDF8" stroke="#D3C7B6" stroke-width="0.4" />
      <ellipse cx="33" cy="11" rx="1.2" ry="2" transform="rotate(-10 33 11)" fill="#FFFDF8" stroke="#D3C7B6" stroke-width="0.4" />
      <ellipse cx="41" cy="14" rx="1.2" ry="2" transform="rotate(-35 41 14)" fill="#FFFDF8" stroke="#D3C7B6" stroke-width="0.4" />
      <ellipse cx="28" cy="18" rx="1.2" ry="2" transform="rotate(20 28 18)" fill="#FFFDF8" stroke="#D3C7B6" stroke-width="0.4" />
      <ellipse cx="38" cy="19" rx="1.2" ry="2" transform="rotate(-25 38 19)" fill="#FFFDF8" stroke="#D3C7B6" stroke-width="0.4" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-fries': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="15" y="12" width="7" height="25" rx="2" fill="#E9AD35" transform="rotate(-6 18.5 24.5)" />
      <rect x="23" y="8" width="7" height="29" rx="2" fill="#F5CA55" transform="rotate(3 26.5 22.5)" />
      <rect x="32" y="11" width="7" height="27" rx="2" fill="#EDB63D" transform="rotate(-2 35.5 24.5)" />
      <rect x="41" y="15" width="6.5" height="23" rx="2" fill="#F5CA55" transform="rotate(6 44.25 26.5)" />
      <path d="M12 29H52L48 55C47.8 57 46 58 44 58H20C18 58 16.2 57 16 55L12 29Z" fill="#D63B32" stroke="#962B29" stroke-width="1.15" />
      <path d="M13.5 31C23 34 41 34 50.5 31" stroke="#F05A4C" stroke-width="1.1" fill="none" />
      <path d="M20 40H44L42.5 53H21.5L20 40Z" fill="#E94B3E" stroke="#B92E2D" stroke-width="0.8" />
      <path d="M24 44H40" stroke="#FFDB70" stroke-width="1.2" stroke-linecap="round" /><circle cx="47" cy="24" r="1.1" fill="#FFF1B2" />
      <circle cx="17" cy="22" r="0.9" fill="#FFF1B2" /><circle cx="35" cy="17" r="0.75" fill="#FFF1B2" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-hotdog': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="22" y="8" width="20" height="48" rx="10" fill="#F5BA56" />
      <rect x="25" y="10" width="14" height="44" rx="7" fill="#E2A138" />
      <rect x="28" y="6" width="8" height="52" rx="4" fill="#C44F41" />
      <ellipse cx="30" cy="14" rx="1.6" ry="3" fill="#D96B5E" fill-opacity="0.6" />
      <path d="M32 12Q36 16 32 20Q28 24 32 28Q36 32 32 36Q28 40 32 44Q36 48 32 52" stroke="#F9D342" stroke-width="3" stroke-linecap="round" fill="none" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-taco': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M10 42C12 24 24 16 32 16C40 16 52 24 54 42H10Z" fill="#E5B258" />
      <path d="M14 36C18 28 26 24 32 24C38 24 46 28 50 36H14Z" fill="#7C3E29" />
      <circle cx="22" cy="26" r="3" fill="#68B04D" />
      <circle cx="32" cy="23" r="3.5" fill="#E53935" />
      <circle cx="42" cy="26" r="3" fill="#68B04D" />
      <circle cx="27" cy="30" r="2.4" fill="#F4CA38" />
      <path d="M8 44C10 32 22 28 32 28C42 28 54 32 56 44C44 41 20 41 8 44Z" fill="#F5CD84" />
      <path d="M11 41C18 37 46 37 53 41" stroke="#E8B968" stroke-width="1" fill="none" stroke-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-burrito': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="54" rx="15" ry="3" fill="#6F3A38" fill-opacity="0.14" />
      <path d="M18 18C18 12 23 9 32 9C41 9 46 12 46 18V48C46 53 40 56 32 56C24 56 18 53 18 48V18Z" fill="#E7B96E" stroke="#9B652B" stroke-width="1.25" />
      <path d="M20 18C23 14 41 14 44 18C41 23 37 26 32 26C27 26 23 23 20 18Z" fill="#5E3623" />
      <path d="M22 18C25 16 27 20 30 17C33 20 35 16 38 19C40 16 42 18 43 19" stroke="#6EAD4E" stroke-width="2.6" stroke-linecap="round" fill="none" />
      <circle cx="27" cy="18" r="1.75" fill="#E64A3C" /><circle cx="36" cy="18" r="1.6" fill="#F4C646" />
      <path d="M19 30C25 33 39 33 45 30M19 40C25 43 39 43 45 40" stroke="#C58A43" stroke-width="1" stroke-linecap="round" fill="none" stroke-opacity="0.86" />
      <path d="M23 27C25 31 25 47 23 51M41 27C39 31 39 47 41 51" stroke="#F6D995" stroke-width="1.05" stroke-linecap="round" fill="none" stroke-opacity="0.72" />
      <circle cx="27" cy="36" r="1.1" fill="#B67838" /><circle cx="36" cy="46" r="0.9" fill="#B67838" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-steak': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="52" rx="20" ry="3.5" fill="#6F3A38" fill-opacity="0.16" />
      <path d="M15 30C12 20 21 13 33 14C47 14 54 24 51 38C49 48 39 54 27 51C19 49 13 44 15 38C16 35 17 33 15 30Z" fill="#8F3139" stroke="#571D25" stroke-width="1.3" />
      <path d="M18 27C20 19 28 17 35 18C43 19 48 24 48 31C47 39 42 44 35 46" stroke="#BF5660" stroke-width="2" stroke-linecap="round" fill="none" stroke-opacity="0.66" />
      <path d="M20 24L43 37M18 34L37 45M29 19L47 31" stroke="#542225" stroke-width="2.1" stroke-linecap="round" />
      <path d="M22 28C26 25 31 26 33 30C35 34 32 37 29 37C26 37 24 34 25 31" stroke="#F6D8C3" stroke-width="2.2" stroke-linecap="round" fill="none" />
      <path d="M38 21C43 23 46 27 46 32" stroke="#F1BC9B" stroke-width="1.15" stroke-linecap="round" fill="none" stroke-opacity="0.75" />
      <circle cx="22" cy="41" r="1" fill="#D96965" /><circle cx="40" cy="41" r="0.9" fill="#D96965" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-chicken-leg': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="31" cy="53" rx="20" ry="3.3" fill="#6F3A38" fill-opacity="0.14" />
      <path d="M38 38L51 51" stroke="#F6ECD7" stroke-width="5.5" stroke-linecap="round" />
      <circle cx="53" cy="49.5" r="3.3" fill="#FFF7E7" stroke="#D4C3A8" stroke-width="0.75" /><circle cx="49.4" cy="53.5" r="3.3" fill="#FFF7E7" stroke="#D4C3A8" stroke-width="0.75" />
      <path d="M13 31C13 19 23 13 34 16C45 19 48 31 43 40C39 49 24 51 16 43C12 39 12 35 13 31Z" fill="#C9762B" stroke="#814418" stroke-width="1.35" />
      <path d="M17 29C20 20 29 18 36 21C42 24 43 31 39 38C35 44 25 45 19 40C16 37 16 33 17 29Z" fill="#E5A14A" />
      <path d="M20 25C25 22 34 23 39 28M18 34C24 31 34 33 40 37" stroke="#A85C22" stroke-width="1.25" stroke-linecap="round" fill="none" />
      <path d="M21 20C26 18 33 19 36 21" stroke="#F6C678" stroke-width="1.45" stroke-linecap="round" fill="none" />
      <circle cx="23" cy="38" r="1.2" fill="#934718" /><circle cx="33" cy="27" r="1" fill="#934718" /><circle cx="36" cy="35" r="0.9" fill="#934718" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-salmon-fillet': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="33" cy="52" rx="23" ry="3.5" fill="#6F3A38" fill-opacity="0.14" />
      <path d="M11 41L46 18C49 17 53 19 54 22L55 31C55 34 52 38 48 40L21 55C17 56 13 53 12 49L10 45C9 43 10 42 11 41Z" fill="#DF6D45" stroke="#9E3F2C" stroke-width="1.25" />
      <path d="M11 41L46 18C49 17 52 19 54 22L52 25L16 48L10 45C9 43 10 42 11 41Z" fill="#445E4A" />
      <path d="M19 42L29 36M25 47L36 40M33 50L45 43M38 32L48 26" stroke="#FFD5C7" stroke-width="1.8" stroke-linecap="round" />
      <path d="M17 45L27 39M31 52L42 45" stroke="#AD4A36" stroke-width="1" stroke-linecap="round" stroke-opacity="0.78" />
      <path d="M17 47C20 51 25 53 29 52" stroke="#FFAA87" stroke-width="1.25" stroke-linecap="round" fill="none" />
      <path d="M45 19C47 16 50 14 52 16" stroke="#72A950" stroke-width="1.8" stroke-linecap="round" fill="none" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-fried-egg': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M16 32C12 42 22 54 36 52C48 50 54 38 48 26C42 16 22 20 16 32Z" fill="#FFFDF8" stroke="#DFD5C4" stroke-width="1.5" />
      <circle cx="32" cy="34" r="10" fill="#F4A81D" />
      <ellipse cx="28" cy="30" rx="3" ry="2" fill="#FFF" fill-opacity="0.6" />
      <path d="M22 26C25 23 40 24 45 29" stroke="#FFFFFF" stroke-width="1" fill="none" stroke-opacity="0.5" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-cheese-wedge': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="12,46 54,46 46,24 16,24" fill="#F4BA42" stroke="#D9822B" stroke-width="1.5" />
      <polygon points="46,24 54,46 56,40 48,18" fill="#D99726" />
      <line x1="15" y1="42" x2="51" y2="42" stroke="#E3A430" stroke-width="0.8" stroke-opacity="0.5" />
      <circle cx="28" cy="36" r="3.5" fill="#D99726" fill-opacity="0.7" />
      <circle cx="42" cy="38" r="2.5" fill="#D99726" fill-opacity="0.7" />
      <circle cx="34" cy="30" r="2" fill="#D99726" fill-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-breakfast-plate': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="32" r="23" fill="#DCE7E4" stroke="#A9BBB6" stroke-width="1.4" />
      <circle cx="32" cy="32" r="19" fill="#FFFDF8" />
      <path d="M15 26C14 20 19 17 25 18C32 18 35 21 34 27L32 41H17L15 26Z" fill="#D89646" stroke="#A76127" stroke-width="1" />
      <path d="M18 27C18 22 21 21 25 21C29 21 31 23 31 27L29.5 37H19.5L18 27Z" fill="#F2C576" />
      <path d="M35 25C39 20 47 23 47 30C47 36 43 40 38 40C32 40 29 35 31 30C32 27 33 26 35 25Z" fill="#FFFDF8" stroke="#E2D8CB" stroke-width="0.85" />
      <circle cx="39" cy="31" r="4.5" fill="#F4A81D" /><ellipse cx="37.5" cy="29.5" rx="1.5" ry="1" fill="#FFE876" fill-opacity="0.78" />
      <path d="M18 44C23 40 27 45 32 41C37 38 41 43 46 40" stroke="#B63838" stroke-width="4" stroke-linecap="round" fill="none" />
      <path d="M18 44C23 40 27 45 32 41C37 38 41 43 46 40" stroke="#F7C1B7" stroke-width="1.25" stroke-linecap="round" fill="none" />
      <circle cx="43" cy="19" r="2.2" fill="#6FA653" /><circle cx="47" cy="20" r="1.8" fill="#83B861" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-ham-roast': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="32" rx="16" ry="22" fill="#C95A64" stroke="#A33E46" stroke-width="1.5" />
      <path d="M16 32C16 18 23 10 32 10C41 10 48 18 48 32" stroke="#D98C4E" stroke-width="2.5" stroke-linecap="round" fill="none" />
      <line x1="22" y1="22" x2="42" y2="42" stroke="#FAF7F2" stroke-width="1" stroke-opacity="0.5" />
      <line x1="42" y1="22" x2="22" y2="42" stroke="#FAF7F2" stroke-width="1" stroke-opacity="0.5" />
      <circle cx="32" cy="28" r="4.5" fill="#FFFDF8" stroke="#D3DCDB" stroke-width="1" />
      <circle cx="32" cy="28" r="2" fill="#9E462E" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-shawarma': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="55" rx="15" ry="3" fill="#6F3A38" fill-opacity="0.14" />
      <path d="M20 16C24 11 40 11 44 16L42 52C38 56 26 56 22 52L20 16Z" fill="#E6B966" stroke="#93602B" stroke-width="1.2" />
      <path d="M21 18C24 15 26 19 29 16C32 20 35 15 38 18C40 16 42 18 43 19L41 27C35 30 29 30 23 27L21 18Z" fill="#5D3521" />
      <path d="M23 18C27 16 29 21 32 18C35 21 38 16 41 19" stroke="#69A850" stroke-width="2.6" stroke-linecap="round" fill="none" />
      <circle cx="27" cy="19" r="1.8" fill="#E54C3C" /><circle cx="37" cy="19" r="1.6" fill="#F4C646" />
      <path d="M22 30C27 33 37 33 42 30M22 38C27 41 37 41 42 38M22 46C27 49 37 49 42 46" stroke="#C68338" stroke-width="1.05" stroke-linecap="round" fill="none" />
      <path d="M26 27C24 35 24 46 26 52M38 27C40 35 40 46 38 52" stroke="#F6D789" stroke-width="1" stroke-linecap="round" fill="none" stroke-opacity="0.7" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-sub-sandwich': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="18" y="8" width="28" height="48" rx="2" fill="#E8ECEB" />
      <rect x="22" y="10" width="20" height="44" rx="10" fill="#E5A358" />
      <rect x="18" y="24" width="28" height="4" rx="2" fill="#68B04D" />
      <rect x="19" y="32" width="26" height="4" rx="2" fill="#E84855" />
      <polygon points="20,20 28,20 24,26" fill="#FBD46D" />
      <polygon points="36,36 44,36 40,42" fill="#FBD46D" />
      <path d="M25 13C29 11 35 11 39 13" stroke="#F0BB80" stroke-width="0.9" fill="none" stroke-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-skewer': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="29.3" y="3" width="5.4" height="57" rx="2.7" fill="#C89258" />
      <rect x="29.3" y="3" width="2" height="57" rx="1" fill="#DBAE78" opacity="0.7" />
      <circle cx="32" cy="4.5" r="3.4" fill="#C89258" />
      <rect x="21" y="10" width="20" height="11.5" rx="4.5" fill="#B5573D" />
      <rect x="21" y="10" width="20" height="4" rx="2" fill="#C96F58" opacity="0.55" />
      <rect x="21" y="17.5" width="20" height="4" rx="2" fill="#8A3F2A" opacity="0.4" />
      <rect x="19.5" y="22.5" width="23" height="8" rx="3.5" fill="#68A348" />
      <rect x="19.5" y="22.5" width="23" height="3" rx="1.5" fill="#88C161" opacity="0.6" />
      <rect x="20.5" y="31.5" width="22" height="13" rx="5" fill="#9E462E" />
      <rect x="20.5" y="31.5" width="22" height="4.5" rx="2.2" fill="#C2694A" opacity="0.5" />
      <rect x="20.5" y="40" width="22" height="5" rx="2.5" fill="#6E2F1C" opacity="0.4" />
      <ellipse cx="27" cy="35" rx="3.4" ry="1.8" fill="#D98A6B" opacity="0.5" />
      <rect x="23" y="45.5" width="18" height="7.5" rx="3" fill="#FAD277" />
      <rect x="23" y="45.5" width="18" height="2.8" rx="1.4" fill="#FFE9A8" opacity="0.7" />
      <path d="M24 21C24 23.5 25 24.5 24.5 26" stroke="#6E2F1C" stroke-width="1.1" stroke-linecap="round" opacity="0.35" fill="none" />
      <path d="M38 32C38.5 35 37.5 38 38.5 41" stroke="#6E2F1C" stroke-width="1.1" stroke-linecap="round" opacity="0.3" fill="none" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-paella': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <path d="M6 34C6 27 10 27 12 30" stroke="#3D3530" stroke-width="3.5" stroke-linecap="round" fill="none" />
      <path d="M58 34C58 27 54 27 52 30" stroke="#3D3530" stroke-width="3.5" stroke-linecap="round" fill="none" />

      
      <circle cx="32" cy="34" r="23" fill="#2C2623" stroke="#1A1614" stroke-width="1.5" />
      <circle cx="32" cy="34" r="20" fill="#3D3530" />
      
      <circle cx="32" cy="34" r="18.5" fill="#E89B1D" />
      <circle cx="32" cy="34" r="18" fill="#F4BA38" />
      
      <circle cx="24" cy="32" r="1" fill="#D98A15" />
      <circle cx="32" cy="26" r="1" fill="#D98A15" />
      <circle cx="38" cy="38" r="1" fill="#D98A15" />
      <circle cx="28" cy="42" r="1" fill="#D98A15" />

      
      <path d="M22 28C20 22 26 18 30 20C34 22 33 26 28 27" stroke="#F26A36" stroke-width="3.8" stroke-linecap="round" fill="none" />
      <polygon points="30,19 35,17 33,22" fill="#E22E3E" />
      <path d="M38 38C44 38 46 44 42 47C38 50 35 46 36 42" stroke="#F26A36" stroke-width="3.8" stroke-linecap="round" fill="none" />
      <polygon points="43,48 46,52 41,51" fill="#E22E3E" />

      
      <ellipse cx="40" cy="26" rx="4.5" ry="3" transform="rotate(-30 40 26)" fill="#1A202C" />
      <ellipse cx="40" cy="26" rx="3" ry="1.8" transform="rotate(-30 40 26)" fill="#F59E0B" />

      <ellipse cx="20" cy="40" rx="4.5" ry="3" transform="rotate(45 20 40)" fill="#1A202C" />
      <ellipse cx="20" cy="40" rx="3" ry="1.8" transform="rotate(45 20 40)" fill="#F59E0B" />

      
      <circle cx="32" cy="34" r="4.2" fill="#8C2518" stroke="#5E140B" stroke-width="0.8" />
      <circle cx="30.5" cy="33" r="0.8" fill="#E8B0A8" />
      <circle cx="33.5" cy="35" r="0.8" fill="#E8B0A8" />

      
      <circle cx="27" cy="36" r="1.8" fill="#4A7A2A" />
      <circle cx="37" cy="32" r="1.8" fill="#4A7A2A" />
      <circle cx="23" cy="23" r="1.6" fill="#4A7A2A" />
      <circle cx="32" cy="44" r="1.8" fill="#4A7A2A" />

      
      <path d="M32 17C35 17 38 20 38 23L32 23Z" fill="#FDE047" stroke="#CA8A04" stroke-width="0.8" />
      <path d="M33 18.5C34.5 18.5 36.5 20.5 36.5 22L33 22Z" fill="#FEF08A" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-soup-bowl': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <path
        d="M10 27C10 46 20 55 32 55C44 55 54 46 54 27H10Z"
        fill="#C85A32"
        stroke="#9E3B18"
        stroke-width="1.5"
      />
      
      <rect x="25" y="55" width="14" height="3" rx="1.5" fill="#9E3B18" />
      
      <path d="M13 30C15 44 24 51 32 52" stroke="#E57D58" stroke-width="1.5" fill="none" stroke-opacity="0.7" />

      
      <ellipse cx="32" cy="27" rx="21" ry="8" fill="#A8581E" />
      <ellipse cx="32" cy="26.5" rx="19.5" ry="6.8" fill="#D9822B" />
      <ellipse cx="32" cy="26" rx="17" ry="5.2" fill="#F4A838" />

      
      <ellipse cx="23" cy="26" rx="5.5" ry="4" transform="rotate(-15 23 26)" fill="#FFFDF8" stroke="#DFD5C4" stroke-width="0.6" />
      <circle cx="23.5" cy="26" r="2.8" fill="#F5651B" />
      <circle cx="22.5" cy="25" r="0.9" fill="#FFA34D" />

      
      <path d="M38 23C42 21 44 25 41 28C38 29 36 26 38 23Z" fill="#52321A" />
      <path d="M39 24L41 27M37 26L41 25" stroke="#7A4B29" stroke-width="0.7" />

      
      <circle cx="31" cy="25" r="2.2" fill="#4A7A2A" />
      <circle cx="31" cy="25" r="1.1" fill="#78B846" />
      <circle cx="34" cy="28" r="1.8" fill="#4A7A2A" />
      <circle cx="34" cy="28" r="0.9" fill="#78B846" />
      <circle cx="27" cy="29" r="0.7" fill="#FFFDF8" />
      <circle cx="29" cy="23" r="0.7" fill="#FFFDF8" />

      
      <path d="M22 17Q25 11 22 5" stroke="#FAF7F2" stroke-width="1.8" stroke-linecap="round" fill="none" stroke-opacity="0.8" />
      <path d="M32 15Q35 9 32 3" stroke="#FAF7F2" stroke-width="2.2" stroke-linecap="round" fill="none" stroke-opacity="0.85" />
      <path d="M42 17Q45 11 42 5" stroke="#FAF7F2" stroke-width="1.8" stroke-linecap="round" fill="none" stroke-opacity="0.8" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-ramen-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <path
        d="M10 26C10 47 21 56 32 56C43 56 54 47 54 26H10Z"
        fill="#1E293B"
        stroke="#0F172A"
        stroke-width="1.5"
      />
      
      <rect x="25" y="56" width="14" height="3" rx="1.5" fill="#0F172A" />
      
      <path d="M10 27H54" stroke="#DC2626" stroke-width="2.5" />
      <path d="M14 27H18M22 27H26M30 27H34M38 27H42M46 27H50" stroke="#FFF" stroke-width="1.5" />

      
      <ellipse cx="32" cy="27" rx="21" ry="8" fill="#C2782A" />
      <ellipse cx="32" cy="26.5" rx="19" ry="6.5" fill="#E89B38" />

      
      <path d="M16 26Q20 22 24 26Q28 22 32 26Q36 22 40 26" stroke="#FEF08A" stroke-width="2.2" stroke-linecap="round" fill="none" />
      <path d="M18 29Q22 25 26 29Q30 25 34 29Q38 25 42 29" stroke="#FDE047" stroke-width="2.2" stroke-linecap="round" fill="none" />

      
      <rect x="14" y="10" width="9" height="18" rx="1" transform="rotate(-15 14 10)" fill="#14211A" stroke="#0B1410" stroke-width="0.8" />

      
      <ellipse cx="26" cy="28" rx="7.5" ry="5.5" transform="rotate(20 26 28)" fill="#C26A3A" stroke="#7C2D12" stroke-width="0.8" />
      <path d="M22 26C24 24 28 24 30 27C30 30 27 32 24 31" stroke="#FEE2E2" stroke-width="1.6" fill="none" />

      
      <ellipse cx="37" cy="28" rx="6" ry="4.5" transform="rotate(-20 37 28)" fill="#FFFDF8" stroke="#DFD5C4" stroke-width="0.8" />
      <circle cx="37.5" cy="28" r="3" fill="#EA580C" />
      <circle cx="36.5" cy="27" r="1" fill="#FDBA74" />

      
      <circle cx="29" cy="34" r="4.2" fill="#FFFFFF" stroke="#F472B6" stroke-width="1.2" />
      <path d="M29 32C30.5 32 31.5 33 31.5 34C31.5 35.5 30 36 29 36C27.5 36 27 34.5 27.5 33.5" stroke="#EC4899" stroke-width="1.2" fill="none" stroke-linecap="round" />

      
      <circle cx="33" cy="23" r="1.6" fill="#16A34A" />
      <circle cx="43" cy="24" r="1.6" fill="#16A34A" />
      <circle cx="21" cy="33" r="1.4" fill="#16A34A" />

      
      <line x1="12" y1="8" x2="48" y2="21" stroke="#A16207" stroke-width="2.4" stroke-linecap="round" />
      <line x1="14" y1="5" x2="52" y2="19" stroke="#CA8A04" stroke-width="1.8" stroke-linecap="round" />

      
      <path d="M15 35C18 46 25 51 32 52C39 51 46 46 49 35" stroke="#334155" stroke-width="1.25" fill="none" stroke-opacity="0.8" />
      <path d="M21 45C25 48 39 48 43 45" stroke="#64748B" stroke-width="0.9" fill="none" stroke-opacity="0.72" />
      <ellipse cx="19" cy="24" rx="0.8" ry="1.2" transform="rotate(35 19 24)" fill="#FFF4C7" />
      <ellipse cx="46" cy="29" rx="0.8" ry="1.2" transform="rotate(-25 46 29)" fill="#FFF4C7" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-sushi-set': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <rect x="8" y="16" width="48" height="34" rx="4" fill="#D4A373" stroke="#8C5C33" stroke-width="1.5" />
      <line x1="8" y1="26" x2="56" y2="26" stroke="#C08A56" stroke-width="0.8" />
      <line x1="8" y1="36" x2="56" y2="36" stroke="#C08A56" stroke-width="0.8" />
      
      <rect x="12" y="50" width="8" height="6" rx="1.5" fill="#8C5C33" />
      <rect x="44" y="50" width="8" height="6" rx="1.5" fill="#8C5C33" />

      
      <rect x="12" y="20" width="18" height="10" rx="4" fill="#FFFDF8" stroke="#DFD5C4" stroke-width="0.8" />
      <path d="M10 23C10 19 14 18 21 18C28 18 32 19 32 23C32 25 28 26 21 26C14 26 10 25 10 23Z" fill="#F97316" stroke="#EA580C" stroke-width="0.8" />
      <line x1="14" y1="20" x2="28" y2="24" stroke="#FFF" stroke-width="1" stroke-opacity="0.8" />
      <line x1="17" y1="19" x2="25" y2="25" stroke="#FFF" stroke-width="0.8" stroke-opacity="0.8" />
      <rect x="19" y="18" width="4" height="12" rx="1" fill="#0F172A" />

      
      <rect x="12" y="34" width="18" height="10" rx="4" fill="#FFFDF8" stroke="#DFD5C4" stroke-width="0.8" />
      <path d="M10 37C10 33 14 32 21 32C28 32 32 33 32 37C32 39 28 40 21 40C14 40 10 39 10 37Z" fill="#BE123C" stroke="#9F1239" stroke-width="0.8" />
      <ellipse cx="19" cy="35" rx="3" ry="1.2" fill="#FB7185" fill-opacity="0.6" />

      
      <circle cx="41" cy="24" r="7" fill="#0F172A" />
      <circle cx="41" cy="24" r="5.5" fill="#FFFDF8" />
      <rect x="39" y="22" width="4" height="4" rx="1" fill="#65A30D" />

      
      <circle cx="41" cy="39" r="7" fill="#0F172A" />
      <circle cx="41" cy="39" r="5.5" fill="#FFFDF8" />
      <rect x="39" y="37" width="4" height="4" rx="1" fill="#BE123C" />

      
      <circle cx="50" cy="20" r="3.2" fill="#84CC16" />
      <circle cx="50.5" cy="19.5" r="1.5" fill="#A3E635" />
      <path d="M49 45C47 43 51 41 53 43C54 45 52 47 49 45Z" fill="#FDA4AF" />
      <path d="M51 43C50 41 53 40 54 42" stroke="#F43F5E" stroke-width="0.8" fill="none" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-sushi-nigiri': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="10" y="28" width="44" height="18" rx="8" fill="#FFFDF9" stroke="#DFD5C4" stroke-width="1.5" />
      <path d="M8 26C8 22 22 18 32 18C42 18 56 22 56 26C56 28 42 32 32 32C22 32 8 28 8 26Z" fill="#F26A36" />
      <line x1="16" y1="22" x2="48" y2="28" stroke="#FFF" stroke-width="1" stroke-opacity="0.6" />
      <rect x="28" y="18" width="8" height="28" rx="2" fill="#1E1A18" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-maki-roll': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="32" r="22" fill="#1E2322" />
      <circle cx="32" cy="32" r="16" fill="#FFFDF8" />
      <rect x="26" y="26" width="12" height="12" rx="3" fill="#F26A36" />
      <circle cx="28" cy="28" r="2.5" fill="#68A348" />
      <circle cx="36" cy="36" r="2.5" fill="#F4CA38" />
      <circle cx="20" cy="24" r="1.2" fill="#FFFFFF" fill-opacity="0.4" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-dimsum-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="32" r="23" fill="#D99726" stroke="#8C5C1A" stroke-width="1.5" />
      <circle cx="32" cy="32" r="19" fill="#FCE59F" />
      <circle cx="24" cy="26" r="6" fill="#FAF7F2" stroke="#DFD5C4" stroke-width="1" />
      <path d="M24 21C22 22 21 25 22 27" stroke="#E8DCC8" stroke-width="0.8" fill="none" />
      <circle cx="40" cy="26" r="6" fill="#FAF7F2" stroke="#DFD5C4" stroke-width="1" />
      <path d="M40 21C38 22 37 25 38 27" stroke="#E8DCC8" stroke-width="0.8" fill="none" />
      <circle cx="32" cy="38" r="6" fill="#FAF7F2" stroke="#DFD5C4" stroke-width="1" />
      <path d="M32 33C30 34 29 37 30 39" stroke="#E8DCC8" stroke-width="0.8" fill="none" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-gyoza-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M12 40C12 22 24 14 36 14C48 14 54 22 52 40H12Z" fill="#FAF7F2" stroke="#DFD5C4" stroke-width="1.5" />
      <path d="M12 40H52" stroke="#A86E45" stroke-width="4" stroke-linecap="round" />
      <path d="M22 18L24 24M32 15L32 22M42 18L40 24" stroke="#DFD5C4" stroke-width="1.5" stroke-linecap="round" />
      <path d="M17 33C24 30 40 30 47 33" stroke="#E8DCC8" stroke-width="0.9" fill="none" stroke-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-bao-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M14 44C14 26 22 18 32 18C42 18 50 26 50 44C40 48 24 48 14 44Z" fill="#FFFDF8" stroke="#DFD5C4" stroke-width="1.5" />
      <circle cx="32" cy="20" r="3" fill="#DFD5C4" />
      <path d="M24 26C28 22 32 20 32 20M40 26C36 22 32 20 32 20" stroke="#DFD5C4" stroke-width="1.5" stroke-linecap="round" fill="none" />
      <path d="M18 40C24 43.5 40 43.5 46 40" stroke="#EFE7DA" stroke-width="1" fill="none" stroke-opacity="0.6" />
      <path d="M20 29C22 26 24 24.5 26 24.5M44 29C42 26 40 24.5 38 24.5" stroke="#FFFFFF" stroke-width="1.1" stroke-linecap="round" fill="none" stroke-opacity="0.8" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0.0 1.0) translate(32 34) scale(0.72) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-onigiri-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M32 12C34 12 48 38 48 44C48 50 42 52 32 52C22 52 16 50 16 44C16 38 30 12 32 12Z" fill="#FFFDF8" stroke="#DFD5C4" stroke-width="1.5" />
      <rect x="24" y="38" width="16" height="14" rx="2" fill="#1E2322" />
      <path d="M19 30C22 26 28 20 32 18" stroke="#EFE7DA" stroke-width="1" fill="none" stroke-opacity="0.5" />
      <circle cx="32" cy="26" r="2.5" fill="#E22E3E" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-takoyaki-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="8,40 56,40 50,54 14,54" fill="#D99726" />
      <circle cx="22" cy="34" r="9" fill="#E5A352" />
      <circle cx="34" cy="30" r="9" fill="#E5A352" />
      <circle cx="44" cy="36" r="8" fill="#E5A352" />
      <path d="M16 32Q32 24 48 32" stroke="#52321A" stroke-width="3" stroke-linecap="round" fill="none" />
      <ellipse cx="19" cy="30" rx="2.2" ry="1.3" transform="rotate(-25 19 30)" fill="#F2BB74" fill-opacity="0.6" />
      <circle cx="26" cy="30" r="1.2" fill="#4A6B53" />
      <circle cx="36" cy="28" r="1.2" fill="#4A6B53" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-tempura-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="51" rx="23" ry="5" fill="#D6DFDB" stroke="#B8C9C3" stroke-width="0.9" />
      <ellipse cx="32" cy="49.5" rx="20" ry="3.6" fill="#FFFDF8" />
      <path d="M44 39L56 49L51 36L47 43L44 34Z" fill="#E95A4D" stroke="#AB382F" stroke-width="0.85" stroke-linejoin="round" />
      <path d="M13 18C11 27 20 39 45 44C45 37 36 24 22 15C18 12 14 14 13 18Z" fill="#E9B842" stroke="#A86A18" stroke-width="1.25" />
      <path d="M17 20C21 27 31 35 41 40" stroke="#FFF0A8" stroke-width="2.2" stroke-linecap="round" fill="none" />
      <path d="M18 26C23 28 27 33 30 38" stroke="#D28A23" stroke-width="1.25" stroke-linecap="round" fill="none" />
      <circle cx="22" cy="21" r="1.05" fill="#C9821E" /><circle cx="26" cy="27" r="1.2" fill="#C9821E" /><circle cx="33" cy="35" r="1.1" fill="#C9821E" /><circle cx="38" cy="38" r="0.9" fill="#C9821E" />
      <path d="M19 44C19 37 25 33 31 36C35 38 36 44 33 48H21C19 47 18 46 19 44Z" fill="#F1C34D" stroke="#A86A18" stroke-width="1" />
      <path d="M24 38C25 34 28 32 30 31" stroke="#6E9A48" stroke-width="1.7" stroke-linecap="round" />
      <circle cx="39" cy="48" r="3.3" fill="#7A4A28" /><ellipse cx="38" cy="47" rx="1.4" ry="0.7" fill="#B67A45" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-taiyaki-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="28" cy="32" rx="16" ry="12" fill="#D99726" stroke="#8C5C1A" stroke-width="1.2" />
      <polygon points="42,32 54,22 54,42" fill="#D99726" stroke="#8C5C1A" stroke-width="1.2" />
      <circle cx="20" cy="28" r="2" fill="#1E1A18" />
      <line x1="26" y1="26" x2="34" y2="38" stroke="#8C5C1A" stroke-width="1.5" />
      <line x1="30" y1="24" x2="38" y2="36" stroke="#8C5C1A" stroke-width="1.5" />
      <path d="M16 26C19 22 24 20 28 20" stroke="#E9AE55" stroke-width="1" fill="none" stroke-opacity="0.5" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-fortune-cookie': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M16 28C14 42 26 50 32 46C38 50 50 42 48 28C38 32 26 32 16 28Z" fill="#F4CA64" stroke="#D99726" stroke-width="1.5" />
      <rect x="22" y="32" width="20" height="6" fill="#FFFDF8" stroke="#D3DCDB" stroke-width="0.8" />
      <path d="M20 32C24 36 40 36 44 32" stroke="#E8B968" stroke-width="0.9" fill="none" stroke-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-spring-roll': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="12" y="24" width="34" height="14" rx="7" transform="rotate(-25 12 24)" fill="#D99726" stroke="#8C5C1A" stroke-width="1.2" />
      <rect x="22" y="36" width="34" height="14" rx="7" transform="rotate(-25 22 36)" fill="#E5A352" stroke="#8C5C1A" stroke-width="1.2" />
      <line x1="16" y1="26" x2="42" y2="18" stroke="#F0BC7A" stroke-width="0.8" stroke-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-bento-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <rect x="7" y="11" width="50" height="42" rx="5" fill="#1E293B" stroke="#0F172A" stroke-width="1.5" />
      <rect x="9" y="13" width="46" height="38" rx="3.5" fill="#991B1B" />

      
      <line x1="30" y1="13" x2="30" y2="51" stroke="#0F172A" stroke-width="1.8" />
      <line x1="30" y1="32" x2="55" y2="32" stroke="#0F172A" stroke-width="1.8" />

      
      <rect x="11" y="15" width="17" height="34" rx="2" fill="#FFFDF8" stroke="#E2E8F0" stroke-width="0.8" />
      <circle cx="19.5" cy="32" r="3.2" fill="#BE123C" stroke="#9F1239" stroke-width="0.6" />
      <circle cx="19" cy="31.5" r="1.1" fill="#F43F5E" />
      <circle cx="15" cy="22" r="0.6" fill="#1E293B" />
      <circle cx="24" cy="24" r="0.6" fill="#1E293B" />
      <circle cx="16" cy="42" r="0.6" fill="#1E293B" />
      <circle cx="23" cy="40" r="0.6" fill="#1E293B" />

      
      <rect x="32" y="15" width="21" height="15" rx="2" fill="#FEF3C7" stroke="#FDE68A" stroke-width="0.6" />
      <circle cx="38" cy="22" r="4.5" fill="#B45309" stroke="#78350F" stroke-width="0.8" />
      <circle cx="37.5" cy="21.5" r="3.6" fill="#D97706" />
      <circle cx="46" cy="21" r="4" fill="#B45309" stroke="#78350F" stroke-width="0.8" />
      <circle cx="45.5" cy="20.5" r="3.2" fill="#D97706" />
      <path d="M48 24C49 24 51 26 51 28L48 28Z" fill="#FDE047" stroke="#CA8A04" stroke-width="0.6" />

      
      <rect x="32" y="34" width="21" height="15" rx="2" fill="#FEF3C7" stroke="#FDE68A" stroke-width="0.6" />
      
      <rect x="34" y="36" width="7" height="11" rx="1.5" fill="#FACC15" stroke="#CA8A04" stroke-width="0.8" />
      <path d="M36 38C38 38 38 45 36 45" stroke="#EAB308" stroke-width="0.8" fill="none" />
      <rect x="42" y="36" width="7" height="11" rx="1.5" fill="#FACC15" stroke="#CA8A04" stroke-width="0.8" />
      <path d="M44 38C46 38 46 45 44 45" stroke="#EAB308" stroke-width="0.8" fill="none" />
      
      <ellipse cx="50" cy="41" rx="1.8" ry="3.5" transform="rotate(15 50 41)" fill="#65A30D" />
      <circle cx="50" cy="40" r="0.9" fill="#84CC16" />
      <circle cx="50.5" cy="43" r="0.9" fill="#84CC16" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-pad-thai': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="16,22 48,22 44,54 20,54" fill="#FFFDF8" stroke="#D3DCDB" stroke-width="1.5" />
      <polygon points="12,22 52,22 48,16 16,16" fill="#C8281E" />
      <circle cx="32" cy="38" r="6" fill="#C8281E" />
      <path d="M22 14L46 6" stroke="#B58A59" stroke-width="2.5" stroke-linecap="round" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-bibimbap-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="32" r="22" fill="#2C2623" />
      <circle cx="32" cy="32" r="18" fill="#FAF7F2" />
      <path d="M32 14A18 18 0 0 1 48 26L32 32Z" fill="#E86E24" />
      <path d="M48 26A18 18 0 0 1 44 46L32 32Z" fill="#4A6B53" />
      <path d="M44 46A18 18 0 0 1 24 48L32 32Z" fill="#6F361E" />
      <path d="M24 48A18 18 0 0 1 16 28L32 32Z" fill="#F4CA38" />
      <circle cx="32" cy="32" r="6" fill="#F4A81D" stroke="#FFF" stroke-width="1.5" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-edamame-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M12 42C12 24 24 16 48 14C44 28 36 44 12 42Z" fill="#68A348" stroke="#4A7A2A" stroke-width="1.5" />
      <path d="M15 38C22 32 34 24 44 19" stroke="#7FBA5A" stroke-width="1" fill="none" stroke-opacity="0.6" />
      <circle cx="22" cy="34" r="4.5" fill="#88C43E" />
      <circle cx="32" cy="28" r="4.5" fill="#88C43E" />
      <circle cx="42" cy="22" r="4" fill="#88C43E" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-matcha-dish': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M14 26C14 46 22 52 32 52C42 52 50 46 50 26H14Z" fill="#2C2623" stroke="#15110F" stroke-width="1.2" />
      <path d="M17 32C19 42 26 47.5 32 48" stroke="#6C584D" stroke-width="1" fill="none" stroke-opacity="0.72" />
      <path d="M47 31C45 41 39 47 33 49" stroke="#0E0B0A" stroke-width="1" fill="none" stroke-opacity="0.52" />
      <ellipse cx="32" cy="26" rx="18" ry="6" fill="#5A8A34" />
      <ellipse cx="32" cy="26" rx="14" ry="4" fill="#78B846" />
      <path d="M23 26C26 23.8 28 28.2 31 26C34 23.8 36 28.2 40 25.7" stroke="#B9D882" stroke-width="0.8" fill="none" stroke-opacity="0.72" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0.0 6.0) translate(32 34) scale(0.72) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-tomato': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="35" r="22" fill="#E23E2A" />
      <ellipse cx="27" cy="29" rx="14" ry="16" fill="#EA533F" />
      <ellipse cx="21" cy="23" rx="3.5" ry="6" transform="rotate(-25 21 23)" fill="#FFFFFF" fill-opacity="0.45" />
      <path d="M32 17C32 10 34 5 36 4" stroke="#3D5A45" stroke-width="2.5" stroke-linecap="round" fill="none" />
      <path d="M32 17L22 13M32 17L42 13M32 17L27 21M32 17L37 21" stroke="#4A6B53" stroke-width="2.2" stroke-linecap="round" fill="none" />
      <ellipse cx="32" cy="17" rx="4" ry="2" fill="#5A8064" />
      <path d="M18 40C20 46 24 51 30 54" stroke="#C92F23" stroke-width="1" stroke-linecap="round" fill="none" stroke-opacity="0.52" />
      
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0.0 5.0) translate(32 34) scale(0.76) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-basil': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M32 56V18" stroke="#3D5A45" stroke-width="2.5" stroke-linecap="round" />
      <path d="M32 18C20 22 18 36 32 40C46 36 44 22 32 18Z" fill="#4A6B53" />
      <path d="M32 22C24 25 22 34 32 37" stroke="#5A8064" stroke-width="1" fill="none" stroke-opacity="0.6" />
      <path d="M32 30C16 28 8 42 24 50C32 46 32 34 32 30Z" fill="#5A8064" />
      <path d="M32 30C48 28 56 42 40 50C32 46 32 34 32 30Z" fill="#4A6B53" />
      <path d="M32 34C25 36 20 42 24 47" stroke="#4A6B53" stroke-width="0.8" fill="none" stroke-opacity="0.5" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-garlic': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M32 52C45 52 49 43 47 32C45 21 36 12 32 10C28 12 19 21 17 32C15 43 19 52 32 52Z" fill="#FAF6EE" stroke="#CFC5B2" stroke-width="1.5" />
      <path d="M32 10V52" stroke="#DFD7C7" stroke-width="1.2" />
      <path d="M32 10C25 22 23 38 26 50" stroke="#DFD7C7" stroke-width="1" />
      <path d="M32 10C39 22 41 38 38 50" stroke="#DFD7C7" stroke-width="1" />
      <path d="M32 10V4" stroke="#8C7355" stroke-width="2" stroke-linecap="round" />
      <ellipse cx="24" cy="20" rx="2.5" ry="4" transform="rotate(-15 24 20)" fill="#FFFFFF" fill-opacity="0.5" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-avocado': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M32 10C24 10 18 18 16 28C14 42 22 56 32 56C42 56 50 42 48 28C46 18 40 10 32 10Z" fill="#3D5A45" />
      <path d="M32 14C26 14 21 21 20 29C18 41 24 52 32 52C40 52 46 41 44 29C43 21 38 14 32 14Z" fill="#8DB355" />
      <path d="M25 20C22 25 20 33 21 40" stroke="#9FC26A" stroke-width="1.2" fill="none" stroke-opacity="0.5" />
      <circle cx="32" cy="36" r="8" fill="#6F4827" stroke="#4A2E16" stroke-width="1.5" />
      <circle cx="29.5" cy="33.5" r="2.5" fill="#8C5C33" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-lemon': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M12 28C10 20 20 12 32 12C46 12 56 22 54 32C52 44 38 52 24 50C14 48 10 38 12 28Z" fill="#F4CA38" stroke="#D9971D" stroke-width="1.5" />
      <ellipse cx="24" cy="24" rx="4.5" ry="7" transform="rotate(-25 24 24)" fill="#FFFFFF" fill-opacity="0.35" />
      <path d="M30 12C32 2 44 4 48 10C42 16 34 16 30 12Z" fill="#4A6B53" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-lime': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="32" r="22" fill="#4A7A2A" />
      <circle cx="32" cy="32" r="18" fill="#E8F4CC" />
      <path d="M18 22C24 18 40 18 46 22" stroke="#D5E8AE" stroke-width="1" fill="none" stroke-opacity="0.6" />
      <path d="M32 14L32 50M14 32L50 32M20 20L44 44M44 20L20 44" stroke="#D5E8AE" stroke-width="0.6" stroke-opacity="0.4" />
      <circle cx="32" cy="32" r="3" fill="#88C43E" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-chili': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M42 12C42 12 44 30 36 44C30 54 20 60 14 60C12 60 16 50 24 38C30 26 32 14 32 14Z" fill="#D9281C" stroke="#A81D14" stroke-width="1.5" />
      <path d="M35 18C36 26 32 38 25 48" stroke="#E85A48" stroke-width="1.4" fill="none" stroke-opacity="0.5" />
      <path d="M30 14C32 10 38 10 44 12C42 16 32 16 30 14Z" fill="#4A6B53" />
      <path d="M40 10C42 5 48 3 52 5" stroke="#4A6B53" stroke-width="2.2" stroke-linecap="round" fill="none" />
      </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-bell-pepper': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M16 26C14 42 18 54 26 56C30 56 32 50 32 50C32 50 34 56 38 56C46 54 50 42 48 26C46 16 40 18 32 18C24 18 18 16 16 26Z" fill="#F4BA38" stroke="#D9971D" stroke-width="1.5" />
      <path d="M20 28C19 38 22 47 26 51" stroke="#F9D06B" stroke-width="1.3" fill="none" stroke-opacity="0.6" />
      <path d="M32 18C32 10 34 6 36 4" stroke="#4A6B53" stroke-width="3" stroke-linecap="round" fill="none" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-eggplant': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M24 16C18 24 14 38 16 48C18 56 26 60 36 58C46 56 50 46 48 36C44 20 34 14 24 16Z" fill="#4A1E4A" stroke="#2D122D" stroke-width="1.5" />
      <ellipse cx="24" cy="26" rx="3.5" ry="7" transform="rotate(-20 24 26)" fill="#7A4A7A" fill-opacity="0.5" />
      <path d="M24 16L18 8M24 16C22 10 26 8 30 10C28 14 26 16 24 16Z" fill="#4A6B53" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-mushroom': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M26 34C24 46 20 54 32 54C44 54 40 46 38 34Z" fill="#F3ECE2" stroke="#CFC5B2" stroke-width="1.5" />
      <path d="M29 38C28.3 44 27 49 30 51" stroke="#E5DACB" stroke-width="0.9" fill="none" stroke-opacity="0.6" />
      <path d="M12 36C12 18 22 12 32 12C42 12 52 18 52 36C42 38 22 38 12 36Z" fill="#7A4B29" stroke="#52321A" stroke-width="1.5" />
      <ellipse cx="22" cy="22" rx="3" ry="4" transform="rotate(-20 22 22)" fill="#A87850" fill-opacity="0.5" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-carrot': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="32,58 20,20 44,20" fill="#E86E24" stroke="#C45312" stroke-width="1.5" />
      <line x1="26" y1="26" x2="29" y2="46" stroke="#F08840" stroke-width="1" stroke-opacity="0.6" />
      <line x1="38" y1="26" x2="35" y2="46" stroke="#F08840" stroke-width="1" stroke-opacity="0.6" />
      <path d="M24.5 31L39.5 31M26.5 38L37.5 38M28.5 45L35.5 45" stroke="#C45312" stroke-width="0.75" stroke-opacity="0.5" />
      <path d="M32 20C32 12 26 6 22 4M32 20C32 10 32 4 32 2M32 20C32 12 38 6 42 4" stroke="#4A6B53" stroke-width="2" stroke-linecap="round" fill="none" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0.0 5.0) translate(32 34) scale(0.55) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-broccoli': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="27" y="36" width="10" height="20" rx="4" fill="#9DBA6D" />
      <line x1="31" y1="40" x2="31" y2="52" stroke="#8AA65C" stroke-width="0.9" stroke-opacity="0.6" />
      <circle cx="22" cy="30" r="10" fill="#3D5A45" />
      <circle cx="42" cy="30" r="10" fill="#3D5A45" />
      <circle cx="32" cy="22" r="12" fill="#4A6B53" />
      <circle cx="27" cy="18" r="2.6" fill="#5A8064" fill-opacity="0.7" />
      <circle cx="36" cy="19" r="2.4" fill="#5A8064" fill-opacity="0.7" />
      <circle cx="20" cy="27" r="2.2" fill="#4E6E52" fill-opacity="0.7" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-strawberry': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M32 54C22 48 16 38 16 26C16 18 24 16 32 20C40 16 48 18 48 26C48 38 42 48 32 54Z" fill="#E22E3E" stroke="#B81D2C" stroke-width="1.5" />
      <ellipse cx="24" cy="27" rx="3.2" ry="5.5" transform="rotate(-15 24 27)" fill="#F2564F" fill-opacity="0.6" />
      <path d="M32 20L26 12M32 20L38 12M32 20L32 10" stroke="#4A6B53" stroke-width="2" stroke-linecap="round" fill="none" />
      <circle cx="26" cy="30" r="1.2" fill="#FEF8EB" />
      <circle cx="38" cy="30" r="1.2" fill="#FEF8EB" />
      <circle cx="32" cy="38" r="1.2" fill="#FEF8EB" />
      <circle cx="30" cy="24" r="1" fill="#FEF8EB" />
      <circle cx="35" cy="42" r="1" fill="#FEF8EB" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-apple': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M32 52C22 52 14 42 14 30C14 18 22 16 32 20C42 16 50 18 50 30C50 42 42 52 32 52Z" fill="#D9281C" stroke="#A8180E" stroke-width="1.5" />
      <ellipse cx="22" cy="28" rx="3.5" ry="6.5" transform="rotate(-15 22 28)" fill="#EA4D40" fill-opacity="0.6" />
      <path d="M32 20C32 10 36 6 36 4" stroke="#8C5C1A" stroke-width="2.5" stroke-linecap="round" fill="none" />
      <ellipse cx="38" cy="12" rx="5" ry="3" transform="rotate(-30 38 12)" fill="#4A6B53" />
    </g>
  
    <g aria-hidden="true" pointer-events="none" transform="translate(0 0) translate(32 34) scale(1) translate(-32 -34)">
      <ellipse cx="23.2" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="40.8" cy="38.1" rx="3.2" ry="1.35" fill="#F48792" fill-opacity="0.42" />
      <ellipse cx="27.3" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="36.7" cy="34.1" rx="1.55" ry="2.15" fill="#4B302C" />
      <ellipse cx="26.8" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <ellipse cx="36.2" cy="33.35" rx="0.48" ry="0.72" fill="#FFFFFF" fill-opacity="0.92" />
      <path d="M29.7 38.1Q32 40.35 34.3 38.1" stroke="#4B302C" stroke-width="1.15" stroke-linecap="round" fill="none" />
    </g>
    
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-banana': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M12 47C20 55 41 52 51 20C46 23 42 26 37 29C30 35 22 40 12 47Z" fill="#E8B936" stroke="#976E1F" stroke-width="1.2" />
      <path d="M14 45C24 50 40 43 48 22C40 31 29 39 14 45Z" fill="#F7D75A" />
      <path d="M17 46C27 47 40 39 46 25" stroke="#FFF1A3" stroke-width="1.6" stroke-linecap="round" fill="none" stroke-opacity="0.88" />
      <path d="M20 49C27 50 34 47 39 43" stroke="#D49A25" stroke-width="1" stroke-linecap="round" fill="none" />
      <path d="M49 21L53 16" stroke="#5F4725" stroke-width="3" stroke-linecap="round" /><circle cx="53" cy="16" r="2" fill="#563B22" />
      <path d="M12 47L10 49" stroke="#5F4725" stroke-width="3" stroke-linecap="round" /><circle cx="10" cy="49" r="1.8" fill="#563B22" />
      <ellipse cx="41" cy="31" rx="1.7" ry="0.8" transform="rotate(-35 41 31)" fill="#C98B24" fill-opacity="0.65" />
      
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-beer-mug': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M19 20H45V49C45 53 41 56 32 56C23 56 19 53 19 49V20Z" fill="#D58B22" stroke="#855018" stroke-width="1.25" />
      <path d="M22 23H42V48C42 51 38 53 32 53C26 53 22 51 22 48V23Z" fill="#EFB53A" />
      <path d="M45 27H51C55 27 55 45 51 45H45" stroke="#9D6727" stroke-width="6" fill="none" stroke-linecap="round" />
      <path d="M45 29H50C52 29 52 43 50 43H45" stroke="#F4D696" stroke-width="2.1" fill="none" stroke-linecap="round" />
      <path d="M25 26V48M31 24V52M38 26V49" stroke="#C27A1E" stroke-width="1" stroke-opacity="0.55" />
      <path d="M18 21C18 16 22 14 26 16C27 11 34 10 37 15C42 12 47 16 46 21C39 24 25 24 18 21Z" fill="#FFFDF6" stroke="#DDD6C9" stroke-width="0.8" />
      <circle cx="23" cy="18" r="3.5" fill="#FFFDF6" /><circle cx="31" cy="15" r="4.5" fill="#FFFDF6" /><circle cx="40" cy="18" r="3.5" fill="#FFFDF6" />
      <path d="M24 30C23 36 23 43 25 47" stroke="#FFF0B2" stroke-width="1.25" stroke-linecap="round" fill="none" fill-opacity="0.72" />
      <circle cx="37" cy="31" r="1.1" fill="#FFF4C9" fill-opacity="0.82" /><circle cx="34" cy="41" r="0.9" fill="#FFF4C9" fill-opacity="0.72" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-coffee-cup': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="50" rx="20" ry="5" fill="#DFD5C4" />
      <path d="M18 28H46V40C46 46 40 48 32 48C24 48 18 46 18 40V28Z" fill="#FAF7F2" stroke="#1E1A18" stroke-width="1.5" />
      <path d="M46 30C52 30 52 38 46 38" stroke="#1E1A18" stroke-width="2" fill="none" stroke-linecap="round" />
      <ellipse cx="32" cy="28" rx="14" ry="4" fill="#6F4827" />
      <ellipse cx="27" cy="27" rx="4" ry="1.4" fill="#8C5C33" fill-opacity="0.6" />
      <path d="M26 20Q28 14 26 8M32 18Q34 12 32 6M38 20Q40 14 38 8" stroke="#8C7355" stroke-width="1.5" stroke-linecap="round" fill="none" stroke-opacity="0.7" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-iced-coffee': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <polygon points="18,18 46,18 42,54 22,54" fill="#6F4827" stroke="#E8ECEB" stroke-width="1.5" />
      <rect x="16" y="14" width="32" height="4" rx="2" fill="#E8ECEB" />
      <line x1="38" y1="6" x2="30" y2="40" stroke="#68A348" stroke-width="3" stroke-linecap="round" />
      <rect x="24" y="26" width="6" height="6" fill="#FFF" fill-opacity="0.6" rx="1" />
      <rect x="32" y="34" width="6" height="6" fill="#FFF" fill-opacity="0.6" rx="1" />
      <rect x="27" y="42" width="5" height="5" fill="#FFF" fill-opacity="0.45" rx="1" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-boba': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <path
        d="M17 18L21 54C21 57 24 59 28 59H36C40 59 43 57 43 54L47 18H17Z"
        fill="#D4A373"
        stroke="#E2E8F0"
        stroke-width="1.5"
      />
      
      <path d="M17 18L18.5 30Q32 34 45.5 30L47 18H17Z" fill="#FFFDF8" fill-opacity="0.85" />
      
      <path d="M19 32C24 38 22 46 25 50" stroke="#FFF" stroke-width="2.5" stroke-linecap="round" stroke-opacity="0.45" fill="none" />

      
      <circle cx="25" cy="53" r="3.6" fill="#1E293B" />
      <circle cx="24.2" cy="52.2" r="1.1" fill="#FFFFFF" fill-opacity="0.75" />

      <circle cx="32" cy="54" r="3.6" fill="#1E293B" />
      <circle cx="31.2" cy="53.2" r="1.1" fill="#FFFFFF" fill-opacity="0.75" />

      <circle cx="39" cy="53" r="3.6" fill="#1E293B" />
      <circle cx="38.2" cy="52.2" r="1.1" fill="#FFFFFF" fill-opacity="0.75" />

      <circle cx="28" cy="47" r="3.6" fill="#1E293B" />
      <circle cx="27.2" cy="46.2" r="1.1" fill="#FFFFFF" fill-opacity="0.75" />

      <circle cx="36" cy="48" r="3.6" fill="#1E293B" />
      <circle cx="35.2" cy="47.2" r="1.1" fill="#FFFFFF" fill-opacity="0.75" />

      <circle cx="23" cy="42" r="3.2" fill="#1E293B" />
      <circle cx="22.4" cy="41.4" r="0.9" fill="#FFFFFF" fill-opacity="0.75" />

      <circle cx="32" cy="41" r="3.2" fill="#1E293B" />
      <circle cx="31.4" cy="40.4" r="0.9" fill="#FFFFFF" fill-opacity="0.75" />

      
      <line x1="36" y1="5" x2="28" y2="52" stroke="#E11D48" stroke-width="4.5" stroke-linecap="round" />
      <line x1="36" y1="5" x2="28" y2="52" stroke="#FDA4AF" stroke-width="1.5" stroke-linecap="round" />

      
      <ellipse cx="32" cy="18" rx="16" ry="3.5" fill="#E2E8F0" stroke="#CBD5E1" stroke-width="1" />
      <path d="M20 18C20 12 24 9 32 9C40 9 44 12 44 18" stroke="#E2E8F0" stroke-width="2.5" fill="#F8FAFC" fill-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-wine-glass': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path d="M20 16H44V28C44 38 34 42 32 42C30 42 20 38 20 28V16Z" fill="#FFFDF9" stroke="#8C2D3A" stroke-width="1.5" />
      <path d="M22 24H42V28C42 36 34 40 32 40C30 40 22 36 22 28V24Z" fill="#8C2D3A" />
      <ellipse cx="27" cy="27" rx="2.2" ry="4.5" fill="#A8465A" fill-opacity="0.6" />
      <line x1="32" y1="42" x2="32" y2="56" stroke="#8C2D3A" stroke-width="2" />
      <ellipse cx="32" cy="56" rx="12" ry="3" fill="#8C2D3A" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-wine-bottle': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <path
        d="M21 30C21 27 22.5 25.5 28 24.5V12C28 10.5 29 9 31 9H33C35 9 36 10.5 36 12V24.5C41.5 25.5 43 27 43 30V54C43 56.5 41 58 38.5 58H25.5C23 58 21 56.5 21 54V30Z"
        fill="#3D1A24"
        stroke="#2A1119"
        stroke-width="1"
      />
      <rect x="27" y="10" width="10" height="7" rx="1.5" fill="#8C2D3A" />
      <rect x="27" y="15" width="10" height="1.6" fill="#6E1F2A" opacity="0.6" />
      <rect x="29.5" y="6" width="5" height="5" rx="1" fill="#D9B382" />
      <rect x="24" y="34" width="16" height="19" fill="#FFFDF8" rx="1.5" />
      <rect x="26" y="38" width="12" height="1.6" fill="#C9A86A" opacity="0.7" />
      <rect x="26" y="42" width="9" height="1.2" fill="#DDD0B0" opacity="0.6" />
      <rect x="26" y="45" width="10" height="1.2" fill="#DDD0B0" opacity="0.6" />
      <path d="M24.5 29C24 36 24 48 24.5 55" stroke="#5A2A38" stroke-width="1.8" stroke-linecap="round" opacity="0.5" fill="none" />
      <path d="M23 27C22.7 34 22.7 47 23 56" stroke="#6E3644" stroke-width="1" stroke-linecap="round" opacity="0.35" fill="none" />
      <ellipse cx="32" cy="57" rx="10.5" ry="1.6" fill="#1E0B10" opacity="0.4" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-teapot': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <ellipse cx="32" cy="38" rx="18" ry="14" fill="#4A6B53" stroke="#3D5A45" stroke-width="1.5" />
      <path d="M18 32C20 28 44 28 46 32" stroke="#5A8064" stroke-width="1.2" fill="none" stroke-opacity="0.6" />
      <rect x="26" y="20" width="12" height="6" rx="2" fill="#3D5A45" />
      <circle cx="32" cy="18" r="2.5" fill="#D9822B" />
      <path d="M16 34C8 30 8 44 16 42" stroke="#3D5A45" stroke-width="3" fill="none" stroke-linecap="round" />
      <path d="M48 32C56 30 58 24 58 20" stroke="#3D5A45" stroke-width="3" fill="none" stroke-linecap="round" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-milk-carton': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <rect x="20" y="22" width="24" height="34" rx="2" fill="#2E4A7A" />
      <polygon points="20,22 44,22 38,10 26,10" fill="#FFFDF8" stroke="#2E4A7A" stroke-width="1.5" />
      <circle cx="32" cy="36" r="6" fill="#FFFDF8" />
      <line x1="23" y1="26" x2="23" y2="52" stroke="#24406A" stroke-width="0.9" stroke-opacity="0.6" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-coconut-drink': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      <circle cx="32" cy="36" r="20" fill="#6F4827" />
      <ellipse cx="27" cy="30" rx="5" ry="8" transform="rotate(-20 27 30)" fill="#845A34" fill-opacity="0.6" />
      <ellipse cx="32" cy="22" rx="14" ry="6" fill="#FFFDF8" />
      <line x1="38" y1="10" x2="30" y2="28" stroke="#E22E3E" stroke-width="3" stroke-linecap="round" />
      <circle cx="44" cy="22" r="4" fill="#F8B4C0" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-whisk': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <path d="M14 50L27 37" stroke="#8C7355" stroke-width="6.5" stroke-linecap="round" fill="none" />
      <path d="M14 50L27 37" stroke="#B09A7C" stroke-width="2.2" stroke-linecap="round" opacity="0.5" fill="none" />
      
      
      <rect x="10" y="46.75" width="8" height="6.5" rx="3" transform="rotate(-45, 14, 50)" fill="#6B5A42" />
      
      
      <ellipse cx="40" cy="24" rx="12.5" ry="8.5" transform="rotate(-45, 40, 24)" stroke="#9C9186" stroke-width="1.6" fill="none" opacity="0.55" />
      <ellipse cx="40" cy="24" rx="10.5" ry="6" transform="rotate(-45, 40, 24)" stroke="#9C9186" stroke-width="1.4" fill="none" opacity="0.5" />
      <ellipse cx="40" cy="24" rx="13" ry="9" transform="rotate(-45, 40, 24)" stroke="#4A4038" stroke-width="2.1" fill="none" />
      <ellipse cx="40" cy="24" rx="10.8" ry="6.4" transform="rotate(-45, 40, 24)" stroke="#4A4038" stroke-width="1.8" fill="none" />
      <ellipse cx="40" cy="24" rx="8.4" ry="4" transform="rotate(-45, 40, 24)" stroke="#6B625B" stroke-width="1.4" fill="none" opacity="0.7" />
      
      
      <line x1="27" y1="24" x2="53" y2="24" transform="rotate(-45, 40, 24)" stroke="#4A4038" stroke-width="1.8" stroke-linecap="round" fill="none" />
      
      
      <path d="M32 18C34 20 36 22 38 24" stroke="#FFFFFF" stroke-width="1" stroke-linecap="round" opacity="0.4" fill="none" />
      
      
      <ellipse cx="29" cy="35" rx="4.5" ry="3" transform="rotate(-45, 29, 35)" fill="#4A4038" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
  'food-chef-knife': r'''<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g>
      
      <g transform="translate(25, 39) rotate(-45)">
        
        <rect x="-26" y="-4.75" width="20" height="9.5" rx="4.5" fill="#3D2A18" />
        <rect x="-26" y="-4.75" width="20" height="9.5" rx="4.5" fill="#5A3E22" opacity="0.45" />
        
        
        <line x1="-19" y1="-2.5" x2="-19" y2="2.5" stroke="#241A0E" stroke-width="1.1" stroke-linecap="round" opacity="0.6" />
        <line x1="-14" y1="-2.5" x2="-14" y2="2.5" stroke="#241A0E" stroke-width="1.1" stroke-linecap="round" opacity="0.6" />
        
        
        <rect x="-8" y="-3.5" width="8" height="7" rx="1.5" fill="#8C8378" />
      </g>
      
      
      <path d="M22 36L48 10C54 20 42 36 28 42L22 36Z" fill="#E4DED4" stroke="#5F5951" stroke-width="1.3" />
      
      
      <path d="M24 32L46 10" stroke="#FFFFFF" stroke-width="1.6" stroke-linecap="round" opacity="0.65" fill="none" />
      <path d="M25 37L45 17" stroke="#A39C90" stroke-width="1.1" stroke-linecap="round" opacity="0.55" fill="none" />
      <path d="M27 33L41 19" stroke="#F2ECE4" stroke-width="2.2" stroke-linecap="round" opacity="0.5" fill="none" />
    </g>
  
  
    <g aria-hidden="true" pointer-events="none" fill="#FFFDF8">
      <path d="M10.5 14L11.45 16.55L14 17.5L11.45 18.45L10.5 21L9.55 18.45L7 17.5L9.55 16.55L10.5 14Z" fill-opacity="0.88" />
      <path d="M53.5 8L54.2 9.8L56 10.5L54.2 11.2L53.5 13L52.8 11.2L51 10.5L52.8 9.8L53.5 8Z" fill-opacity="0.78" />
      <circle cx="55" cy="19" r="1" fill-opacity="0.7" />
    </g>

</svg>''',
};
