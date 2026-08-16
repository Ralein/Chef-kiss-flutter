import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';
import '../../../app/audio_chime_service.dart';
import '../../../app/chef_toast_service.dart';

class AIRecipeStudioModal extends ConsumerStatefulWidget {
  const AIRecipeStudioModal({super.key});

  @override
  ConsumerState<AIRecipeStudioModal> createState() => _AIRecipeStudioModalState();
}

class _AIRecipeStudioModalState extends ConsumerState<AIRecipeStudioModal> {
  final TextEditingController _promptController = TextEditingController();
  ScrapbookTheme _selectedTheme = ScrapbookTheme.terracottaClassic;
  bool _isGenerating = false;

  // Sous Chef Pass & BYO API session state
  static const int _passMinutesLeft = 28;

  final List<Map<String, dynamic>> _inspirations = [
    {
      'title': 'Artisanal Fettuccine al Pomodoro',
      'tag': 'Handmade Pasta',
      'prompt': 'Handmade fresh egg fettuccine tossed with sweet San Marzano tomato sauce, garlic, extra virgin olive oil, and fresh basil.',
      'theme': ScrapbookTheme.terracottaClassic,
      'cover': 'assets/illustrations/sketchbook_pasta.jpg',
    },
    {
      'title': 'French Crêpes Suzette with Berries',
      'tag': 'Sweet Pastry',
      'prompt': 'Delicate French crêpes with caramelized citrus-butter glaze, pure honey, and fresh wild berries.',
      'theme': ScrapbookTheme.artisanKraft,
      'cover': 'assets/illustrations/sketchbook_crepes.jpg',
    },
    {
      'title': 'Country Artisan Sourdough Boule',
      'tag': 'Wild Ferment',
      'prompt': 'High-hydration wild sourdough boule with open custardy crumb, blistering ear, and cultured honey butter.',
      'theme': ScrapbookTheme.artisanKraft,
      'cover': 'assets/illustrations/sketchbook_sourdough.jpg',
    },
    {
      'title': 'Tokyo Shoyu Ramen with Jammy Egg',
      'tag': 'Craft Ramen',
      'prompt': 'Rich chicken-dashi broth served over springy hand-pulled noodles, soft-boiled marinated egg, nori crisp, and sesame oil.',
      'theme': ScrapbookTheme.matchaSage,
      'cover': 'assets/illustrations/sketchbook_ramen.jpg',
    },
    {
      'title': 'Golden Brioche Avocado Toast',
      'tag': 'Brunch Green',
      'prompt': 'Toasted buttery brioche loaded with lemon-mashed avocado, heirloom cherry tomatoes, and jammy 6-minute egg.',
      'theme': ScrapbookTheme.matchaSage,
      'cover': 'assets/illustrations/sketchbook_salad.jpg',
    },
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _handleGenerate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    audioChime.playTap();
    setState(() => _isGenerating = true);

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final promptLower = prompt.toLowerCase();

    var title = 'Artisanal Culinary Dish';
    var summary = 'A curated culinary creation documented in your recipe keepsake.';
    var cover = 'assets/illustrations/sketchbook_pasta.jpg';
    var moodStamps = ['Artisanal Craft', "Chef's Signature"];
    var theme = _selectedTheme;
    var totalMinutes = 30;
    var difficulty = RecipeDifficulty.medium;

    var ingredients = [
      RecipeIngredient(id: 'ing-$now-1', recipeId: 'new', displayName: 'Key Ingredient', quantity: Rational(250, 1), unitCode: 'g', position: 1, icon: 'grain', iconColor: '#8C7355'),
      RecipeIngredient(id: 'ing-$now-2', recipeId: 'new', displayName: 'Extra Virgin Olive Oil', quantity: Rational(2, 1), unitCode: 'tbsp', position: 2, icon: 'droplets', iconColor: '#4A6B53'),
      RecipeIngredient(id: 'ing-$now-3', recipeId: 'new', displayName: 'Fresh Aromatics', quantity: Rational(2, 1), unitCode: 'cloves', position: 3, icon: 'leaf', iconColor: '#4A6B53'),
      RecipeIngredient(id: 'ing-$now-4', recipeId: 'new', displayName: 'Flaky Sea Salt & Pepper', quantity: Rational(1, 1), unitCode: 'to taste', position: 4, icon: 'scale', iconColor: '#8C7355'),
    ];

    var steps = [
      RecipeStep(
        id: 'st-$now-1',
        recipeId: 'new',
        position: 1,
        actionKey: 'Whisk',
        iconKey: 'utensils',
        instructionShort: 'Carefully measure and prepare your ingredients on your cutting board.',
        instructionDetail: 'Proper mise en place ensures seamless workflow and timing.',
        timers: [StepTimer(id: 't-$now-1', recipeStepId: 'st-$now-1', label: 'Prep Time', durationSeconds: 180, position: 1)],
      ),
      RecipeStep(
        id: 'st-$now-2',
        recipeId: 'new',
        position: 2,
        actionKey: 'Simmer',
        iconKey: 'cookingPot',
        instructionShort: 'Cook slowly over medium-low heat until flavors are deeply integrated and glossy.',
        instructionDetail: 'Taste periodically to balance acidity, saltiness, and aromatics.',
        timers: [StepTimer(id: 't-$now-2', recipeStepId: 'st-$now-2', label: 'Cook Timer', durationSeconds: 600, position: 1)],
      ),
      RecipeStep(
        id: 'st-$now-3',
        recipeId: 'new',
        position: 3,
        actionKey: 'Fold',
        iconKey: 'layers',
        instructionShort: 'Plate with care, garnish with fresh herbs, and serve warm immediately.',
        instructionDetail: 'Finish with a light drizzle of cold-pressed olive oil.',
      ),
    ];

    if (promptLower.contains('pasta') || promptLower.contains('pomodoro') || promptLower.contains('fettuccine')) {
      title = 'Handmade Ribbon Fettuccine al Pomodoro';
      summary = 'Fresh rolled ribbon egg fettuccine tossed with sweet San Marzano tomatoes, garlic, extra virgin olive oil, and fragrant basil.';
      cover = 'assets/illustrations/sketchbook_pasta.jpg';
      moodStamps = ['Al Dente', 'Slow Simmered', "Chef's Signature"];
      totalMinutes = 35;
    } else if (promptLower.contains('crêpe') || promptLower.contains('crepe') || promptLower.contains('pancake') || promptLower.contains('sweet')) {
      title = 'French Crêpes Suzette with Sweet Berries';
      summary = 'Delicate French crêpes layered with sweet strawberry compote, whipped vanilla cream, and dusted with powdered sugar.';
      cover = 'assets/illustrations/sketchbook_crepes.jpg';
      moodStamps = ['Pastry Craft', "Chef's Signature", 'Golden Crust'];
      totalMinutes = 25;
      difficulty = RecipeDifficulty.easy;
    } else if (promptLower.contains('sourdough') || promptLower.contains('bread') || promptLower.contains('boule')) {
      title = 'Rustic Country Sourdough Boule';
      summary = 'A golden crackling blistered crust with an airy open crumb, wild yeast fermentation, and rich roasted grain depth.';
      cover = 'assets/illustrations/sketchbook_sourdough.jpg';
      moodStamps = ['Wild Ferment', 'Golden Crust', 'Artisanal Craft'];
      totalMinutes = 180;
      difficulty = RecipeDifficulty.hard;
    } else if (promptLower.contains('ramen') || promptLower.contains('shoyu') || promptLower.contains('soup')) {
      title = 'Tokyo Shoyu Craft Ramen with Jammy Egg';
      summary = 'Silky fragrant chicken-dashi broth served over springy noodles, soft-boiled ajitsuke egg, nori crisp, and toasted sesame oil.';
      cover = 'assets/illustrations/sketchbook_ramen.jpg';
      moodStamps = ['Tokyo Craft', 'Slow Simmered', 'Umami Rich'];
      totalMinutes = 30;
    } else if (promptLower.contains('avocado') || promptLower.contains('brioche') || promptLower.contains('toast')) {
      title = 'Smashed Avocado Brioche & Jammy Egg';
      summary = 'Golden toasted brioche loaded with lemon-mashed avocado, heirloom cherry tomatoes, flaky sea salt, and a 6-minute jammy egg.';
      cover = 'assets/illustrations/sketchbook_salad.jpg';
      moodStamps = ['Garden Fresh', 'Slow Morning', 'Culinary Craft'];
      totalMinutes = 15;
      difficulty = RecipeDifficulty.easy;
    }

    final newRecipe = Recipe(
      id: 'ai-recipe-$now',
      profileId: 'system',
      title: title,
      summary: summary,
      status: RecipeStatus.ready,
      baseServings: Rational(2, 1),
      difficulty: difficulty,
      totalMinutes: totalMinutes,
      isCurated: false,
      origin: Origin.aiProposed,
      isFavorite: true,
      coverImage: cover,
      polaroidCaption: title,
      theme: theme,
      moodStamps: moodStamps,
      chefTip: 'Taste and adjust seasoning frequently at each step of the cook.',
      chefTipIcon: 'chefHat',
      chefTipIconColor: '#C85A32',
      createdAt: now,
      updatedAt: now,
      stickers: [],
      washiTapes: [],
      ingredients: ingredients,
      steps: steps,
    );

    final repo = ref.read(recipeRepositoryProvider);
    await repo.saveRecipe(newRecipe);

    audioChime.playSuccessFanfare();
    if (!mounted) return;
    Navigator.of(context).pop();

    ChefToastService.show(
      context: context,
      title: 'Illustrated Recipe Generated!',
      description: newRecipe.title,
      type: ChefToastType.success,
    );

    context.push('/recipe/${newRecipe.id}');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset + 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1A18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF5C534D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFFC85A32), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'AI SOUS CHEF STUDIO',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          // Sous Chef Pass Banner
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF283D2F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A6B53)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF8CD4A0)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Sous Chef Pass Active: $_passMinutesLeft min remaining • Direct BYO API',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE2F5E8)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6B53),
                    borderRadius: BorderRadius.circular(ChefRadius.pill),
                  ),
                  child: const Text(
                    'UNLOCKED',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: ListView(
              children: [
                // Quick Inspiration Chips
                const Text('Chef Inspiration Presets', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE8E0D2))),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _inspirations.length,
                    itemBuilder: (context, idx) {
                      final item = _inspirations[idx];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFFC85A32)),
                          label: Text(item['tag'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E1A18))),
                          backgroundColor: const Color(0xFFFCFAF7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ChefRadius.pill),
                            side: const BorderSide(color: Color(0xFFE8E0D2)),
                          ),
                          onPressed: () {
                            audioChime.playTap();
                            _promptController.text = item['prompt'] as String;
                            setState(() => _selectedTheme = item['theme'] as ScrapbookTheme);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Prompt Input
                const Text('What would you like to cook today?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                TextField(
                  controller: _promptController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                  cursorColor: const Color(0xFFC85A32),
                  decoration: InputDecoration(
                    hintText: 'Describe any recipe, ingredients, or cooking style (e.g. Handmade saffron tagliatelle with braised wild mushrooms)...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B625B)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8E0D2)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Theme Selector
                const Text('Select Keepsake Theme', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE8E0D2))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildThemeChip(ScrapbookTheme.terracottaClassic, 'Terracotta Classic', const Color(0xFFC85A32)),
                    const SizedBox(width: 8),
                    _buildThemeChip(ScrapbookTheme.matchaSage, 'Matcha Sage', const Color(0xFF4A6B53)),
                    const SizedBox(width: 8),
                    _buildThemeChip(ScrapbookTheme.artisanKraft, 'Artisan Kraft', const Color(0xFF8C7355)),
                  ],
                ),
                const SizedBox(height: 24),

                // Generate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC85A32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      _isGenerating ? 'Structuring Illustrated Recipe...' : 'Generate Illustrated Recipe Note',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    onPressed: _isGenerating ? null : _handleGenerate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(ScrapbookTheme theme, String label, Color color) {
    final isSelected = _selectedTheme == theme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          audioChime.playTap();
          setState(() => _selectedTheme = theme);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : const Color(0xFF2C2623),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : const Color(0xFF5C534D),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFFD6CBBF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
