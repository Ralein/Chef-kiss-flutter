import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';
import '../../../app/audio_chime_service.dart';
import '../../../app/chef_toast_service.dart';
import '../../imports/presentation/ai_recipe_studio_modal.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedCategory = 'all';
  String _sortBy = 'default';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openAIStudio() {
    audioChime.playTap();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AIRecipeStudioModal(),
    );
  }

  void _addNewRecipe() async {
    audioChime.playTap();
    final now = DateTime.now().millisecondsSinceEpoch;
    final blankRecipe = Recipe(
      id: 'custom-recipe-$now',
      profileId: 'default',
      title: 'My Illustrated Recipe Note',
      summary: 'Handcrafted recipe note with kitchen measurements, step-by-step instructions, and chef annotations.',
      baseServings: Rational(2, 1),
      difficulty: RecipeDifficulty.easy,
      totalMinutes: 25,
      origin: Origin.manual,
      isFavorite: true,
      isCurated: false,
      coverImage: 'assets/illustrations/sketchbook_pasta.jpg',
      polaroidCaption: 'My Kitchen Note',
      theme: ScrapbookTheme.terracottaClassic,
      moodStamps: ['Artisanal Craft', "Chef's Signature"],
      chefTip: 'Taste and adjust seasoning frequently at each step of the cook.',
      chefTipIcon: 'chefHat',
      chefTipIconColor: '#C85A32',
      createdAt: now,
      updatedAt: now,
      stickers: [],
      washiTapes: [],
      ingredients: [
        RecipeIngredient(
          id: 'ing-1',
          recipeId: 'new',
          displayName: 'Key Ingredient',
          quantity: Rational(200, 1),
          unitCode: 'g',
          position: 1,
          icon: 'grain',
          iconColor: '#8C7355',
        ),
        RecipeIngredient(
          id: 'ing-2',
          recipeId: 'new',
          displayName: 'Extra Virgin Olive Oil',
          quantity: Rational(2, 1),
          unitCode: 'tbsp',
          position: 2,
          icon: 'droplets',
          iconColor: '#4A6B53',
        ),
      ],
      steps: [
        const RecipeStep(
          id: 'st-1',
          recipeId: 'new',
          position: 1,
          actionKey: 'Mise en Place',
          instructionShort: 'Prepare all fresh ingredients on your kitchen cutting board.',
          instructionDetail: 'Measure everything before turning on the heat for smooth, relaxed cooking.',
        ),
        const RecipeStep(
          id: 'st-2',
          recipeId: 'new',
          position: 2,
          actionKey: 'Simmer',
          instructionShort: 'Cook gently over medium-low heat until fragrant and glossy.',
          instructionDetail: 'Stir occasionally and let the flavors meld together harmoniously.',
          timers: [StepTimer(id: 't-1', recipeStepId: 'st-2', label: 'Simmer Timer', durationSeconds: 300, position: 1)],
        ),
      ],
    );

    final repo = ref.read(recipeRepositoryProvider);
    await repo.saveRecipe(blankRecipe);
    if (!mounted) return;

    ChefToastService.show(
      context: context,
      title: 'New Recipe Note Created',
      description: 'Opening visual sketchbook editor...',
      type: ChefToastType.success,
    );

    context.push('/recipe/${blankRecipe.id}');
  }

  void _toggleFavorite(Recipe recipe) async {
    audioChime.playTap();
    final updated = recipe.copyWith(isFavorite: !recipe.isFavorite);
    final repo = ref.read(recipeRepositoryProvider);
    await repo.saveRecipe(updated);

    if (!mounted) return;
    ChefToastService.show(
      context: context,
      title: updated.isFavorite ? 'Saved to Favorites' : 'Removed from Favorites',
      description: updated.title,
      type: updated.isFavorite ? ChefToastType.success : ChefToastType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;
    final recipesAsync = ref.watch(recipesStreamProvider);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () => _searchFocusNode.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () => _searchFocusNode.requestFocus(),
      },
      child: Scaffold(
        backgroundColor: colors.surfaceCanvas,
        appBar: AppBar(
          backgroundColor: colors.surfacePaper,
          elevation: 0,
          title: const ChefBrandBadge(size: 34, showTitle: true),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              color: colors.accentTomato,
              onPressed: _openAIStudio,
              tooltip: 'AI Sous Chef Studio',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              color: colors.accentHerb,
              onPressed: _addNewRecipe,
              tooltip: 'Add Recipe Note',
            ),
            const SizedBox(width: ChefSpacing.space2),
          ],
        ),
        body: recipesAsync.when(
          data: (allRecipes) {
            final favoritesCount = allRecipes.where((r) => r.isFavorite).length;

            // Filtering & Sorting
            final query = _searchController.text.trim().toLowerCase();
            final filtered = allRecipes.where((r) {
              final matchQuery = query.isEmpty ||
                  r.title.toLowerCase().contains(query) ||
                  (r.summary?.toLowerCase().contains(query) ?? false) ||
                  r.ingredients.any((i) => i.displayName.toLowerCase().contains(query));

              if (!matchQuery) return false;

              if (_selectedCategory == 'fav') return r.isFavorite;
              if (_selectedCategory == 'pasta') {
                return r.title.toLowerCase().contains('pasta') ||
                    r.title.toLowerCase().contains('pomodoro') ||
                    r.title.toLowerCase().contains('fettuccine');
              }
              if (_selectedCategory == 'bread') {
                return r.title.toLowerCase().contains('sourdough') || r.title.toLowerCase().contains('bread');
              }
              if (_selectedCategory == 'sweets') {
                return r.title.toLowerCase().contains('crêpe') ||
                    r.title.toLowerCase().contains('pancake') ||
                    r.title.toLowerCase().contains('sweet');
              }
              if (_selectedCategory == 'ramen') {
                return r.title.toLowerCase().contains('ramen') || r.title.toLowerCase().contains('soup');
              }
              if (_selectedCategory == 'greens') {
                return r.title.toLowerCase().contains('avocado') ||
                    r.title.toLowerCase().contains('salad') ||
                    r.title.toLowerCase().contains('green');
              }
              return true;
            }).toList();

            if (_sortBy == 'time') {
              filtered.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
            } else if (_sortBy == 'ingredients') {
              filtered.sort((a, b) => a.ingredients.length.compareTo(b.ingredients.length));
            } else if (_sortBy == 'easy') {
              final rank = {RecipeDifficulty.easy: 1, RecipeDifficulty.medium: 2, RecipeDifficulty.hard: 3};
              filtered.sort((a, b) => (rank[a.difficulty] ?? 2).compareTo(rank[b.difficulty] ?? 2));
            } else if (_sortBy == 'fav') {
              filtered.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space4, vertical: ChefSpacing.space3),
              children: [
                // 📱 Mobile Hero Banner
                Container(
                  padding: const EdgeInsets.all(ChefSpacing.space4),
                  decoration: BoxDecoration(
                    color: colors.surfacePaper,
                    borderRadius: BorderRadius.circular(ChefRadius.card),
                    border: Border.all(color: colors.outlineSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.accentTomato,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: ChefSpacing.space2),
                              Text(
                                'COOKBOOK COLLECTION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: colors.accentTomato,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(ChefRadius.pill),
                              border: Border.all(color: colors.outlineSubtle),
                            ),
                            child: Text(
                              '${allRecipes.length} Recipes • $favoritesCount Favs',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.contentSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ChefSpacing.space3),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEEF4F0),
                                foregroundColor: const Color(0xFF4A6B53),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ChefRadius.card),
                                  side: const BorderSide(color: Color(0xFFD3E2D7)),
                                ),
                              ),
                              icon: const Icon(Icons.auto_awesome, size: 16),
                              label: const Text('AI Studio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              onPressed: _openAIStudio,
                            ),
                          ),
                          const SizedBox(width: ChefSpacing.space2),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.accentTomato,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ChefRadius.card),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('New Recipe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              onPressed: _addNewRecipe,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ChefSpacing.space3),

                // Search & Sort Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surfacePaper,
                          borderRadius: BorderRadius.circular(ChefRadius.card),
                          border: Border.all(color: colors.outlineSubtle),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search recipes by title, ingredients...',
                            hintStyle: TextStyle(color: colors.contentSecondary, fontSize: 12),
                            prefixIcon: Icon(Icons.search, size: 18, color: colors.contentSecondary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ChefSpacing.space2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: colors.surfacePaper,
                        borderRadius: BorderRadius.circular(ChefRadius.card),
                        border: Border.all(color: colors.outlineSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          icon: Icon(Icons.sort, size: 16, color: colors.accentTomato),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.contentPrimary),
                          items: const [
                            DropdownMenuItem(value: 'default', child: Text('Default')),
                            DropdownMenuItem(value: 'time', child: Text('Fastest')),
                            DropdownMenuItem(value: 'ingredients', child: Text('Fewest Items')),
                            DropdownMenuItem(value: 'easy', child: Text('Easiest')),
                            DropdownMenuItem(value: 'fav', child: Text('Favorites')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _sortBy = val);
                              audioChime.playTap();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ChefSpacing.space3),

                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryPill('all', 'All Recipes', Icons.auto_awesome),
                      _buildCategoryPill('fav', 'Favorites', Icons.favorite),
                      _buildCategoryPill('pasta', 'Pasta & Fettuccine', Icons.restaurant),
                      _buildCategoryPill('bread', 'Artisan Sourdough', Icons.grain),
                      _buildCategoryPill('sweets', 'Crêpes & Pastry', Icons.cake),
                      _buildCategoryPill('ramen', 'Ramen & Broths', Icons.soup_kitchen),
                      _buildCategoryPill('greens', 'Garden Greens', Icons.eco),
                    ],
                  ),
                ),
                const SizedBox(height: ChefSpacing.space4),

                // Recipe Cards Grid / List
                if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(ChefSpacing.space6),
                    decoration: BoxDecoration(
                      color: colors.surfacePaper,
                      borderRadius: BorderRadius.circular(ChefRadius.card),
                      border: Border.all(color: colors.outlineSubtle, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 40, color: colors.accentTomato),
                        const SizedBox(height: ChefSpacing.space3),
                        Text(
                          'No illustrated recipes found',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try adjusting your search query or generate one with AI!',
                          style: TextStyle(fontSize: 12, color: colors.contentSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ChefSpacing.space3),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accentTomato,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.pill)),
                          ),
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Generate with AI', style: TextStyle(fontWeight: FontWeight.w800)),
                          onPressed: _openAIStudio,
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map((recipe) => _buildRecipeCard(context, recipe)),
                const SizedBox(height: 80),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load library: $err')),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String id, String label, IconData icon) {
    final isSelected = _selectedCategory == id;
    final colors = Theme.of(context).extension<ChefColors>()!;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : colors.accentTomato),
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : colors.contentPrimary)),
        backgroundColor: colors.surfacePaper,
        selectedColor: const Color(0xFF1E1A18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChefRadius.pill),
          side: BorderSide(color: isSelected ? Colors.transparent : colors.outlineSubtle),
        ),
        onSelected: (_) {
          audioChime.playTap();
          setState(() => _selectedCategory = id);
        },
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return GestureDetector(
      onTap: () {
        audioChime.playTap();
        context.push('/recipe/${recipe.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: ChefSpacing.space4),
        decoration: BoxDecoration(
          color: colors.surfacePaper,
          borderRadius: BorderRadius.circular(ChefRadius.card),
          border: Border.all(color: colors.outlineSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Polaroid Cover Header with Tape
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(ChefRadius.card)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    recipe.coverImage ?? 'assets/illustrations/sketchbook_pasta.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: colors.surfaceRaised,
                      child: Icon(Icons.restaurant_menu, size: 48, color: colors.accentTomato),
                    ),
                  ),
                ),
              ),

              // Decorative Washi Tape on Top Left
              const Positioned(
                top: 8,
                left: 12,
                child: WashiTape(
                  width: 50,
                  height: 14,
                  rotation: -0.06,
                  pattern: WashiTapePattern.terracotta,
                ),
              ),

              // Favorite Toggle Button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(recipe),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: recipe.isFavorite ? colors.accentTomato : colors.contentSecondary,
                    ),
                  ),
                ),
              ),

              // Difficulty Badge
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(ChefRadius.pill),
                    border: Border.all(color: colors.outlineSubtle),
                  ),
                  child: Text(
                    recipe.difficulty.name.toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF1E1A18)),
                  ),
                ),
              ),
            ],
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(ChefSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood Stamps
                if (recipe.moodStamps.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: recipe.moodStamps.take(2).map((stamp) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF7F2),
                            borderRadius: BorderRadius.circular(ChefRadius.pill),
                            border: Border.all(color: colors.outlineSubtle),
                          ),
                          child: Text(
                            stamp,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.contentSecondary),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                Text(
                  recipe.title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                if (recipe.summary != null && recipe.summary!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    recipe.summary!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.contentSecondary, fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: ChefSpacing.space3),

                // Stats Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colors.outlineSubtle)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: colors.accentTomato),
                          const SizedBox(width: 4),
                          Text('${recipe.totalMinutes} mins', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.group_outlined, size: 14, color: colors.accentHerb),
                          const SizedBox(width: 4),
                          Text('${recipe.baseServings.toDisplayString()} serv', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.layers_outlined, size: 14, color: colors.accentYolk),
                          const SizedBox(width: 4),
                          Text('${recipe.ingredients.length} items', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ChefSpacing.space2),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.contentPrimary,
                          side: BorderSide(color: colors.outlineSubtle),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.card)),
                        ),
                        icon: const Icon(Icons.menu_book_outlined, size: 14),
                        label: const Text('Open Note', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        onPressed: () {
                          audioChime.playTap();
                          context.push('/recipe/${recipe.id}');
                        },
                      ),
                    ),
                    const SizedBox(width: ChefSpacing.space2),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF4F0),
                          foregroundColor: const Color(0xFF4A6B53),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ChefRadius.card),
                            side: const BorderSide(color: Color(0xFFD3E2D7)),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Cook Mode', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        onPressed: () {
                          audioChime.playTap();
                          context.push('/cook/${recipe.id}');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
