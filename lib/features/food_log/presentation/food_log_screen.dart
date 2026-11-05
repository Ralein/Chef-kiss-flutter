import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../app/widgets/nutrition_widgets.dart';
import '../../../app/widgets/recipe_image.dart';
import '../../../core/media/local_image_store.dart';
import '../../nutrition/presentation/recipe_insights.dart';

class FoodLogScreen extends ConsumerStatefulWidget {
  final String? initialDayKey;
  const FoodLogScreen({super.key, this.initialDayKey});

  @override
  ConsumerState<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends ConsumerState<FoodLogScreen> {
  late String _dayKey = widget.initialDayKey ?? dayKeyFor(DateTime.now());

  /// Entries swiped away but not yet gone from the stream. A dismissed
  /// Dismissible must leave the tree immediately, so hide them optimistically.
  final Set<String> _pendingDeletes = {};

  String get _todayKey => dayKeyFor(DateTime.now());

  void _shiftDay(int days) {
    final next = dateForDayKey(_dayKey).add(Duration(days: days));
    if (next.isAfter(DateTime.now())) return;
    setState(() => _dayKey = dayKeyFor(next));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateForDayKey(_dayKey),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dayKey = dayKeyFor(picked));
  }

  /// Chart window: the last 7 days, unless an older day is selected.
  String get _chartEndKey {
    final selected = dateForDayKey(_dayKey);
    final today = dateForDayKey(_todayKey);
    return today.difference(selected).inDays <= 6 ? _todayKey : _dayKey;
  }

  String _dayLabel(String key) {
    if (key == _todayKey) return 'Today';
    final yesterday = dayKeyFor(DateTime.now().subtract(const Duration(days: 1)));
    if (key == yesterday) return 'Yesterday';
    return DateFormat.MMMEd().format(dateForDayKey(key));
  }

  Future<void> _delete(FoodLogEntry e) async {
    setState(() => _pendingDeletes.add(e.id));
    final repo = ref.read(foodLogRepositoryProvider);
    final res = await repo.deleteEntry(e.id);
    if (!mounted) return;
    if (res.isFailure) {
      setState(() => _pendingDeletes.remove(e.id));
      ChefToastService.show(context: context, title: 'Could not remove ${e.title}', type: ChefToastType.error);
      return;
    }
    ChefToastService.show(
      context: context,
      title: 'Removed ${e.title}',
      actionLabel: 'Undo',
      onAction: () async {
        await repo.saveEntry(e);
        if (mounted) setState(() => _pendingDeletes.remove(e.id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final goals = ref.watch(nutritionGoalsProvider).valueOrNull ?? NutritionGoals.standard;
    final entriesAsync = ref.watch(foodLogDayProvider(_dayKey));
    final week = ref.watch(foodLogWeekProvider(_chartEndKey)).valueOrNull ?? const [];
    final isToday = _dayKey == _todayKey;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'log-fab',
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add food'),
      ),
      body: SafeArea(
        bottom: false,
        child: entriesAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(
            message: 'Your food log could not be loaded.',
            onRetry: () => ref.invalidate(foodLogDayProvider(_dayKey)),
          ),
          data: (allEntries) {
            final entries = allEntries.where((e) => !_pendingDeletes.contains(e.id)).toList();
            final total = NutritionFacts.sum(entries.map((e) => e.nutrition));
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    Row(
                      children: [
                        Expanded(child: Semantics(header: true, child: Text('Food log', style: t.headlineMedium))),
                        IconButton(tooltip: 'Previous day', onPressed: () => _shiftDay(-1), icon: const Icon(Icons.chevron_left_rounded)),
                        TextButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(_dayLabel(_dayKey)),
                        ),
                        IconButton(
                          tooltip: 'Next day',
                          onPressed: isToday ? null : () => _shiftDay(1),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ChefCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CalorieSummary(
                            consumed: total.calories,
                            goal: goals.calories,
                            caption: isToday ? 'eaten today' : 'eaten ${_dayLabel(_dayKey).toLowerCase() == 'yesterday' ? 'yesterday' : 'on ${_dayLabel(_dayKey)}'}',
                          ),
                          const SizedBox(height: 20),
                          MacroMeterRow(label: 'Protein', grams: total.proteinG, goalGrams: goals.proteinG, color: c.macroProtein),
                          const SizedBox(height: 14),
                          MacroMeterRow(label: 'Carbs', grams: total.carbsG, goalGrams: goals.carbsG, color: c.macroCarbs),
                          const SizedBox(height: 14),
                          MacroMeterRow(label: 'Fat', grams: total.fatG, goalGrams: goals.fatG, color: c.macroFat),
                          const SizedBox(height: 18),
                          NutrientFootnote(facts: total),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ChefCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader('Calories', subtitle: 'Last 7 days · tap a day to open it'),
                          const SizedBox(height: 16),
                          WeeklyCaloriesChart(
                            summaries: week,
                            endDayKey: _chartEndKey,
                            goal: goals.calories,
                            selectedDayKey: _dayKey,
                            onSelectDay: (key) => setState(() => _dayKey = key),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.restaurant_rounded, size: 40, color: c.contentSecondary),
                            const SizedBox(height: 10),
                            Text(isToday ? 'Nothing logged yet today' : 'Nothing logged this day', style: t.titleMedium),
                            const SizedBox(height: 4),
                            Text('Scan a meal or log a serving from one of your recipes.', style: t.bodySmall, textAlign: TextAlign.center),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: () => context.go('/scan'),
                              icon: const Icon(Icons.photo_camera_rounded),
                              label: const Text('Scan a meal'),
                            ),
                          ],
                        ),
                      )
                    else
                      for (final slot in MealSlot.values) ..._slotSection(context, slot, entries.where((e) => e.mealSlot == slot).toList()),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _slotSection(BuildContext context, MealSlot slot, List<FoodLogEntry> entries) {
    if (entries.isEmpty) return const [];
    final kcal = entries.fold<double>(0, (s, e) => s + e.nutrition.calories);
    return [
      SectionHeader(slot.label, subtitle: '${KitchenFormat.kcal(kcal)} kcal'),
      const SizedBox(height: 8),
      for (final e in entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Dismissible(
            key: ValueKey(e.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(color: context.chefColors.dangerSoft, borderRadius: BorderRadius.circular(ChefRadius.tile)),
              child: Icon(Icons.delete_outline_rounded, color: context.chefColors.stateDanger),
            ),
            onDismissed: (_) => _delete(e),
            child: _EntryTile(entry: e, onTap: () => _showEntrySheet(context, e)),
          ),
        ),
      const SizedBox(height: 12),
    ];
  }

  Future<void> _showEntrySheet(BuildContext context, FoodLogEntry entry) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _EntrySheet(entry: entry, onDelete: () => _delete(entry)),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Scan a meal'),
              subtitle: const Text('Photo → calories and macros'),
              onTap: () => Navigator.pop(ctx, 'scan'),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Log a recipe'),
              subtitle: const Text('A serving of something you cooked'),
              onTap: () => Navigator.pop(ctx, 'recipe'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Quick add'),
              subtitle: const Text('Enter calories yourself'),
              onTap: () => Navigator.pop(ctx, 'quick'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    switch (choice) {
      case 'scan':
        context.go('/scan');
      case 'recipe':
        await _logRecipe(context);
      case 'quick':
        await _quickAdd(context);
    }
  }

  DateTime get _loggedTime {
    final now = DateTime.now();
    if (_dayKey == _todayKey) return now;
    final d = dateForDayKey(_dayKey);
    return DateTime(d.year, d.month, d.day, 12);
  }

  Future<void> _save(FoodLogEntry entry) async {
    final res = await ref.read(foodLogRepositoryProvider).saveEntry(entry);
    if (!mounted) return;
    ChefToastService.show(
      context: context,
      title: res.isSuccess ? 'Logged to ${entry.mealSlot.label}' : 'Could not save',
      description: res.isSuccess ? '${KitchenFormat.kcal(entry.nutrition.calories)} kcal · ${entry.title}' : res.error?.message,
      type: res.isSuccess ? ChefToastType.success : ChefToastType.error,
    );
  }

  Future<void> _logRecipe(BuildContext context) async {
    final recipe = await showModalBottomSheet<Recipe>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const _RecipePickerSheet(),
    );
    if (recipe == null || !mounted) return;
    final report = RecipeInsights.of(recipe);
    final when = _loggedTime;
    await _save(FoodLogEntry(
      id: const Uuid().v4(),
      dayKey: _dayKey,
      mealSlot: MealSlot.forTime(when),
      title: recipe.title,
      source: FoodLogSource.recipe,
      recipeId: recipe.id,
      imagePath: recipe.coverImage,
      nutrition: report.perServing,
      loggedAt: when.toUtc().millisecondsSinceEpoch,
    ));
  }

  Future<void> _quickAdd(BuildContext context) async {
    final result = await showDialog<_QuickAddResult>(context: context, builder: (_) => const _QuickAddDialog());
    if (result == null || !mounted) return;
    final when = _loggedTime;
    await _save(FoodLogEntry(
      id: const Uuid().v4(),
      dayKey: _dayKey,
      mealSlot: result.slot,
      title: result.name,
      source: FoodLogSource.manual,
      nutrition: result.facts,
      loggedAt: when.toUtc().millisecondsSinceEpoch,
    ));
  }
}

class _EntryTile extends StatelessWidget {
  final FoodLogEntry entry;
  final VoidCallback onTap;
  const _EntryTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final n = entry.nutrition;
    return ChefCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: RecipeImage(source: entry.imagePath, placeholderIcon: Icons.restaurant_rounded),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  'P ${n.proteinG.round()} g · C ${n.carbsG.round()} g · F ${n.fatG.round()} g'
                  '${entry.portionMultiplier != 1 ? ' · ×${entry.portionMultiplier}' : ''}',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
          Text('${KitchenFormat.kcal(n.calories)} kcal', style: ChefTypography.numeric(context.chefColors.contentPrimary, size: 15)),
        ],
      ),
    );
  }
}

class _EntrySheet extends ConsumerStatefulWidget {
  final FoodLogEntry entry;
  final VoidCallback onDelete;
  const _EntrySheet({required this.entry, required this.onDelete});

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  late double _portion = widget.entry.portionMultiplier;
  late MealSlot _slot = widget.entry.mealSlot;

  NutritionFacts get _base => widget.entry.nutrition.scale(1 / (widget.entry.portionMultiplier <= 0 ? 1 : widget.entry.portionMultiplier));

  Future<void> _save() async {
    final repo = ref.read(foodLogRepositoryProvider);
    final navigator = Navigator.of(context);
    await repo.saveEntry(widget.entry.copyWith(
      portionMultiplier: _portion,
      mealSlot: _slot,
      nutrition: _base.scale(_portion),
    ));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final e = widget.entry;
    final facts = _base.scale(_portion);
    const portions = [0.5, 0.75, 1.0, 1.5, 2.0];
    final selected = portions.contains(_portion) ? _portion : 1.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (e.imagePath != null && (supportsLocalImages || !e.imagePath!.startsWith('/')))
              ClipRRect(
                borderRadius: BorderRadius.circular(ChefRadius.tile),
                child: SizedBox(height: 180, child: RecipeImage(source: e.imagePath)),
              ),
            const SizedBox(height: 12),
            Text(e.title, style: t.headlineSmall),
            Text(DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(e.loggedAt).toLocal()), style: t.bodySmall),
            const SizedBox(height: 16),
            KcalHero(calories: facts.calories, style: t.displaySmall),
            const SizedBox(height: 12),
            MacroSplitBar(facts: facts),
            const SizedBox(height: 10),
            MacroLegend(facts: facts),
            const SizedBox(height: 16),
            Text('Portion', style: t.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 0.5, label: Text('½')),
                ButtonSegment(value: 0.75, label: Text('¾')),
                ButtonSegment(value: 1.0, label: Text('1×')),
                ButtonSegment(value: 1.5, label: Text('1½')),
                ButtonSegment(value: 2.0, label: Text('2×')),
              ],
              selected: {selected},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _portion = s.first),
            ),
            const SizedBox(height: 16),
            Text('Meal', style: t.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in MealSlot.values)
                  ChoiceChip(label: Text(s.label), selected: _slot == s, onSelected: (_) => setState(() => _slot = s)),
              ],
            ),
            if (e.analysis != null && e.analysis!.items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Items', style: t.labelLarge),
              const SizedBox(height: 4),
              for (final item in e.analysis!.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.name, style: t.bodyMedium)),
                      Text('${KitchenFormat.kcal(item.nutrition.calories * _portion)} kcal', style: t.bodySmall),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete();
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
                const Spacer(),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipePickerSheet extends ConsumerStatefulWidget {
  const _RecipePickerSheet();

  @override
  ConsumerState<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends ConsumerState<_RecipePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final recipes = (ref.watch(allRecipesProvider).valueOrNull ?? const <Recipe>[])
        .where((r) => _query.isEmpty || r.title.toLowerCase().contains(_query))
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Log a recipe serving', style: t.headlineSmall),
                const SizedBox(height: 12),
                TextField(
                  autofocus: false,
                  decoration: const InputDecoration(hintText: 'Search recipes', prefixIcon: Icon(Icons.search_rounded)),
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemCount: recipes.length,
              itemBuilder: (context, i) {
                final r = recipes[i];
                final kcal = RecipeInsights.kcalPerServing(r);
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(width: 48, height: 48, child: RecipeImage(source: r.coverImage, theme: r.theme)),
                  ),
                  title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(kcal == null ? 'Nutrition estimate incomplete' : '${kcal.round()} kcal per serving'),
                  enabled: kcal != null,
                  onTap: () => Navigator.pop(context, r),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddResult {
  final String name;
  final MealSlot slot;
  final NutritionFacts facts;
  const _QuickAddResult(this.name, this.slot, this.facts);
}

class _QuickAddDialog extends StatefulWidget {
  const _QuickAddDialog();

  @override
  State<_QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<_QuickAddDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  MealSlot _slot = MealSlot.forTime(DateTime.now());

  @override
  void dispose() {
    for (final c in [_name, _kcal, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.').trim()) ?? 0;

  Widget _numberField(TextEditingController c, String label, {bool required = false}) => TextFormField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) {
                final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                return d == null || d <= 0 || d > 10000 ? 'Enter calories (1–10,000)' : null;
              }
            : null,
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick add'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'What did you eat?'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Give it a name' : null,
              ),
              const SizedBox(height: 10),
              _numberField(_kcal, 'Calories (kcal)', required: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numberField(_protein, 'Protein g')),
                  const SizedBox(width: 8),
                  Expanded(child: _numberField(_carbs, 'Carbs g')),
                  const SizedBox(width: 8),
                  Expanded(child: _numberField(_fat, 'Fat g')),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MealSlot>(
                initialValue: _slot,
                decoration: const InputDecoration(labelText: 'Meal'),
                items: [for (final s in MealSlot.values) DropdownMenuItem(value: s, child: Text(s.label))],
                onChanged: (s) => setState(() => _slot = s ?? _slot),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!(_form.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              _QuickAddResult(
                _name.text.trim(),
                _slot,
                NutritionFacts(calories: _num(_kcal), proteinG: _num(_protein), carbsG: _num(_carbs), fatG: _num(_fat)),
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
