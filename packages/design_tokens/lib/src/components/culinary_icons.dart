import 'package:flutter/material.dart';

class CulinaryIconItem {
  final String key;
  final String label;
  final String category;
  final IconData icon;

  const CulinaryIconItem({
    required this.key,
    required this.label,
    required this.category,
    required this.icon,
  });
}

final List<CulinaryIconItem> culinaryIconsCatalog = [
  // 1. Produce & Garden
  const CulinaryIconItem(key: 'apple', label: 'Apple / Crisp Fruit', category: 'Produce & Garden', icon: Icons.apple),
  const CulinaryIconItem(key: 'banana', label: 'Fresh Banana', category: 'Produce & Garden', icon: Icons.energy_savings_leaf),
  const CulinaryIconItem(key: 'carrot', label: 'Carrot / Root Veg', category: 'Produce & Garden', icon: Icons.grass),
  const CulinaryIconItem(key: 'cherry', label: 'Cherry / Fresh Berries', category: 'Produce & Garden', icon: Icons.grain),
  const CulinaryIconItem(key: 'citrus', label: 'Lemon / Citrus', category: 'Produce & Garden', icon: Icons.wb_sunny_outlined),
  const CulinaryIconItem(key: 'lemon', label: 'Meyer Lemon', category: 'Produce & Garden', icon: Icons.wb_sunny),
  const CulinaryIconItem(key: 'grape', label: 'Grapes / Vineyard', category: 'Produce & Garden', icon: Icons.bubble_chart),
  const CulinaryIconItem(key: 'leaf', label: 'Basil / Fresh Herbs', category: 'Produce & Garden', icon: Icons.eco),
  const CulinaryIconItem(key: 'basil', label: 'Sweet Basil', category: 'Produce & Garden', icon: Icons.eco),
  const CulinaryIconItem(key: 'salad', label: 'Salad / Microgreens', category: 'Produce & Garden', icon: Icons.grass),
  const CulinaryIconItem(key: 'bean', label: 'Beans / Legumes', category: 'Produce & Garden', icon: Icons.circle),
  const CulinaryIconItem(key: 'nut', label: 'Nuts / Walnuts', category: 'Produce & Garden', icon: Icons.spa),
  const CulinaryIconItem(key: 'hop', label: 'Hops / Seasoning', category: 'Produce & Garden', icon: Icons.yard),
  const CulinaryIconItem(key: 'sprout', label: 'Sprouts / Micro-herbs', category: 'Produce & Garden', icon: Icons.spa),
  const CulinaryIconItem(key: 'garlic', label: 'Garlic Cloves', category: 'Produce & Garden', icon: Icons.spa),
  const CulinaryIconItem(key: 'avocado', label: 'Hass Avocado', category: 'Produce & Garden', icon: Icons.radio_button_checked),
  const CulinaryIconItem(key: 'mushroom', label: 'Wild Mushroom', category: 'Produce & Garden', icon: Icons.nature),
  const CulinaryIconItem(key: 'tomato', label: 'San Marzano Tomato', category: 'Produce & Garden', icon: Icons.circle_notifications),
  const CulinaryIconItem(key: 'chili', label: 'Chili Pepper', category: 'Produce & Garden', icon: Icons.local_fire_department),
  const CulinaryIconItem(key: 'flower', label: 'Edible Botanical Flower', category: 'Produce & Garden', icon: Icons.local_florist),
  const CulinaryIconItem(key: 'flower2', label: 'Chamomile / Elderflower', category: 'Produce & Garden', icon: Icons.filter_vintage),
  const CulinaryIconItem(key: 'clover', label: 'Fresh Clover Garnish', category: 'Produce & Garden', icon: Icons.eco),

  // 2. Bakery & Grains
  const CulinaryIconItem(key: 'wheat', label: 'Wheat / Type 00 Flour', category: 'Bakery & Grains', icon: Icons.grain),
  const CulinaryIconItem(key: 'flour', label: 'Artisan Flour Sack', category: 'Bakery & Grains', icon: Icons.inventory_2),
  const CulinaryIconItem(key: 'bread', label: 'Artisan Sourdough Loaf', category: 'Bakery & Grains', icon: Icons.bakery_dining),
  const CulinaryIconItem(key: 'croissant', label: 'Butter Croissant', category: 'Bakery & Grains', icon: Icons.breakfast_dining),
  const CulinaryIconItem(key: 'sandwich', label: 'Sandwich / Panini', category: 'Bakery & Grains', icon: Icons.lunch_dining),
  const CulinaryIconItem(key: 'pizza', label: 'Pizza / Focaccia', category: 'Bakery & Grains', icon: Icons.local_pizza),
  const CulinaryIconItem(key: 'cookie', label: 'Artisan Cookie', category: 'Bakery & Grains', icon: Icons.cookie),
  const CulinaryIconItem(key: 'donut', label: 'Glazed Donut / Bagel', category: 'Bakery & Grains', icon: Icons.donut_large),
  const CulinaryIconItem(key: 'cake', label: 'Celebration Cake', category: 'Bakery & Grains', icon: Icons.cake),
  const CulinaryIconItem(key: 'cake-slice', label: 'Cake Slice / Tart', category: 'Bakery & Grains', icon: Icons.cake),
  const CulinaryIconItem(key: 'dessert', label: 'Flan / Pudding', category: 'Bakery & Grains', icon: Icons.icecream),
  const CulinaryIconItem(key: 'layers', label: 'Pastry Layers / Laminate', category: 'Bakery & Grains', icon: Icons.layers),
  const CulinaryIconItem(key: 'sourdough-starter', label: 'Wild Sourdough Starter', category: 'Bakery & Grains', icon: Icons.science),
  const CulinaryIconItem(key: 'butter', label: 'Cultured Butter', category: 'Bakery & Grains', icon: Icons.view_agenda),
  const CulinaryIconItem(key: 'honey', label: 'Wildflower Honey', category: 'Bakery & Grains', icon: Icons.hive),

  // 3. Proteins, Butcher & Seafood
  const CulinaryIconItem(key: 'egg', label: 'Farm Fresh Egg', category: 'Proteins & Seafood', icon: Icons.egg),
  const CulinaryIconItem(key: 'egg-fried', label: 'Sunny Side Egg', category: 'Proteins & Seafood', icon: Icons.egg_alt),
  const CulinaryIconItem(key: 'beef', label: 'Prime Beef / Steak', category: 'Proteins & Seafood', icon: Icons.kebab_dining),
  const CulinaryIconItem(key: 'ham', label: 'Prosciutto / Cured Ham', category: 'Proteins & Seafood', icon: Icons.set_meal),
  const CulinaryIconItem(key: 'drumstick', label: 'Roast Poultry / Chicken', category: 'Proteins & Seafood', icon: Icons.dinner_dining),
  const CulinaryIconItem(key: 'fish', label: 'Fresh Catch Fish', category: 'Proteins & Seafood', icon: Icons.phishing),
  const CulinaryIconItem(key: 'fish-symbol', label: 'Seared Fish Fillet', category: 'Proteins & Seafood', icon: Icons.set_meal),
  const CulinaryIconItem(key: 'shrimp', label: 'Shrimp / Prawns', category: 'Proteins & Seafood', icon: Icons.water),
  const CulinaryIconItem(key: 'soup', label: 'Bone Broth / Dashi', category: 'Proteins & Seafood', icon: Icons.soup_kitchen),
  const CulinaryIconItem(key: 'anchor', label: 'Deep Sea Catch', category: 'Proteins & Seafood', icon: Icons.anchor),

  // 4. Sweets & Treats
  const CulinaryIconItem(key: 'ice-cream', label: 'Gelato Cone', category: 'Sweets & Treats', icon: Icons.icecream),
  const CulinaryIconItem(key: 'ice-cream-bowl', label: 'Sundae Ice Cream', category: 'Sweets & Treats', icon: Icons.rice_bowl),
  const CulinaryIconItem(key: 'popsicle', label: 'Fruit Popsicle', category: 'Sweets & Treats', icon: Icons.icecream_outlined),
  const CulinaryIconItem(key: 'candy', label: 'Caramel Candy', category: 'Sweets & Treats', icon: Icons.favorite_border),
  const CulinaryIconItem(key: 'candy-cane', label: 'Peppermint Cane', category: 'Sweets & Treats', icon: Icons.celebration),
  const CulinaryIconItem(key: 'lollipop', label: 'Lollipop Confection', category: 'Sweets & Treats', icon: Icons.adjust),
  const CulinaryIconItem(key: 'popcorn', label: 'Sweet & Salty Popcorn', category: 'Sweets & Treats', icon: Icons.fastfood),
  const CulinaryIconItem(key: 'gift', label: 'Artisan Food Hamper', category: 'Sweets & Treats', icon: Icons.card_giftcard),
  const CulinaryIconItem(key: 'heart', label: 'Comfort Food Love', category: 'Sweets & Treats', icon: Icons.favorite),

  // 5. Drinks & Beverages
  const CulinaryIconItem(key: 'coffee', label: 'Espresso / Roast Coffee', category: 'Drinks & Beverages', icon: Icons.coffee),
  const CulinaryIconItem(key: 'milk', label: 'Fresh Milk / Cream', category: 'Drinks & Beverages', icon: Icons.water_drop),
  const CulinaryIconItem(key: 'glass-water', label: 'Mineral Water', category: 'Drinks & Beverages', icon: Icons.local_drink),
  const CulinaryIconItem(key: 'cup-soda', label: 'Iced Soda / Tonic', category: 'Drinks & Beverages', icon: Icons.local_bar),
  const CulinaryIconItem(key: 'wine', label: 'Reserve Wine', category: 'Drinks & Beverages', icon: Icons.wine_bar),
  const CulinaryIconItem(key: 'beer', label: 'Craft Beer', category: 'Drinks & Beverages', icon: Icons.sports_bar),
  const CulinaryIconItem(key: 'martini', label: 'Aperitif / Cocktail', category: 'Drinks & Beverages', icon: Icons.liquor),
  const CulinaryIconItem(key: 'droplets', label: 'Olive Oil / Infusion', category: 'Drinks & Beverages', icon: Icons.opacity),
  const CulinaryIconItem(key: 'waves', label: 'Sea Brine / Saltwater', category: 'Drinks & Beverages', icon: Icons.waves),

  // 6. Cookware & Kitchen Tools
  const CulinaryIconItem(key: 'chef', label: 'Master Chef Hat', category: 'Cookware & Prep', icon: Icons.restaurant_menu),
  const CulinaryIconItem(key: 'chef-hat', label: 'Chef Toque', category: 'Cookware & Prep', icon: Icons.emoji_events),
  const CulinaryIconItem(key: 'cooking-pot', label: 'Dutch Oven / Stew Pot', category: 'Cookware & Prep', icon: Icons.soup_kitchen),
  const CulinaryIconItem(key: 'utensils', label: 'Fork & Knife Plating', category: 'Cookware & Prep', icon: Icons.restaurant),
  const CulinaryIconItem(key: 'utensils-crossed', label: 'Crossed Cutlery', category: 'Cookware & Prep', icon: Icons.dining),
  const CulinaryIconItem(key: 'knife', label: 'Chef Knife / Shears', category: 'Cookware & Prep', icon: Icons.content_cut),
  const CulinaryIconItem(key: 'chef-knife', label: 'Prep Knife', category: 'Cookware & Prep', icon: Icons.content_cut),
  const CulinaryIconItem(key: 'flame', label: 'High Sear / Flame', category: 'Cookware & Prep', icon: Icons.local_fire_department),
  const CulinaryIconItem(key: 'scale', label: 'Precision Scale', category: 'Cookware & Prep', icon: Icons.scale),
  const CulinaryIconItem(key: 'timer', label: 'Kitchen Timer', category: 'Cookware & Prep', icon: Icons.timer),
  const CulinaryIconItem(key: 'clock', label: 'Slow Cooking Clock', category: 'Cookware & Prep', icon: Icons.access_time),
  const CulinaryIconItem(key: 'shopping-bag', label: 'Market Shopping Bag', category: 'Cookware & Prep', icon: Icons.shopping_bag),
  const CulinaryIconItem(key: 'shopping-cart', label: 'Grocery Cart', category: 'Cookware & Prep', icon: Icons.shopping_cart),
  const CulinaryIconItem(key: 'camera', label: 'Polaroid Camera', category: 'Cookware & Prep', icon: Icons.camera_alt),
  const CulinaryIconItem(key: 'circle-dot', label: 'Induction Burner / Pan', category: 'Cookware & Prep', icon: Icons.album),
  const CulinaryIconItem(key: 'rotate-cw', label: 'Whisk & Stir', category: 'Cookware & Prep', icon: Icons.sync),
  const CulinaryIconItem(key: 'sea-salt', label: 'Flaky Sea Salt', category: 'Cookware & Prep', icon: Icons.grain),

  // 7. Chef Standards & Badges
  const CulinaryIconItem(key: 'award', label: 'Michelin / Award', category: 'Quality Badges', icon: Icons.military_tech),
  const CulinaryIconItem(key: 'trophy', label: 'Grand Champion Recipe', category: 'Quality Badges', icon: Icons.emoji_events),
  const CulinaryIconItem(key: 'crown', label: 'Signature Crown Dish', category: 'Quality Badges', icon: Icons.workspace_premium),
  const CulinaryIconItem(key: 'medal', label: 'Gold Standard Technique', category: 'Quality Badges', icon: Icons.stars),
  const CulinaryIconItem(key: 'shield-check', label: 'Organic & Farm Certified', category: 'Quality Badges', icon: Icons.verified_user),
  const CulinaryIconItem(key: 'badge-check', label: 'Verified Tested', category: 'Quality Badges', icon: Icons.verified),
  const CulinaryIconItem(key: 'lightbulb', label: 'Master Technique Tip', category: 'Quality Badges', icon: Icons.lightbulb_outline),
  const CulinaryIconItem(key: 'pen-tool', label: 'Chef Tasting Notes', category: 'Quality Badges', icon: Icons.edit_note),
  const CulinaryIconItem(key: 'bookmark', label: 'Family Secret Recipe', category: 'Quality Badges', icon: Icons.bookmark),
  const CulinaryIconItem(key: 'book-open', label: 'Open Recipe Keepsake', category: 'Quality Badges', icon: Icons.menu_book),
  const CulinaryIconItem(key: 'compass', label: 'Regional Origin', category: 'Quality Badges', icon: Icons.explore),
  const CulinaryIconItem(key: 'store', label: 'Local Farmer Market', category: 'Quality Badges', icon: Icons.storefront),
  const CulinaryIconItem(key: 'truck', label: 'Farm-to-Table Fresh', category: 'Quality Badges', icon: Icons.local_shipping),
  const CulinaryIconItem(key: 'smile', label: 'Pure Comfort Food', category: 'Quality Badges', icon: Icons.sentiment_satisfied_alt),
  const CulinaryIconItem(key: 'chefs-signature', label: "Chef's Signature", category: 'Quality Badges', icon: Icons.auto_awesome),
  const CulinaryIconItem(key: 'al-dente', label: 'Al Dente', category: 'Quality Badges', icon: Icons.restaurant),
  const CulinaryIconItem(key: 'slow-simmered', label: 'Slow Simmered', category: 'Quality Badges', icon: Icons.whatshot),
  const CulinaryIconItem(key: 'wild-ferment', label: 'Wild Ferment', category: 'Quality Badges', icon: Icons.grain),
  const CulinaryIconItem(key: 'artisanal-craft', label: 'Artisanal Craft', category: 'Quality Badges', icon: Icons.auto_awesome),
  const CulinaryIconItem(key: 'master-technique', label: 'Master Technique', category: 'Quality Badges', icon: Icons.military_tech),
];

IconData getCulinaryIconData(String? key) {
  if (key == null || key.isEmpty) return Icons.restaurant;
  final norm = key.toLowerCase().trim();
  final match = culinaryIconsCatalog.firstWhere(
    (item) => item.key.toLowerCase() == norm || item.label.toLowerCase().contains(norm) || norm.contains(item.key),
    orElse: () => const CulinaryIconItem(key: 'default', label: '', category: '', icon: Icons.restaurant),
  );
  return match.icon;
}
