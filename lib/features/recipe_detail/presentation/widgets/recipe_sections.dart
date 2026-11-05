import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/chef_toast_service.dart';
import '../../../../app/providers.dart';
import '../../../../app/widgets/common_widgets.dart';
import '../../../../app/widgets/kitchen_format.dart';
import '../../../../app/widgets/nutrition_widgets.dart';
import '../../../../app/widgets/step_timer_button.dart';
import '../../../../core/ai/ai_connection.dart';

/// Scales one ingredient for [servings], tolerating a zero base.
ScaledIngredientResult scaleFor(Recipe recipe, RecipeIngredient ing, double servings) {
  final target = Rational.fromDouble(servings, 0.001);
  final base = recipe.baseServings.isZero ? target : recipe.baseServings;
  return const RecipeScalingEngine().scaleIngredient(ing, target / base);
}

String ingredientAmount(ScaledIngredientResult scaled) {
  final ing = scaled.original;
  final amount = KitchenFormat.amount(scaled.scaledQuantity, ing.unitCode, authored: ing.authoredQuantity);
  if (amount == null) return ing.scalingPolicy == ScalingPolicy.toTaste ? 'To taste' : '';
  return scaled.isApproximate ? '~$amount' : amount;
}

// --- Ingredients ----------------------------------------------------------------

class IngredientsSection extends StatelessWidget {
  final Recipe recipe;
  final int servings;
  final ValueChanged<int> onServingsChanged;
  final Set<String> checked;
  final ValueChanged<String> onToggle;
  final VoidCallback onClearChecks;

  const IngredientsSection({
    super.key,
    required this.recipe,
    required this.servings,
    required this.onServingsChanged,
    required this.checked,
    required this.onToggle,
    required this.onClearChecks,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;

    // Group headers are computed eagerly (not in deferred builders).
    final rows = <Widget>[];
    String? lastGroup;
    for (final ing in recipe.ingredients) {
      final group = ing.groupKey?.trim();
      if (group != null && group.isNotEmpty && group != lastGroup) {
        rows.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(group, style: t.labelLarge?.copyWith(color: c.contentSecondary)),
        ));
      }
      lastGroup = group;
      rows.add(_IngredientRow(
        scaled: scaleFor(recipe, ing, servings.toDouble()),
        checked: checked.contains(ing.id),
        onTap: () => onToggle(ing.id),
      ));
    }

    return ChefCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            'Ingredients',
            subtitle: checked.isEmpty ? 'Tap to check off as you prep' : '${checked.length} of ${recipe.ingredients.length} ready',
            trailing: ServingsStepper(value: servings, onChanged: onServingsChanged),
          ),
          const SizedBox(height: 8),
          if (recipe.ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No ingredients yet.', style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
            ),
          ...rows,
          if (checked.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onClearChecks,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Uncheck all'),
              ),
            ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final ScaledIngredientResult scaled;
  final bool checked;
  final VoidCallback onTap;
  const _IngredientRow({required this.scaled, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final ing = scaled.original;
    final amount = ingredientAmount(scaled);
    final strike = checked ? TextDecoration.lineThrough : null;
    final ink = checked ? c.contentSecondary : c.contentPrimary;

    return Semantics(
      checked: checked,
      label: '$amount ${ing.displayName}${ing.prepText != null ? ', ${ing.prepText}' : ''}${ing.isOptional ? ', optional' : ''}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Icon(
                checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: checked ? c.accentHerb : c.contentSecondary,
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: c.tomatoSoft, borderRadius: BorderRadius.circular(8)),
                child: Icon(getCulinaryIconData(ing.icon), size: 18, color: c.accentTomato),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    if (amount.isNotEmpty)
                      TextSpan(text: '$amount  ', style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: ink, decoration: strike)),
                    TextSpan(text: ing.displayName, style: t.bodyLarge?.copyWith(color: ink, decoration: strike)),
                    if (ing.prepText != null && ing.prepText!.isNotEmpty)
                      TextSpan(text: ', ${ing.prepText}', style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
                    if (ing.isOptional) TextSpan(text: '  (optional)', style: t.bodySmall),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServingsStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const ServingsStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(ChefRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Fewer servings',
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          Semantics(
            liveRegion: true,
            label: '$value servings',
            excludeSemantics: true,
            child: Text('$value serv.', style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          IconButton(
            tooltip: 'More servings',
            onPressed: value < 99 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

// --- Method ---------------------------------------------------------------------

class MethodSection extends StatelessWidget {
  final Recipe recipe;
  const MethodSection({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    return ChefCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader('Method', subtitle: '${recipe.steps.length} step${recipe.steps.length == 1 ? '' : 's'}'),
          const SizedBox(height: 12),
          if (recipe.steps.isEmpty)
            Text('No steps yet.', style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
          for (var i = 0; i < recipe.steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            _StepTile(recipe: recipe, step: recipe.steps[i], number: i + 1),
          ],
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final Recipe recipe;
  final RecipeStep step;
  final int number;
  const _StepTile({required this.recipe, required this.step, required this.number});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final temp = step.temperatureC != null
        ? '${step.temperatureC}°C / ${step.temperatureF ?? (step.temperatureC! * 9 / 5 + 32).round()}°F'
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.accentTomato, shape: BoxShape.circle),
          child: Text('$number', style: t.labelLarge?.copyWith(color: c.onAccent, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (step.actionKey != null && step.actionKey!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(step.actionKey!.toUpperCase(), style: t.labelSmall?.copyWith(letterSpacing: 1.1)),
                ),
              Text(step.instructionShort, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              if (step.instructionDetail != null && step.instructionDetail!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(step.instructionDetail!, style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
              ],
              if (temp != null || step.timers.isNotEmpty) const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (temp != null)
                    Chip(
                      avatar: Icon(Icons.thermostat_rounded, size: 18, color: c.accentTomato),
                      label: Text(temp),
                    ),
                  for (final timer in step.timers)
                    StepTimerButton(timer: timer, recipeId: recipe.id, recipeTitle: recipe.title),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Nutrition ------------------------------------------------------------------

class NutritionSection extends ConsumerStatefulWidget {
  final Recipe recipe;
  final RecipeNutritionReport report;

  const NutritionSection({super.key, required this.recipe, required this.report});

  @override
  ConsumerState<NutritionSection> createState() => _NutritionSectionState();
}

class _NutritionSectionState extends ConsumerState<NutritionSection> {
  bool _estimating = false;
  bool _expanded = false;

  Future<void> _estimateWithAi() async {
    final service = ref.read(aiNutritionServiceProvider);
    final recipeRepo = ref.read(recipeRepositoryProvider);
    if (service == null) return;
    setState(() => _estimating = true);
    final lines = widget.report.unresolved.map((l) => l.ingredient).toList();
    final res = await service.estimate(lines);
    if (!mounted) return;
    setState(() => _estimating = false);
    await res.when(
      ok: (estimates) async {
        if (estimates.isEmpty) {
          ChefToastService.show(context: context, title: 'No estimates returned', type: ChefToastType.info);
          return;
        }
        final updated = widget.recipe.copyWith(
          nutritionOverrides: {...widget.recipe.nutritionOverrides, ...estimates},
        );
        final saved = await recipeRepo.saveRecipe(updated);
        if (!mounted) return;
        ChefToastService.show(
          context: context,
          title: saved.isSuccess ? 'Nutrition updated' : 'Could not save the estimate',
          description: saved.isSuccess ? 'Added AI estimates for ${estimates.length} ingredient(s).' : saved.error?.message,
          type: saved.isSuccess ? ChefToastType.success : ChefToastType.error,
        );
      },
      err: (f) async => ChefToastService.show(
        context: context,
        title: f.message,
        description: f.recoveryAction,
        type: ChefToastType.error,
      ),
    );
  }

  Future<void> _logServing() async {
    final r = widget.recipe;
    final now = DateTime.now();
    final entry = FoodLogEntry(
      id: '${r.id}-${now.microsecondsSinceEpoch}',
      dayKey: dayKeyFor(now),
      mealSlot: MealSlot.forTime(now),
      title: r.title,
      source: FoodLogSource.recipe,
      recipeId: r.id,
      imagePath: r.coverImage,
      nutrition: widget.report.perServing,
      loggedAt: now.toUtc().millisecondsSinceEpoch,
    );
    final repo = ref.read(foodLogRepositoryProvider);
    final res = await repo.saveEntry(entry);
    if (!mounted) return;
    ChefToastService.show(
      context: context,
      title: res.isSuccess ? 'Logged 1 serving to ${entry.mealSlot.label}' : 'Could not log this meal',
      description: res.isSuccess ? '${KitchenFormat.kcal(entry.nutrition.calories)} kcal · ${r.title}' : res.error?.message,
      type: res.isSuccess ? ChefToastType.success : ChefToastType.error,
      actionLabel: res.isSuccess ? 'Undo' : null,
      onAction: res.isSuccess ? () => repo.deleteEntry(entry.id) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final report = widget.report;
    final per = report.perServing;
    final aiReady = ref.watch(aiConnectionProvider).valueOrNull?.isAvailable == true;
    final unresolved = report.unresolved;
    final diet = report.diet;

    final badges = <String>[
      if (diet.isVegan) 'Vegan' else if (diet.isVegetarian) 'Vegetarian',
      if (diet.isGlutenFree) 'Gluten-free',
      if (diet.isDairyFree) 'Dairy-free',
    ];

    return ChefCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            'Nutrition',
            subtitle: 'Per serving · estimated from ${report.coveredLines} of ${report.countedLines} ingredients',
            trailing: IconButton(
              tooltip: 'How this is estimated',
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          const SizedBox(height: 12),
          if (!report.hasData)
            Text('Add ingredient amounts to see an estimate.', style: t.bodyMedium?.copyWith(color: c.contentSecondary))
          else ...[
            KcalHero(calories: per.calories, style: t.displaySmall),
            const SizedBox(height: 12),
            MacroSplitBar(facts: per),
            const SizedBox(height: 12),
            MacroLegend(facts: per),
            const SizedBox(height: 14),
            NutrientFootnote(facts: per),
          ],
          if (badges.isNotEmpty || diet.allergens.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in badges)
                  Chip(
                    avatar: Icon(Icons.eco_outlined, size: 18, color: c.accentHerb),
                    label: Text(diet.isComplete ? b : '$b (likely)'),
                  ),
              ],
            ),
            if (diet.allergens.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: c.stateWarning),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Contains ${diet.allergens.join(', ')}', style: t.bodyMedium)),
                ],
              ),
            ],
          ],
          if (_expanded) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 8),
            for (final line in report.lines) _NutritionLineRow(line: line),
            const SizedBox(height: 8),
            Text(
              'Estimates use USDA FoodData Central reference values and typical kitchen conversions. '
              'They are approximate and not medical advice.',
              style: t.bodySmall,
            ),
          ],
          if (unresolved.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Not counted: ${unresolved.map((l) => l.ingredient.displayName).join(', ')}',
              style: t.bodySmall,
            ),
            if (aiReady)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _estimating ? null : _estimateWithAi,
                  icon: _estimating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(_estimating ? 'Estimating…' : 'Estimate the rest with AI'),
                ),
              ),
          ],
          if (report.hasData) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _logServing,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Log a serving'),
            ),
          ],
        ],
      ),
    );
  }
}

class _NutritionLineRow extends StatelessWidget {
  final IngredientNutritionLine line;
  const _NutritionLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final (IconData icon, Color color, String note) = switch (line.status) {
      NutritionLineStatus.matched => (Icons.check_rounded, c.stateSuccess, line.food!.name),
      NutritionLineStatus.override => (Icons.auto_awesome_rounded, c.accentHerb, 'AI estimate'),
      NutritionLineStatus.trace => (Icons.grain_rounded, c.contentSecondary, 'Negligible'),
      NutritionLineStatus.unquantified => (Icons.help_outline_rounded, c.stateWarning, 'Amount unclear'),
      NutritionLineStatus.unmatched => (Icons.help_outline_rounded, c.stateWarning, 'Not recognized'),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.ingredient.displayName, style: t.bodyMedium, overflow: TextOverflow.ellipsis),
                Text(
                  line.grams != null ? '$note · ${line.grams!.round()} g' : note,
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            line.facts.calories > 0 ? '${KitchenFormat.kcal(line.facts.calories)} kcal' : '—',
            style: ChefTypography.numeric(c.contentPrimary, size: 13, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
