import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/recipe_image.dart';
import '../../../core/media/recipe_art.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart';

const _uuid = Uuid();

/// Parses "1½", "1 1/2", "¾", "1,5", "2" into a [Rational]; null if blank.
Rational? parseQuantity(String raw) {
  const glyphs = {'½': '1/2', '⅓': '1/3', '⅔': '2/3', '¼': '1/4', '¾': '3/4', '⅛': '1/8', '⅜': '3/8', '⅝': '5/8', '⅞': '7/8', '⅕': '1/5'};
  var s = raw.trim().replaceAll(',', '.');
  if (s.isEmpty) return null;
  glyphs.forEach((g, f) => s = s.replaceAllMapped(RegExp('(\\d)?$g'), (m) => m.group(1) == null ? f : '${m.group(1)} $f'));
  final r = Rational.tryParse(s.trim());
  return (r == null || r.isZero || r.isNegative) ? null : r;
}

class _IngredientDraft {
  final RecipeIngredient? original;
  final String key = _uuid.v4();
  final TextEditingController qty;
  final TextEditingController unit;
  final TextEditingController name;
  final TextEditingController prep;

  _IngredientDraft(this.original)
      : qty = TextEditingController(text: original?.quantity?.toDisplayString() ?? original?.authoredQuantity ?? ''),
        unit = TextEditingController(text: original?.unitCode ?? ''),
        name = TextEditingController(text: original?.displayName ?? ''),
        prep = TextEditingController(text: original?.prepText ?? '');

  void dispose() {
    qty.dispose();
    unit.dispose();
    name.dispose();
    prep.dispose();
  }

  RecipeIngredient? build(String recipeId, int position) {
    final displayName = name.text.trim();
    if (displayName.isEmpty) return null;
    final o = original;
    final quantity = parseQuantity(qty.text);
    final authored = quantity == null && qty.text.trim().isNotEmpty ? qty.text.trim() : null;
    return RecipeIngredient(
      id: o?.id ?? _uuid.v4(),
      recipeId: recipeId,
      catalogIngredientId: o?.catalogIngredientId,
      displayName: displayName,
      quantity: quantity,
      unitCode: unit.text.trim().isEmpty ? null : unit.text.trim(),
      authoredQuantity: authored,
      scalingPolicy: quantity == null ? ScalingPolicy.toTaste : (o?.scalingPolicy == ScalingPolicy.toTaste ? ScalingPolicy.scale : o?.scalingPolicy ?? ScalingPolicy.scale),
      prepText: prep.text.trim().isEmpty ? null : prep.text.trim(),
      isOptional: o?.isOptional ?? false,
      position: position,
      groupKey: o?.groupKey,
      allergenOverrideJson: o?.allergenOverrideJson,
      illustrationKey: o?.illustrationKey,
      icon: (o != null && o.displayName == displayName && o.icon != null) ? o.icon : RecipeArt.iconKeyFor(displayName),
      iconColor: o?.iconColor,
      x: o?.x,
      y: o?.y,
    );
  }
}

class _StepDraft {
  final RecipeStep? original;
  final String key = _uuid.v4();
  final TextEditingController instruction;
  final TextEditingController detail;
  final TextEditingController minutes;
  final TextEditingController temperature;

  _StepDraft(this.original)
      : instruction = TextEditingController(text: original?.instructionShort ?? ''),
        detail = TextEditingController(text: original?.instructionDetail ?? ''),
        minutes = TextEditingController(
          text: () {
            final secs = original?.timers.firstOrNull?.durationSeconds ?? original?.durationSeconds;
            return secs == null || secs <= 0 ? '' : (secs / 60).toStringAsFixed(secs % 60 == 0 ? 0 : 1);
          }(),
        ),
        temperature = TextEditingController(text: original?.temperatureC?.toString() ?? '');

  void dispose() {
    instruction.dispose();
    detail.dispose();
    minutes.dispose();
    temperature.dispose();
  }

  RecipeStep? build(String recipeId, int position) {
    final text = instruction.text.trim();
    if (text.isEmpty) return null;
    final o = original;
    final stepId = o?.id ?? _uuid.v4();
    final mins = double.tryParse(minutes.text.trim().replaceAll(',', '.'));
    final seconds = mins == null || mins <= 0 ? null : (mins * 60).round();
    final tempC = int.tryParse(temperature.text.trim());
    final existingTimer = o?.timers.firstOrNull;
    return RecipeStep(
      id: stepId,
      recipeId: recipeId,
      position: position,
      instructionShort: text,
      instructionDetail: detail.text.trim().isEmpty ? null : detail.text.trim(),
      spokenInstruction: o?.spokenInstruction,
      actionKey: o?.actionKey,
      iconKey: o?.iconKey,
      iconColor: o?.iconColor,
      cookwareKey: o?.cookwareKey,
      durationSeconds: seconds,
      temperatureC: tempC != null && tempC > 0 ? tempC : null,
      temperatureF: tempC != null && tempC > 0 ? (tempC * 9 / 5 + 32).round() : null,
      layoutHint: o?.layoutHint,
      safetyJson: o?.safetyJson,
      x: o?.x,
      y: o?.y,
      timers: [
        if (seconds != null)
          StepTimer(
            id: existingTimer?.id ?? _uuid.v4(),
            recipeStepId: stepId,
            label: existingTimer?.label ?? (o?.actionKey?.isNotEmpty == true ? o!.actionKey! : 'Step $position'),
            durationSeconds: seconds,
          ),
        ...?o?.timers.skip(1),
      ],
    );
  }
}

class RecipeEditorScreen extends ConsumerStatefulWidget {
  final String? recipeId;
  const RecipeEditorScreen({super.key, this.recipeId});

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  Recipe? _original;
  bool _loaded = false;
  bool _dirty = false;
  bool _saving = false;

  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _minutes = TextEditingController();
  final _tags = TextEditingController();
  final _cuisine = TextEditingController();
  int _servings = 2;
  RecipeDifficulty _difficulty = RecipeDifficulty.medium;
  ScrapbookTheme _theme = ScrapbookTheme.terracottaClassic;
  final List<_IngredientDraft> _ingredients = [];
  final List<_StepDraft> _steps = [];

  @override
  void initState() {
    super.initState();
    if (widget.recipeId == null) {
      _ingredients.add(_IngredientDraft(null));
      _steps.add(_StepDraft(null));
      _loaded = true;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final res = await ref.read(recipeRepositoryProvider).getRecipeById(widget.recipeId!);
    if (!mounted) return;
    final r = res.orNull;
    setState(() {
      _loaded = true;
      if (r == null) return;
      _original = r;
      _title.text = r.title;
      _summary.text = r.summary ?? '';
      _minutes.text = r.totalMinutes > 0 ? '${r.totalMinutes}' : '';
      _tags.text = r.labels.where((l) => l.kind == 'tag').map((l) => l.displayName).join(', ');
      _cuisine.text = r.labels.where((l) => l.kind == 'cuisine').map((l) => l.displayName).firstOrNull ?? '';
      _servings = math.max(1, r.baseServings.toDouble().round());
      _difficulty = r.difficulty;
      _theme = r.theme;
      _ingredients.addAll(r.ingredients.map(_IngredientDraft.new));
      _steps.addAll(r.steps.map(_StepDraft.new));
      if (_ingredients.isEmpty) _ingredients.add(_IngredientDraft(null));
      if (_steps.isEmpty) _steps.add(_StepDraft(null));
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _summary, _minutes, _tags, _cuisine]) {
      c.dispose();
    }
    for (final d in _ingredients) {
      d.dispose();
    }
    for (final d in _steps) {
      d.dispose();
    }
    super.dispose();
  }

  void _touch() {
    if (!_dirty) setState(() => _dirty = true);
  }

  List<RecipeLabel> _buildLabels(String recipeId) {
    RecipeLabel label(String kind, String name) {
      final key = name.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      return RecipeLabel(id: _uuid.v4(), recipeId: recipeId, labelId: '$kind:$key', kind: kind, canonicalKey: key, displayName: name.trim());
    }

    final kept = (_original?.labels ?? const <RecipeLabel>[]).where((l) => l.kind != 'tag' && l.kind != 'cuisine');
    final tags = _tags.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toSet();
    return [
      ...kept,
      if (_cuisine.text.trim().isNotEmpty) label('cuisine', _cuisine.text),
      for (final t in tags) label('tag', t),
    ];
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final router = GoRouter.of(context);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _original?.id ?? _uuid.v4();

    final ingredients = <RecipeIngredient>[];
    for (final d in _ingredients) {
      final built = d.build(id, ingredients.length + 1);
      if (built != null) ingredients.add(built);
    }
    final steps = <RecipeStep>[];
    for (final d in _steps) {
      final built = d.build(id, steps.length + 1);
      if (built != null) steps.add(built);
    }

    final title = _title.text.trim().isEmpty ? 'Untitled recipe' : _title.text.trim();
    final minutes = int.tryParse(_minutes.text.trim()) ?? 0;
    final timed = steps.fold<int>(0, (s, st) => s + (st.durationSeconds ?? 0)) ~/ 60;
    final base = _original ??
        Recipe(
          id: id,
          profileId: 'default',
          title: title,
          baseServings: Rational(_servings),
          origin: Origin.manual,
          createdAt: now,
          updatedAt: now,
        );
    var recipe = base.copyWith(
      title: title,
      summary: _summary.text.trim(),
      baseServings: Rational(_servings),
      difficulty: _difficulty,
      totalMinutes: minutes > 0 ? minutes : timed,
      theme: _theme,
      polaroidCaption: base.polaroidCaption ?? title,
      ingredients: ingredients,
      steps: steps,
      labels: _buildLabels(id),
      origin: _original == null ? Origin.manual : (_original!.origin == Origin.manual ? Origin.manual : Origin.userEdited),
    );
    final validation = const RecipeValidator().validateForReady(recipe.copyWith(status: RecipeStatus.ready));
    recipe = recipe.copyWith(status: validation.isValid ? RecipeStatus.ready : RecipeStatus.draft);

    final res = await ref.read(recipeRepositoryProvider).saveRecipe(recipe);
    if (!mounted) return;
    setState(() => _saving = false);
    res.when(
      ok: (saved) {
        _dirty = false;
        ChefToastService.show(
          title: validation.isValid ? 'Recipe saved' : 'Saved as a draft',
          description: validation.isValid ? null : validation.blockingErrors.map((e) => e.message).join(' '),
          type: ChefToastType.success,
        );
        if (_original == null) {
          router.pushReplacement('/recipe/${saved.id}');
        } else {
          router.pop();
        }
      },
      err: (f) => ChefToastService.show(context: context, title: 'Could not save', description: f.message, type: ChefToastType.error),
    );
  }

  Future<void> _pasteList() async {
    final text = await showTextPromptDialog(
      context,
      title: 'Paste ingredients',
      hint: 'One per line, e.g.\n2 cups flour\n1 tsp salt',
      maxLines: 8,
      confirmLabel: 'Add',
    );
    if (text == null || text.trim().isEmpty) return;
    final normalizer = RecipeNormalizer(idGenerator: _uuid.v4);
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    setState(() {
      // Drop a single empty placeholder row before appending.
      if (_ingredients.length == 1 && _ingredients.first.name.text.trim().isEmpty) {
        _ingredients.removeAt(0).dispose();
      }
      for (final line in lines) {
        final ing = normalizer.normalizeIngredient(line, recipeId: _original?.id ?? 'new', position: _ingredients.length + 1);
        _ingredients.add(_IngredientDraft(ing.copyWith(id: _uuid.v4())));
      }
      _dirty = true;
    });
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits to this recipe haven’t been saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    if (!_loaded) return const Scaffold(body: LoadingView());
    if (widget.recipeId != null && _original == null) {
      return Scaffold(appBar: AppBar(), body: const ErrorView(title: 'Recipe not found', message: 'It may have been deleted.'));
    }

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard() && mounted) {
          setState(() => _dirty = false);
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_original == null ? 'New recipe' : 'Edit recipe'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
              children: [
                _Card(
                  title: 'Basics',
                  children: [
                    TextField(
                      controller: _title,
                      onChanged: (_) => _touch(),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Grandma’s rosemary focaccia'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _summary,
                      onChanged: (_) => _touch(),
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Short description (optional)'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minutes,
                            onChanged: (_) => _touch(),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: 'Total time', suffixText: 'min'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Serves', style: t.labelLarge),
                        IconButton(
                          tooltip: 'Fewer servings',
                          onPressed: _servings > 1 ? () => setState(() {
                                _servings--;
                                _dirty = true;
                              }) : null,
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        Text('$_servings', style: t.titleMedium),
                        IconButton(
                          tooltip: 'More servings',
                          onPressed: () => setState(() {
                            _servings++;
                            _dirty = true;
                          }),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<RecipeDifficulty>(
                      segments: const [
                        ButtonSegment(value: RecipeDifficulty.easy, label: Text('Easy')),
                        ButtonSegment(value: RecipeDifficulty.medium, label: Text('Medium')),
                        ButtonSegment(value: RecipeDifficulty.hard, label: Text('Challenging')),
                      ],
                      selected: {_difficulty},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) => setState(() {
                        _difficulty = s.first;
                        _dirty = true;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(
                  title: 'Ingredients',
                  trailing: TextButton.icon(onPressed: _pasteList, icon: const Icon(Icons.content_paste_rounded, size: 18), label: const Text('Paste list')),
                  children: [
                    for (var i = 0; i < _ingredients.length; i++)
                      _IngredientRow(
                        key: ValueKey(_ingredients[i].key),
                        draft: _ingredients[i],
                        onChanged: _touch,
                        onRemove: _ingredients.length > 1
                            ? () => setState(() {
                                  _ingredients.removeAt(i).dispose();
                                  _dirty = true;
                                })
                            : null,
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _ingredients.add(_IngredientDraft(null))),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add ingredient'),
                      ),
                    ),
                    Text('Amounts like 1½, 1 1/2 or 0.5 all work. Leave the amount empty for “to taste”.', style: t.bodySmall),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(
                  title: 'Method',
                  children: [
                    for (var i = 0; i < _steps.length; i++)
                      _StepRow(
                        key: ValueKey(_steps[i].key),
                        number: i + 1,
                        draft: _steps[i],
                        onChanged: _touch,
                        onMoveUp: i > 0
                            ? () => setState(() {
                                  _steps.insert(i - 1, _steps.removeAt(i));
                                  _dirty = true;
                                })
                            : null,
                        onRemove: _steps.length > 1
                            ? () => setState(() {
                                  _steps.removeAt(i).dispose();
                                  _dirty = true;
                                })
                            : null,
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _steps.add(_StepDraft(null))),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add step'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(
                  title: 'Details',
                  children: [
                    TextField(
                      controller: _cuisine,
                      onChanged: (_) => _touch(),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Cuisine (optional)', hintText: 'e.g. Italian'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tags,
                      onChanged: (_) => _touch(),
                      decoration: const InputDecoration(labelText: 'Tags (optional)', hintText: 'dinner, vegetarian, make-ahead'),
                    ),
                    const SizedBox(height: 16),
                    Text('Page theme', style: t.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final th in ScrapbookTheme.values)
                          ChoiceChip(
                            avatar: CircleAvatar(backgroundColor: th.accent(context.chefColors), radius: 8),
                            label: Text(th.label),
                            selected: _theme == th,
                            onSelected: (_) => setState(() {
                              _theme = th;
                              _dirty = true;
                            }),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  const _Card({required this.title, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) => ChefCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title, trailing: trailing),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );
}

class _IngredientRow extends StatelessWidget {
  final _IngredientDraft draft;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;
  const _IngredientRow({super.key, required this.draft, required this.onChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: TextField(
              controller: draft.qty,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(labelText: 'Qty'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 76,
            child: TextField(
              controller: draft.unit,
              onChanged: (_) => onChanged(),
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: draft.name,
                  onChanged: (_) => onChanged(),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Ingredient'),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: draft.prep,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(labelText: 'Prep (optional)', hintText: 'finely chopped', isDense: true),
                ),
              ],
            ),
          ),
          IconButton(tooltip: 'Remove ingredient', onPressed: onRemove, icon: const Icon(Icons.delete_outline_rounded)),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final _StepDraft draft;
  final VoidCallback onChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onRemove;
  const _StepRow({super.key, required this.number, required this.draft, required this.onChanged, required this.onMoveUp, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(ChefRadius.tile)),
      child: Column(
        children: [
          Row(
            children: [
              Text('Step $number', style: context.chefText.labelLarge),
              const Spacer(),
              IconButton(tooltip: 'Move up', onPressed: onMoveUp, icon: const Icon(Icons.arrow_upward_rounded, size: 20)),
              IconButton(tooltip: 'Remove step', onPressed: onRemove, icon: const Icon(Icons.delete_outline_rounded, size: 20)),
            ],
          ),
          TextField(
            controller: draft.instruction,
            onChanged: (_) => onChanged(),
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Instruction', hintText: 'e.g. Sauté the garlic in olive oil until golden.'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: draft.detail,
            onChanged: (_) => onChanged(),
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Tips for this step (optional)'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: draft.minutes,
                  onChanged: (_) => onChanged(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Timer', suffixText: 'min', prefixIcon: Icon(Icons.timer_outlined)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: draft.temperature,
                  onChanged: (_) => onChanged(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Heat', suffixText: '°C', prefixIcon: Icon(Icons.thermostat_rounded)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
