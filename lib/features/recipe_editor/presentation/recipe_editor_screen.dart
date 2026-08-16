import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:uuid/uuid.dart';
import '../../../app/providers.dart';
import 'visual_sketchbook_editor.dart';

class RecipeEditorScreen extends ConsumerStatefulWidget {
  final String? recipeId;

  const RecipeEditorScreen({super.key, this.recipeId});

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();
  final RecipeValidator _validator = const RecipeValidator();

  bool _isSketchbookMode = true;
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _totalMinutesController;
  Rational _servings = Rational(2);
  RecipeDifficulty _difficulty = RecipeDifficulty.medium;
  RecipeStatus _status = RecipeStatus.draft;

  List<RecipeIngredient> _ingredients = [];
  List<RecipeStep> _steps = [];
  bool _initialized = false;
  String _recipeId = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _summaryController = TextEditingController();
    _totalMinutesController = TextEditingController(text: '15');
    _recipeId = widget.recipeId ?? _uuid.v4();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _totalMinutesController.dispose();
    super.dispose();
  }

  void _populateFromRecipe(Recipe recipe) {
    if (_initialized) return;
    _recipeId = recipe.id;
    _titleController.text = recipe.title;
    _summaryController.text = recipe.summary ?? '';
    _totalMinutesController.text = recipe.totalMinutes.toString();
    _servings = recipe.baseServings;
    _difficulty = recipe.difficulty;
    _status = recipe.status;
    _ingredients = List.from(recipe.ingredients);
    _steps = List.from(recipe.steps);
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recipeId != null && !_initialized) {
      final recipeAsync = ref.watch(singleRecipeProvider(widget.recipeId!));
      return recipeAsync.when(
        data: (recipe) {
          if (recipe != null) _populateFromRecipe(recipe);
          return _buildEditorScaffold(context);
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      );
    }

    if (!_initialized && _ingredients.isEmpty && _steps.isEmpty) {
      // Add initial placeholder rows
      _ingredients.add(RecipeIngredient(
        id: _uuid.v4(),
        recipeId: _recipeId,
        displayName: '',
        quantity: Rational(1),
        unitCode: 'cup',
        position: 1,
      ));
      _steps.add(RecipeStep(
        id: _uuid.v4(),
        recipeId: _recipeId,
        position: 1,
        instructionShort: '',
      ));
      _initialized = true;
    }

    return _buildEditorScaffold(context);
  }

  Widget _buildEditorScaffold(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Scaffold(
      backgroundColor: colors.surfaceCanvas,
      appBar: AppBar(
        title: Text(
          widget.recipeId != null ? 'Edit Recipe' : 'New Recipe',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSketchbookMode ? Icons.view_quilt : Icons.brush_outlined),
            tooltip: _isSketchbookMode ? 'Switch to Form View' : 'Switch to Visual Sketchbook',
            color: colors.accentTomato,
            onPressed: () {
              setState(() => _isSketchbookMode = !_isSketchbookMode);
            },
          ),
          TextButton(
            onPressed: () => _saveRecipe(isReady: false),
            child: const Text('Save Draft'),
          ),
          const SizedBox(width: ChefSpacing.space2),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.accentTomato),
            onPressed: () => _saveRecipe(isReady: true),
            child: const Text('Ready to Cook'),
          ),
          const SizedBox(width: ChefSpacing.space3),
        ],
      ),
      body: _isSketchbookMode
          ? VisualSketchbookEditor(
              recipeId: _recipeId,
              titleController: _titleController,
              summaryController: _summaryController,
              ingredients: _ingredients,
              steps: _steps,
              servings: _servings,
              difficulty: _difficulty,
              onServingsChanged: (s) => setState(() => _servings = s),
              onDifficultyChanged: (d) => setState(() => _difficulty = d),
              onStateChanged: () => setState(() {}),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(ChefSpacing.space4),
                children: [
            // 1. Basic Info Card
            Container(
              padding: const EdgeInsets.all(ChefSpacing.space4),
              decoration: BoxDecoration(
                color: colors.surfacePaper,
                borderRadius: BorderRadius.circular(ChefRadius.card),
                border: Border.all(color: colors.outlineSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Basic Details', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: ChefSpacing.space3),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Title',
                      hintText: 'e.g. Grandma’s Sourdough Focaccia',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (_status == RecipeStatus.ready && (val == null || val.trim().isEmpty)) {
                        return 'Title is required to mark recipe ready';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ChefSpacing.space3),
                  TextFormField(
                    controller: _summaryController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Short Description / Story',
                      hintText: 'Crisp golden crust, fragrant with rosemary and olive oil.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: ChefSpacing.space3),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('Base Servings:', style: textTheme.bodyMedium),
                            const SizedBox(width: ChefSpacing.space2),
                            QuantityStepper(
                              value: _servings,
                              label: '',
                              onChanged: (val) {
                                setState(() {
                                  _servings = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _totalMinutesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Minutes',
                            suffixText: 'mins',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: ChefSpacing.space5),

            // 2. Ingredients Builder Card
            Container(
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
                      Text('Ingredients', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Ingredient'),
                        onPressed: () {
                          setState(() {
                            _ingredients.add(RecipeIngredient(
                              id: _uuid.v4(),
                              recipeId: _recipeId,
                              displayName: '',
                              quantity: Rational(1),
                              unitCode: 'each',
                              position: _ingredients.length + 1,
                            ));
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: ChefSpacing.space2),
                  ..._ingredients.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ing = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: ChefSpacing.space2),
                      child: Row(
                        children: [
                          // Quantity
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: ing.quantity?.toDisplayString() ?? '',
                              decoration: const InputDecoration(hintText: 'Qty', border: OutlineInputBorder()),
                              onChanged: (val) {
                                final parsed = Rational.tryParse(val);
                                _ingredients[index] = ing.copyWith(quantity: parsed);
                              },
                            ),
                          ),
                          const SizedBox(width: ChefSpacing.space1),
                          // Unit
                          SizedBox(
                            width: 75,
                            child: TextFormField(
                              initialValue: ing.unitCode ?? '',
                              decoration: const InputDecoration(hintText: 'Unit', border: OutlineInputBorder()),
                              onChanged: (val) {
                                _ingredients[index] = ing.copyWith(unitCode: val.trim());
                              },
                            ),
                          ),
                          const SizedBox(width: ChefSpacing.space1),
                          // Display Name
                          Expanded(
                            child: TextFormField(
                              initialValue: ing.displayName,
                              decoration: const InputDecoration(hintText: 'Ingredient name', border: OutlineInputBorder()),
                              onChanged: (val) {
                                _ingredients[index] = ing.copyWith(displayName: val.trim());
                              },
                            ),
                          ),
                          const SizedBox(width: ChefSpacing.space1),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: colors.stateDanger,
                            onPressed: _ingredients.length > 1
                                ? () {
                                    setState(() {
                                      _ingredients.removeAt(index);
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: ChefSpacing.space5),

            // 3. Steps Builder Card
            Container(
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
                      Text('Cooking Steps', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Step'),
                        onPressed: () {
                          setState(() {
                            _steps.add(RecipeStep(
                              id: _uuid.v4(),
                              recipeId: _recipeId,
                              position: _steps.length + 1,
                              instructionShort: '',
                            ));
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: ChefSpacing.space2),
                  ..._steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: ChefSpacing.space3),
                      padding: const EdgeInsets.all(ChefSpacing.space3),
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(ChefRadius.tile),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Step ${index + 1}', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: colors.stateDanger,
                                onPressed: _steps.length > 1
                                    ? () {
                                        setState(() {
                                          _steps.removeAt(index);
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: step.instructionShort,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Short Instruction',
                              hintText: 'e.g. Sauté garlic and onions in olive oil until golden.',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              _steps[index] = step.copyWith(instructionShort: val.trim());
                            },
                          ),
                          const SizedBox(height: ChefSpacing.space2),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: step.actionKey ?? '',
                                  decoration: const InputDecoration(
                                    labelText: 'Action Verb',
                                    hintText: 'sauté, bake, boil',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    _steps[index] = step.copyWith(actionKey: val.trim());
                                  },
                                ),
                              ),
                              const SizedBox(width: ChefSpacing.space2),
                              Expanded(
                                child: TextFormField(
                                  initialValue: step.durationSeconds != null
                                      ? (step.durationSeconds! ~/ 60).toString()
                                      : '',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Timer (Minutes)',
                                    suffixText: 'm',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    final mins = int.tryParse(val.trim());
                                    if (mins != null && mins > 0) {
                                      _steps[index] = step.copyWith(
                                        durationSeconds: mins * 60,
                                        timers: [
                                          StepTimer(
                                            id: _uuid.v4(),
                                            recipeStepId: step.id,
                                            label: 'Step ${index + 1}',
                                            durationSeconds: mins * 60,
                                            position: 1,
                                          )
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _saveRecipe({required bool isReady}) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final totalMinutes = int.tryParse(_totalMinutesController.text) ?? 15;

    final updatedRecipe = Recipe(
      id: _recipeId,
      profileId: 'default',
      title: _titleController.text.trim().isEmpty ? 'Untitled Draft' : _titleController.text.trim(),
      summary: _summaryController.text.trim(),
      status: isReady ? RecipeStatus.ready : RecipeStatus.draft,
      baseServings: _servings,
      difficulty: _difficulty,
      totalMinutes: totalMinutes,
      createdAt: now,
      updatedAt: now,
      origin: Origin.manual,
      ingredients: _ingredients,
      steps: _steps,
    );

    if (isReady) {
      final validation = _validator.validateForReady(updatedRecipe);
      if (!validation.isValid) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Incomplete Recipe'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: validation.blockingErrors
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('• ${e.message}'),
                      ))
                  .toList(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
        return;
      }
    }

    final res = await ref.read(recipeRepositoryProvider).saveRecipe(updatedRecipe);
    res.when(
      ok: (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isReady ? 'Recipe saved and ready to cook!' : 'Draft saved.')),
        );
        context.go('/recipe/${saved.id}');
      },
      err: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipe: ${failure.message}')),
        );
      },
    );
  }
}
