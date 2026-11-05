import 'dart:async';

import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/food_art.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../app/widgets/nutrition_widgets.dart';
import '../../../core/media/image_prep.dart';
import '../../../core/media/image_store.dart';
import '../../imports/presentation/import_flows.dart';
import 'scan_screen.dart';

class ScanAnalysisScreen extends ConsumerStatefulWidget {
  final ScanRequest? request;
  const ScanAnalysisScreen({super.key, required this.request});

  @override
  ConsumerState<ScanAnalysisScreen> createState() => _ScanAnalysisScreenState();
}

class _ScanAnalysisScreenState extends ConsumerState<ScanAnalysisScreen> {
  FoodAnalysis? _analysis;
  PreparedImage? _prepared;
  AppFailure? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.request != null) _run();
  }

  Future<void> _run() async {
    final request = widget.request!;
    setState(() {
      _loading = true;
      _error = null;
    });
    final service = ref.read(foodVisionServiceProvider);
    if (service == null) {
      setState(() {
        _loading = false;
        _error = const CapabilityUnavailableFailure(
          capability: 'ai',
          reason: 'not_configured',
          message: 'Food scanning needs AI, which is not set up yet.',
          recoveryAction: 'Add an API key in Settings → AI & Scanning.',
        );
      });
      return;
    }
    final prepared = await ImagePrep.prepare(request.bytes, maxEdge: 1568);
    if (prepared.isFailure) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = prepared.error;
        });
      }
      return;
    }
    final res = await service.analyze(request.mode, prepared.orNull!, hint: request.note);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _prepared = prepared.orNull;
      res.when(ok: (a) => _analysis = a, err: (f) => _error = f);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    if (request == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          title: 'Nothing to analyze',
          message: 'Take or choose a photo from the Scan tab.',
          extraAction: FilledButton(onPressed: () => context.go('/scan'), child: const Text('Open Scan')),
        ),
      );
    }

    final Widget body;
    if (_loading) {
      body = _AnalyzingView(request: request);
    } else if (_error != null) {
      final authProblem = _error is AuthenticationFailure || _error is CapabilityUnavailableFailure;
      body = ErrorView.failure(
        _error!,
        onRetry: authProblem ? null : _run,
        extraAction: authProblem
            ? FilledButton.tonal(
                onPressed: () => context.go('/settings?section=ai'),
                child: const Text('Open AI settings'),
              )
            : null,
      );
    } else if (!_analysis!.isFood) {
      body = _NotFoodView(request: request, analysis: _analysis!);
    } else if (request.mode == ScanMode.ingredients) {
      body = _IngredientsResult(request: request, analysis: _analysis!);
    } else {
      body = _MealResult(request: request, analysis: _analysis!, prepared: _prepared);
    }

    return Scaffold(
      appBar: AppBar(title: Text(request.mode == ScanMode.ingredients ? 'Your ingredients' : 'Meal analysis')),
      body: body,
    );
  }
}

class _Photo extends StatelessWidget {
  final ScanRequest request;
  final double maxHeight;
  const _Photo({required this.request, this.maxHeight = 260});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ChefRadius.tile),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SizedBox(
          width: double.infinity,
          child: Image.memory(request.bytes, fit: BoxFit.cover, semanticLabel: 'Your photo', gaplessPlayback: true),
        ),
      ),
    );
  }
}

class _AnalyzingView extends StatefulWidget {
  final ScanRequest request;
  const _AnalyzingView({required this.request});

  @override
  State<_AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<_AnalyzingView> {
  late final Timer _timer;
  int _phase = 0;

  List<String> get _phases => widget.request.mode == ScanMode.ingredients
      ? const ['Looking closely…', 'Identifying ingredients…', 'Thinking of dishes…']
      : const ['Looking closely…', 'Identifying the food…', 'Estimating portions…', 'Working out nutrition…'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) setState(() => _phase = (_phase + 1) % _phases.length);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Photo(request: widget.request, maxHeight: 300),
              const SizedBox(height: 24),
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: AnimatedSwitcher(
                  duration: ChefMotion.standard,
                  child: Text(_phases[_phase], key: ValueKey(_phase), style: t.titleMedium),
                ),
              ),
              const SizedBox(height: 6),
              Text('This usually takes 5–20 seconds.', style: t.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoodView extends StatelessWidget {
  final ScanRequest request;
  final FoodAnalysis analysis;
  const _NotFoodView({required this.request, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              _Photo(request: request),
              const SizedBox(height: 20),
              Text('We couldn’t find food in this photo', style: t.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(analysis.description, style: t.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('Try another photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _confidenceLabel(double c) => c >= 0.75 ? 'High confidence' : (c >= 0.5 ? 'Medium confidence' : 'Low confidence — check portions');

class _MealResult extends ConsumerStatefulWidget {
  final ScanRequest request;
  final FoodAnalysis analysis;
  final PreparedImage? prepared;
  const _MealResult({required this.request, required this.analysis, required this.prepared});

  @override
  ConsumerState<_MealResult> createState() => _MealResultState();
}

class _MealResultState extends ConsumerState<_MealResult> {
  double _portion = 1;
  final Set<int> _excluded = {};
  late MealSlot _slot = MealSlot.forTime(DateTime.now());
  bool _saving = false;
  bool _logged = false;

  NutritionFacts get _total => NutritionFacts.sum([
        for (var i = 0; i < widget.analysis.items.length; i++)
          if (!_excluded.contains(i)) widget.analysis.items[i].nutrition,
      ]).scale(_portion);

  Future<void> _log() async {
    setState(() => _saving = true);
    final repo = ref.read(foodLogRepositoryProvider);
    final images = ref.read(imageStoreProvider);
    final router = GoRouter.of(context);
    final id = const Uuid().v4();
    final prepared = widget.prepared;
    final imagePath = prepared == null
        ? null
        : await images.persist(prepared.bytes, folder: 'scans', fileName: '$id.${prepared.extension}');
    final now = DateTime.now();
    final kept = [
      for (var i = 0; i < widget.analysis.items.length; i++)
        if (!_excluded.contains(i)) widget.analysis.items[i],
    ];
    final entry = FoodLogEntry(
      id: id,
      dayKey: dayKeyFor(now),
      mealSlot: _slot,
      title: widget.analysis.title,
      source: FoodLogSource.scan,
      imagePath: imagePath,
      portionMultiplier: _portion,
      nutrition: _total,
      analysis: FoodAnalysis(
        mode: widget.analysis.mode,
        isFood: true,
        title: widget.analysis.title,
        description: widget.analysis.description,
        cuisine: widget.analysis.cuisine,
        confidence: widget.analysis.confidence,
        items: kept,
        allergens: widget.analysis.allergens,
        dietaryTags: widget.analysis.dietaryTags,
        healthNotes: widget.analysis.healthNotes,
      ),
      loggedAt: now.toUtc().millisecondsSinceEpoch,
    );
    final res = await repo.saveEntry(entry);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _logged = res.isSuccess;
    });
    ChefToastService.show(
      context: context,
      title: res.isSuccess ? 'Logged to ${_slot.label}' : 'Could not log this meal',
      description: res.isSuccess ? '${KitchenFormat.kcal(_total.calories)} kcal · ${widget.analysis.title}' : res.error?.message,
      type: res.isSuccess ? ChefToastType.success : ChefToastType.error,
      actionLabel: res.isSuccess ? 'View log' : null,
      onAction: res.isSuccess ? () => router.go('/log') : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final a = widget.analysis;
    final total = _total;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _Photo(request: widget.request),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: t.headlineSmall),
                            if (a.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(a.description, style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ExcludeSemantics(
                        child: renderCulinaryStampById(
                              FoodArt.stampFor([a.title, ...a.items.map((i) => i.name)]),
                              size: 58,
                              rotation: 6,
                            ) ??
                            const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 16, color: c.contentSecondary),
                      const SizedBox(width: 6),
                      Text(_confidenceLabel(a.confidence), style: t.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ChefCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        KcalHero(calories: total.calories),
                        Text('Estimated for the portion you ate', style: t.bodySmall),
                        const SizedBox(height: 14),
                        Text('Portion eaten', style: t.labelLarge),
                        const SizedBox(height: 8),
                        SegmentedButton<double>(
                          segments: const [
                            ButtonSegment(value: 0.5, label: Text('½')),
                            ButtonSegment(value: 0.75, label: Text('¾')),
                            ButtonSegment(value: 1, label: Text('All')),
                            ButtonSegment(value: 1.5, label: Text('1½')),
                            ButtonSegment(value: 2, label: Text('2×')),
                          ],
                          selected: {_portion},
                          showSelectedIcon: false,
                          onSelectionChanged: (s) => setState(() => _portion = s.first),
                        ),
                        const SizedBox(height: 16),
                        MacroSplitBar(facts: total),
                        const SizedBox(height: 12),
                        MacroLegend(facts: total),
                        const SizedBox(height: 14),
                        NutrientFootnote(facts: total),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ChefCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader('What we found', subtitle: 'Remove anything that isn’t right'),
                        const SizedBox(height: 8),
                        for (var i = 0; i < a.items.length; i++)
                          _ItemRow(
                            item: a.items[i],
                            portion: _portion,
                            excluded: _excluded.contains(i),
                            onToggle: () => setState(() => _excluded.contains(i) ? _excluded.remove(i) : _excluded.add(i)),
                          ),
                      ],
                    ),
                  ),
                  if (a.allergens.isNotEmpty || a.dietaryTags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ChefCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (a.allergens.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: c.stateWarning, size: 20),
                                const SizedBox(width: 8),
                                Text('May contain', style: t.titleSmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [for (final al in a.allergens) Chip(label: Text(allergenLabel(al)))],
                            ),
                          ],
                          if (a.dietaryTags.isNotEmpty) ...[
                            if (a.allergens.isNotEmpty) const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final tag in a.dietaryTags)
                                  Chip(avatar: Icon(Icons.eco_outlined, size: 18, color: c.accentHerb), label: Text(tag)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (a.healthNotes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ChefCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notes', style: t.titleSmall),
                          const SizedBox(height: 8),
                          for (final n in a.healthNotes)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.circle, size: 6, color: c.contentSecondary),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(n, style: t.bodyMedium)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (a.recipeIdeas.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Cook it at home', style: t.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final idea in a.recipeIdeas)
                          ActionChip(
                            avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
                            label: Text(idea),
                            onPressed: () => showAiStudioSheet(context, ref, initialPrompt: idea),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'AI estimates from a photo can be off by 20% or more. Not medical advice.',
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        Material(
          color: c.surfacePaper,
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: c.outlineSubtle))),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Row(
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<MealSlot>(
                          value: _slot,
                          borderRadius: BorderRadius.circular(14),
                          items: [for (final s in MealSlot.values) DropdownMenuItem(value: s, child: Text(s.label))],
                          onChanged: _logged ? null : (s) => setState(() => _slot = s ?? _slot),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _logged
                            ? OutlinedButton.icon(
                                onPressed: () => context.go('/log'),
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Logged · view food log'),
                              )
                            : FilledButton.icon(
                                onPressed: _saving || total.calories <= 0 ? null : _log,
                                icon: _saving
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.add_task_rounded),
                                label: const Text('Log meal'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final FoodItemEstimate item;
  final double portion;
  final bool excluded;
  final VoidCallback onToggle;
  const _ItemRow({required this.item, required this.portion, required this.excluded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final ink = excluded ? c.contentSecondary : c.contentPrimary;
    final deco = excluded ? TextDecoration.lineThrough : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: t.bodyLarge?.copyWith(color: ink, decoration: deco, fontWeight: FontWeight.w600)),
                Text(
                  [if (item.portion.isNotEmpty) item.portion, if (item.grams > 0) '~${(item.grams * portion).round()} g'].join(' · '),
                  style: t.bodySmall?.copyWith(decoration: deco),
                ),
              ],
            ),
          ),
          Text(
            '${KitchenFormat.kcal(item.nutrition.calories * portion)} kcal',
            style: ChefTypography.numeric(ink, size: 14, weight: FontWeight.w600).copyWith(decoration: deco),
          ),
          IconButton(
            tooltip: excluded ? 'Include ${item.name}' : 'Remove ${item.name}',
            onPressed: onToggle,
            icon: Icon(excluded ? Icons.undo_rounded : Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _IngredientsResult extends ConsumerStatefulWidget {
  final ScanRequest request;
  final FoodAnalysis analysis;
  const _IngredientsResult({required this.request, required this.analysis});

  @override
  ConsumerState<_IngredientsResult> createState() => _IngredientsResultState();
}

class _IngredientsResultState extends ConsumerState<_IngredientsResult> {
  late final Set<String> _selected = widget.analysis.detectedIngredients.toSet();

  static String _head(String name) {
    final words = FoodMatcher.normalizeWords(name);
    return words.isEmpty ? '' : words.last;
  }

  /// Library recipes ranked by how many of their (non-trivial) ingredients
  /// are among the selected ones.
  List<({Recipe recipe, int matched, int total})> _matches(List<Recipe> recipes) {
    final have = _selected.map(_head).where((h) => h.isNotEmpty).toSet();
    final out = <({Recipe recipe, int matched, int total})>[];
    for (final r in recipes) {
      final relevant = r.ingredients.where((i) => !(FoodMatcher.standard.match(i.displayName)?.isTrace ?? false)).toList();
      if (relevant.isEmpty) continue;
      final matched = relevant.where((i) => have.contains(_head(i.displayName))).length;
      if (matched > 0) out.add((recipe: r, matched: matched, total: relevant.length));
    }
    out.sort((a, b) {
      final byShare = (b.matched / b.total).compareTo(a.matched / a.total);
      return byShare != 0 ? byShare : b.matched.compareTo(a.matched);
    });
    return out.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final a = widget.analysis;
    final recipes = ref.watch(allRecipesProvider).valueOrNull ?? const [];
    final matches = _matches(recipes);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Photo(request: widget.request, maxHeight: 220),
            const SizedBox(height: 16),
            Text('Found ${a.detectedIngredients.length} ingredients', style: t.headlineSmall),
            Text('Tap to leave out anything you don’t want to use.', style: t.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ing in a.detectedIngredients)
                  FilterChip(
                    avatar: switch (FoodArt.doodleFor([ing])) {
                      final String id => FoodDoodle(id: id, size: 22),
                      null => null,
                    },
                    label: Text(ing),
                    selected: _selected.contains(ing),
                    onSelected: (v) => setState(() => v ? _selected.add(ing) : _selected.remove(ing)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader('From your cookbook', subtitle: matches.isEmpty ? 'No saved recipes use these yet' : null),
            const SizedBox(height: 8),
            for (final m in matches)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChefCard(
                  onTap: () => context.push('/recipe/${m.recipe.id}'),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.recipe.title, style: t.titleSmall),
                            const SizedBox(height: 6),
                            Meter(fraction: m.matched / m.total, color: c.accentHerb, height: 6),
                            const SizedBox(height: 4),
                            Text('Uses ${m.matched} of ${m.total} ingredients', style: t.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SectionHeader('Create something new', subtitle: 'AI writes a recipe around what you have'),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _selected.isEmpty
                  ? null
                  : () => showAiStudioSheet(
                        context,
                        ref,
                        initialPrompt: 'A recipe using mostly: ${_selected.join(', ')}. Common pantry staples are fine.',
                      ),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Create a recipe with these'),
            ),
            if (a.recipeIdeas.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final idea in a.recipeIdeas)
                    ActionChip(label: Text(idea), onPressed: () => showAiStudioSheet(context, ref, initialPrompt: idea)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
