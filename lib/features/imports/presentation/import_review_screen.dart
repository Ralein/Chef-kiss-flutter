import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';

class ImportReviewScreen extends ConsumerStatefulWidget {
  final String jobId;

  const ImportReviewScreen({super.key, required this.jobId});

  @override
  ConsumerState<ImportReviewScreen> createState() => _ImportReviewScreenState();
}

class _ImportReviewScreenState extends ConsumerState<ImportReviewScreen> {
  Recipe? _editableRecipe;
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _summaryController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _initRecipe(Recipe recipe) {
    if (_initialized) return;
    _editableRecipe = recipe;
    _titleController.text = recipe.title;
    _summaryController.text = recipe.summary ?? '';
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final jobAsync = ref.watch(singleImportJobProvider(widget.jobId));

    return Scaffold(
      backgroundColor: colors.surfaceCanvas,
      appBar: AppBar(
        title: Text('Review Extracted Recipe', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/'),
            tooltip: 'Cancel Review',
          ),
        ],
      ),
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return const Center(child: Text('Import job not found.'));
          }

          if (job.status == ImportStatus.extracting || job.status == ImportStatus.preprocessing || job.status == ImportStatus.queued) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: colors.accentTomato),
                  const SizedBox(height: ChefSpacing.space4),
                  Text('Extracting recipe facts...', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: ChefSpacing.space1),
                  Text('Normalizing ingredients, units, and steps locally.', style: textTheme.bodyMedium),
                ],
              ),
            );
          }

          if (job.status == ImportStatus.failed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ChefSpacing.space5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: colors.stateDanger, size: 48),
                    const SizedBox(height: ChefSpacing.space3),
                    Text('Extraction Failed', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: ChefSpacing.space1),
                    Text(job.failureReason ?? 'Unknown error occurred.', textAlign: TextAlign.center),
                    const SizedBox(height: ChefSpacing.space4),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final extracted = job.extractedDraft;
          if (extracted == null) {
            return const Center(child: Text('No extracted draft found.'));
          }

          _initRecipe(extracted);
          final current = _editableRecipe ?? extracted;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(ChefSpacing.space4),
                  children: [
                    // 1. Provenance & Confidence Banner
                    Container(
                      padding: const EdgeInsets.all(ChefSpacing.space3),
                      decoration: BoxDecoration(
                        color: colors.surfacePaper,
                        borderRadius: BorderRadius.circular(ChefRadius.card),
                        border: Border.all(color: colors.outlineSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: colors.accentTomato, size: 20),
                          const SizedBox(width: ChefSpacing.space2),
                          Expanded(
                            child: Text(
                              'Extracted from ${job.source.kind.name.toUpperCase()} source',
                              style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space2, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.accentHerb.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(ChefRadius.pill),
                            ),
                            child: Text(
                              '${(job.overallConfidence * 100).toInt()}% Confidence',
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.accentHerb,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: ChefSpacing.space3),

                    // 2. Safety & Allergen Alerts (if any)
                    if (job.warnings.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(ChefSpacing.space3),
                        decoration: BoxDecoration(
                          color: colors.stateWarning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(ChefRadius.card),
                          border: Border.all(color: colors.stateWarning.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: colors.stateWarning, size: 18),
                                const SizedBox(width: ChefSpacing.space2),
                                Text(
                                  'Safety & Allergen Warnings',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colors.stateWarning,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: ChefSpacing.space1),
                            ...job.warnings.map((w) => Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('• $w', style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: ChefSpacing.space4),
                    ],

                    // 3. Basic Details Card
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
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Recipe Title',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _editableRecipe = current.copyWith(title: val.trim());
                              });
                            },
                          ),
                          const SizedBox(height: ChefSpacing.space3),
                          TextFormField(
                            controller: _summaryController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Description / Story',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _editableRecipe = current.copyWith(summary: val.trim());
                              });
                            },
                          ),
                          const SizedBox(height: ChefSpacing.space3),
                          Row(
                            children: [
                              Text('Servings: ', style: textTheme.bodyMedium),
                              QuantityStepper(
                                value: current.baseServings,
                                label: '',
                                onChanged: (val) {
                                  setState(() {
                                    _editableRecipe = current.copyWith(baseServings: val);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: ChefSpacing.space4),

                    // 4. Extracted Ingredients Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Extracted Ingredients (${current.ingredients.length})', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: ChefSpacing.space2),
                    ...current.ingredients.map((ing) => IngredientTile(
                          ingredient: ing,
                          showCheckbox: false,
                        )),
                    const SizedBox(height: ChefSpacing.space4),

                    // 5. Extracted Preparation Steps
                    Text('Extracted Cooking Steps (${current.steps.length})', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: ChefSpacing.space2),
                    ...current.steps.map((step) => Padding(
                          padding: const EdgeInsets.only(bottom: ChefSpacing.space2),
                          child: StepCanvas(
                            step: step,
                            totalSteps: current.steps.length,
                            isActive: false,
                          ),
                        )),
                    const SizedBox(height: ChefSpacing.space6),
                  ],
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(ChefSpacing.space4),
                decoration: BoxDecoration(
                  color: colors.surfacePaper,
                  border: Border(top: BorderSide(color: colors.outlineSubtle)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          ref.read(importRepositoryProvider).cancelJob(widget.jobId);
                          context.go('/');
                        },
                        child: const Text('Discard'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Accept & Save Recipe', style: TextStyle(fontWeight: FontWeight.w700)),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.accentTomato,
                          foregroundColor: colors.contentInverse,
                          padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space5, vertical: ChefSpacing.space3),
                        ),
                        onPressed: () async {
                          final recipeToSave = current.copyWith(
                            title: _titleController.text.trim().isEmpty ? 'Imported Recipe' : _titleController.text.trim(),
                            summary: _summaryController.text.trim(),
                          );

                          final res = await ref.read(importRepositoryProvider).acceptImportReview(
                                jobId: widget.jobId,
                                recipe: recipeToSave,
                              );

                          res.when(
                            ok: (saved) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Recipe accepted and added to your library!')),
                              );
                              context.go('/recipe/${saved.id}');
                            },
                            err: (f) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to save recipe: ${f.message}')),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading job: $err')),
      ),
    );
  }
}
