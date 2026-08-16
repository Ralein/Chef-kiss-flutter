import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:uuid/uuid.dart';

class VisualSketchbookEditor extends StatefulWidget {
  final String recipeId;
  final TextEditingController titleController;
  final TextEditingController summaryController;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final Rational servings;
  final RecipeDifficulty difficulty;
  final ValueChanged<Rational> onServingsChanged;
  final ValueChanged<RecipeDifficulty> onDifficultyChanged;
  final VoidCallback onStateChanged;

  const VisualSketchbookEditor({
    super.key,
    required this.recipeId,
    required this.titleController,
    required this.summaryController,
    required this.ingredients,
    required this.steps,
    required this.servings,
    required this.difficulty,
    required this.onServingsChanged,
    required this.onDifficultyChanged,
    required this.onStateChanged,
  });

  @override
  State<VisualSketchbookEditor> createState() => _VisualSketchbookEditorState();
}

class _VisualSketchbookEditorState extends State<VisualSketchbookEditor> {
  final Uuid _uuid = const Uuid();
  final Set<String> _selectedMoodStamps = {'Chef\'s Secret', 'Slow Simmer'};

  static const List<Map<String, dynamic>> _quickIngredientsCatalog = [
    {'name': 'San Marzano Tomatoes', 'unit': 'cans', 'qty': '2', 'icon': Icons.agriculture_outlined},
    {'name': '00 Flour', 'unit': 'g', 'qty': '400', 'icon': Icons.grain},
    {'name': 'Fresh Eggs', 'unit': 'large', 'qty': '4', 'icon': Icons.egg_outlined},
    {'name': 'Extra Virgin Olive Oil', 'unit': 'tbsp', 'qty': '3', 'icon': Icons.liquor_outlined},
    {'name': 'Garlic Cloves', 'unit': 'cloves', 'qty': '4', 'icon': Icons.agriculture_outlined},
    {'name': 'Fresh Basil Leaves', 'unit': 'handful', 'qty': '1', 'icon': Icons.eco_outlined},
    {'name': 'Parmigiano Reggiano', 'unit': 'g', 'qty': '50', 'icon': Icons.local_dining_outlined},
    {'name': 'Sea Salt Flakes', 'unit': 'pinch', 'qty': '1', 'icon': Icons.grain_outlined},
    {'name': 'Cracked Black Pepper', 'unit': 'tsp', 'qty': '1', 'icon': Icons.grain_outlined},
    {'name': 'Active Sourdough Starter', 'unit': 'g', 'qty': '100', 'icon': Icons.bakery_dining_outlined},
    {'name': 'Warm Water', 'unit': 'ml', 'qty': '350', 'icon': Icons.water_drop_outlined},
    {'name': 'Whole Milk', 'unit': 'ml', 'qty': '250', 'icon': Icons.local_cafe_outlined},
  ];

  static const List<Map<String, dynamic>> _actionVerbTemplates = [
    {'verb': 'Sauté', 'icon': Icons.fireplace, 'hint': 'Sauté garlic in olive oil until golden fragrant.'},
    {'verb': 'Simmer', 'icon': Icons.soup_kitchen, 'hint': 'Simmer sauce gently for 15-20 minutes.'},
    {'verb': 'Knead', 'icon': Icons.pan_tool_outlined, 'hint': 'Knead dough for 8-10 minutes until silky smooth.'},
    {'verb': 'Whisk', 'icon': Icons.blender_outlined, 'hint': 'Whisk eggs and milk into a smooth batter.'},
    {'verb': 'Proof', 'icon': Icons.hourglass_top, 'hint': 'Let dough rest and proof in warm spot for 1 hour.'},
    {'verb': 'Bake', 'icon': Icons.outdoor_grill, 'hint': 'Bake at 220°C in preheated Dutch oven for 25 minutes.'},
    {'verb': 'Fold', 'icon': Icons.layers_outlined, 'hint': 'Fold crêpes gently into quarters with fresh berries.'},
    {'verb': 'Season', 'icon': Icons.grain, 'hint': 'Season with Maldon sea salt and fresh cracked pepper.'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ChefSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sketchbook Title & Washi Tape Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ChefSpacing.space5),
            decoration: BoxDecoration(
              color: colors.surfacePaper,
              borderRadius: BorderRadius.circular(ChefRadius.card),
              border: Border.all(color: colors.accentTomato.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: colors.accentTomato.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: -24,
                  right: 20,
                  child: WashiTape(width: 70, height: 18, rotation: 0.08),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const DoodleStamp(label: 'Recipe Journal', icon: Icons.auto_stories, color: Colors.deepOrange),
                        const Spacer(),
                        Wrap(
                          spacing: ChefSpacing.space1,
                          children: [
                            'Chef\'s Secret',
                            'Crispy!',
                            'Slow Simmer',
                            'Stay Fresh!',
                          ].map((stamp) {
                            final isSelected = _selectedMoodStamps.contains(stamp);
                            return FilterChip(
                              label: Text(stamp, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedMoodStamps.add(stamp);
                                  } else {
                                    _selectedMoodStamps.remove(stamp);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: ChefSpacing.space3),
                    TextField(
                      controller: widget.titleController,
                      decoration: const InputDecoration(
                        hintText: 'Recipe Title (e.g. Fresh Artisanal Fettuccine)...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 22),
                      onChanged: (_) => widget.onStateChanged(),
                    ),
                    const Divider(),
                    TextField(
                      controller: widget.summaryController,
                      decoration: const InputDecoration(
                        hintText: 'A little note about this dish, origin story, or special tips...',
                        border: InputBorder.none,
                      ),
                      style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                      maxLines: 2,
                      onChanged: (_) => widget.onStateChanged(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ChefSpacing.space4),

          // 2. Interactive Mise en Place Sticker Palette
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ChefSpacing.space4),
            decoration: BoxDecoration(
              color: colors.surfacePaper,
              borderRadius: BorderRadius.circular(ChefRadius.card),
              border: Border.all(color: colors.outlineSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Mise en Place Stickers', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(width: ChefSpacing.space2),
                        const DoodleStamp(label: 'Tap to Add', icon: Icons.add, color: Colors.green),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: colors.accentTomato,
                      tooltip: 'Add Custom Ingredient',
                      onPressed: () => _showAddCustomIngredientDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: ChefSpacing.space1),
                Text(
                  'Tap any sticker below to add it directly to your recipe notes:',
                  style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary),
                ),
                const SizedBox(height: ChefSpacing.space3),

                // Quick add sticker palette
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickIngredientsCatalog.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: ChefSpacing.space2),
                        child: ActionChip(
                          avatar: Icon(item['icon'] as IconData, size: 16, color: colors.accentTomato),
                          label: Text('${item['name']} (${item['qty']} ${item['unit']})'),
                          onPressed: () {
                            setState(() {
                              widget.ingredients.add(RecipeIngredient(
                                id: _uuid.v4(),
                                recipeId: widget.recipeId,
                                displayName: item['name'] as String,
                                quantity: Rational(int.tryParse(item['qty'] as String) ?? 1),
                                unitCode: item['unit'] as String,
                                position: widget.ingredients.length + 1,
                              ));
                              widget.onStateChanged();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: ChefSpacing.space5),

                // Current Recipe Ingredients Board
                Text('Active Ingredients on Canvas (${widget.ingredients.length}):',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: ChefSpacing.space2),
                if (widget.ingredients.isEmpty)
                  const Text('No ingredient stickers on canvas yet. Tap stickers above to add!')
                else
                  Wrap(
                    spacing: ChefSpacing.space2,
                    runSpacing: ChefSpacing.space2,
                    children: widget.ingredients.map((ing) {
                      final qtyStr = ing.quantity != null ? ing.quantity!.toDisplayString() : '1';
                      final unitStr = (ing.unitCode != null && ing.unitCode!.isNotEmpty) ? ' ${ing.unitCode}' : '';
                      return Chip(
                        avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        label: Text('${ing.displayName} ($qtyStr$unitStr)'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            widget.ingredients.removeWhere((i) => i.id == ing.id);
                            widget.onStateChanged();
                          });
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: ChefSpacing.space4),

          // 3. Visual Step Story Board
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ChefSpacing.space4),
            decoration: BoxDecoration(
              color: colors.surfacePaper,
              borderRadius: BorderRadius.circular(ChefRadius.card),
              border: Border.all(color: colors.outlineSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Visual Step Sequence', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(width: ChefSpacing.space2),
                        const DoodleStamp(label: 'Action Story', icon: Icons.movie_creation_outlined, color: Colors.purple),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: colors.accentTomato,
                      tooltip: 'Add Step Block',
                      onPressed: () => _showAddStepDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: ChefSpacing.space1),
                Text('Quick-tap action templates to assemble your cooking timeline:',
                    style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary)),
                const SizedBox(height: ChefSpacing.space3),

                // Quick action templates
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _actionVerbTemplates.map((act) {
                      return Padding(
                        padding: const EdgeInsets.only(right: ChefSpacing.space2),
                        child: ActionChip(
                          avatar: Icon(act['icon'] as IconData, size: 16, color: colors.accentHerb),
                          label: Text(act['verb'] as String),
                          onPressed: () {
                            setState(() {
                              widget.steps.add(RecipeStep(
                                id: _uuid.v4(),
                                recipeId: widget.recipeId,
                                position: widget.steps.length + 1,
                                actionKey: (act['verb'] as String).toLowerCase(),
                                instructionShort: act['hint'] as String,
                                instructionDetail: act['hint'] as String,
                              ));
                              widget.onStateChanged();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: ChefSpacing.space5),

                // Step Cards on Canvas
                Text('Steps on Canvas (${widget.steps.length}):',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: ChefSpacing.space2),
                if (widget.steps.isEmpty)
                  const Text('No preparation steps added yet. Tap an action verb above!')
                else
                  ...widget.steps.map((st) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: ChefSpacing.space3),
                      child: Container(
                        padding: const EdgeInsets.all(ChefSpacing.space4),
                        decoration: BoxDecoration(
                          color: colors.surfaceCanvas,
                          borderRadius: BorderRadius.circular(ChefRadius.tile),
                          border: Border.all(color: colors.outlineSubtle),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.accentTomato.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(ChefRadius.pill),
                              ),
                              child: Text(
                                '${st.position}',
                                style: TextStyle(fontWeight: FontWeight.w900, color: colors.accentTomato),
                              ),
                            ),
                            const SizedBox(width: ChefSpacing.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (st.actionKey != null && st.actionKey!.isNotEmpty)
                                    Text(
                                      st.actionKey!.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colors.accentHerb,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  Text(
                                    st.instructionShort,
                                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () {
                                setState(() {
                                  widget.steps.removeWhere((s) => s.id == st.id);
                                  // Re-index positions
                                  for (var i = 0; i < widget.steps.length; i++) {
                                    widget.steps[i] = widget.steps[i].copyWith(position: i + 1);
                                  }
                                  widget.onStateChanged();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: ChefSpacing.space6),
        ],
      ),
    );
  }

  void _showAddCustomIngredientDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final unitCtrl = TextEditingController(text: 'cup');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Ingredient Sticker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Ingredient Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: ChefSpacing.space3),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: ChefSpacing.space2),
                Expanded(
                  child: TextField(
                    controller: unitCtrl,
                    decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  widget.ingredients.add(RecipeIngredient(
                    id: _uuid.v4(),
                    recipeId: widget.recipeId,
                    displayName: nameCtrl.text.trim(),
                    quantity: Rational(int.tryParse(qtyCtrl.text) ?? 1),
                    unitCode: unitCtrl.text.trim(),
                    position: widget.ingredients.length + 1,
                  ));
                  widget.onStateChanged();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add to Canvas'),
          ),
        ],
      ),
    );
  }

  void _showAddStepDialog(BuildContext context) {
    final actCtrl = TextEditingController();
    final hintCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Step Block'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actCtrl,
              decoration: const InputDecoration(labelText: 'Action Verb (e.g. Sauté, Whisk)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: ChefSpacing.space3),
            TextField(
              controller: hintCtrl,
              decoration: const InputDecoration(labelText: 'Instruction', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (hintCtrl.text.trim().isNotEmpty) {
                setState(() {
                  widget.steps.add(RecipeStep(
                    id: _uuid.v4(),
                    recipeId: widget.recipeId,
                    position: widget.steps.length + 1,
                    actionKey: actCtrl.text.trim().toLowerCase(),
                    instructionShort: hintCtrl.text.trim(),
                  ));
                  widget.onStateChanged();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Step'),
          ),
        ],
      ),
    );
  }
}
