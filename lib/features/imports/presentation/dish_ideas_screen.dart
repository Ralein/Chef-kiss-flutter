import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../services/ai_recipe_service.dart';
import 'import_flows.dart';

/// What can I cook? The ingredients on hand go in, the AI suggests dishes,
/// and one becomes a full recipe — reviewed before it's saved, and put into
/// a cookbook if one is picked.
class DishIdeasScreen extends ConsumerStatefulWidget {
  const DishIdeasScreen({super.key});

  @override
  ConsumerState<DishIdeasScreen> createState() => _DishIdeasScreenState();
}

class _DishIdeasScreenState extends ConsumerState<DishIdeasScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _ingredients = <String>[];
  String? _cookbookId;
  bool _thinking = false;
  List<DishIdea>? _ideas;
  AppFailure? _failure;

  /// Quick picks for what most kitchens have.
  static const _common = [
    'Eggs',
    'Rice',
    'Pasta',
    'Onion',
    'Garlic',
    'Tomatoes',
    'Potatoes',
    'Chicken',
    'Spinach',
    'Cheese',
    'Lemon',
    'Chickpeas',
  ];

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _has(String item) => _ingredients.any((i) => i.toLowerCase() == item.toLowerCase());

  /// Adds what was typed; commas separate several.
  void _add(String raw) {
    setState(() {
      for (final part in raw.split(',')) {
        final item = part.trim();
        if (item.isNotEmpty && !_has(item)) _ingredients.add(item);
      }
      _input.clear();
      _ideas = null;
      _failure = null;
    });
  }

  void _remove(String item) => setState(() {
    _ingredients.remove(item);
    _ideas = null;
  });

  Future<void> _suggest() async {
    final service = ref.read(aiRecipeServiceProvider);
    if (service == null) return;
    if (_input.text.trim().isNotEmpty) _add(_input.text);
    FocusScope.of(context).unfocus();
    setState(() {
      _thinking = true;
      _failure = null;
    });
    final res = await service.suggestDishes(List.of(_ingredients));
    if (!mounted) return;
    setState(() {
      _thinking = false;
      _ideas = res.orNull;
      _failure = res.isFailure ? res.error : null;
    });
  }

  Future<void> _make(DishIdea idea) =>
      startImport(context, ref, buildSource(ImportSourceKind.prompt, text: idea.request), cookbookId: _cookbookId);

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final aiReady = ref.watch(aiRecipeServiceProvider) != null;
    final books = ref.watch(collectionsStreamProvider).valueOrNull ?? const <RecipeCollection>[];
    final ideas = _ideas;

    return Scaffold(
      appBar: AppBar(title: const Text('Cook with what you have')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              if (!aiReady)
                const AiSetupCard(feature: 'dish ideas')
              else ...[
                Text('What’s in your kitchen?', style: t.titleMedium),
                const SizedBox(height: 4),
                Text('Oil, salt, spices and other staples are taken as given.', style: t.bodySmall),
                const SizedBox(height: 12),
                TextField(
                  controller: _input,
                  focusNode: _focus,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (v) {
                    _add(v);
                    _focus.requestFocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. eggs, spinach, feta',
                    prefixIcon: const Icon(LucideIcons.carrot, size: 20),
                    suffixIcon: IconButton(
                      tooltip: 'Add',
                      icon: const Icon(LucideIcons.plus, size: 20),
                      onPressed: () => _add(_input.text),
                    ),
                  ),
                ),
                if (_ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final i in _ingredients) InputChip(label: Text(i), onDeleted: () => _remove(i))],
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in _common)
                      if (!_has(item))
                        ActionChip(
                          avatar: const Icon(LucideIcons.plus, size: 14),
                          label: Text(item),
                          onPressed: () => _add(item),
                        ),
                  ],
                ),
                if (books.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String?>(
                    initialValue: _cookbookId,
                    decoration: const InputDecoration(labelText: 'Put the recipe in'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('No cookbook')),
                      for (final b in books) DropdownMenuItem(value: b.id, child: Text(b.name)),
                    ],
                    onChanged: (v) => setState(() => _cookbookId = v),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _ingredients.isEmpty && _input.text.trim().isEmpty || _thinking ? null : _suggest,
                  icon: const Icon(LucideIcons.sparkles, size: 18),
                  label: Text(ideas == null ? 'Suggest dishes' : 'Suggest others'),
                ),
                const SizedBox(height: 24),
                if (_thinking)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text('Thinking up dishes…', style: t.bodySmall),
                    ],
                  )
                else if (_failure case final failure?)
                  _FailureNote(failure: failure, onRetry: _suggest)
                else if (ideas != null) ...[
                  Semantics(header: true, child: Text('Ideas', style: t.titleMedium)),
                  const SizedBox(height: 8),
                  for (final idea in ideas) _IdeaCard(idea: idea, onMake: () => _make(idea)),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final DishIdea idea;
  final VoidCallback onMake;
  const _IdeaCard({required this.idea, required this.onMake});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    final meta = [
      if (idea.minutes > 0) KitchenFormat.minutes(idea.minutes),
      if (idea.uses.isNotEmpty) 'uses ${idea.uses.join(', ')}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ChefCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(idea.title, style: t.titleMedium),
            if (idea.summary.isNotEmpty) ...[const SizedBox(height: 4), Text(idea.summary, style: t.bodyMedium)],
            if (meta.isNotEmpty) ...[const SizedBox(height: 8), Text(meta, style: t.bodySmall)],
            if (idea.missing.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Also needs ${idea.missing.join(', ')}', style: t.bodySmall?.copyWith(color: c.stateWarning)),
            ],
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onMake,
              icon: const Icon(LucideIcons.chefHat, size: 18),
              label: const Text('Make this recipe'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureNote extends StatelessWidget {
  final AppFailure failure;
  final VoidCallback onRetry;
  const _FailureNote({required this.failure, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(failure.message, style: t.bodyMedium),
        if (failure.recoveryAction != null) ...[
          const SizedBox(height: 4),
          Text(failure.recoveryAction!, style: t.bodySmall),
        ],
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
