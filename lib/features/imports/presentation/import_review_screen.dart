import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../app/widgets/recipe_image.dart';

class ImportReviewScreen extends ConsumerStatefulWidget {
  final String jobId;
  const ImportReviewScreen({super.key, required this.jobId});

  @override
  ConsumerState<ImportReviewScreen> createState() => _ImportReviewScreenState();
}

class _ImportReviewScreenState extends ConsumerState<ImportReviewScreen> {
  final _title = TextEditingController();
  final _summary = TextEditingController();
  Recipe? _draft;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    super.dispose();
  }

  void _adopt(Recipe recipe) {
    if (_draft != null) return;
    _draft = recipe;
    _title.text = recipe.title;
    _summary.text = recipe.summary ?? '';
  }

  Future<void> _discard() async {
    final router = GoRouter.of(context);
    await ref.read(importRepositoryProvider).cancelJob(widget.jobId);
    router.canPop() ? router.pop() : router.go('/');
  }

  Future<void> _accept() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _saving = true);
    final router = GoRouter.of(context);
    var recipe = draft.copyWith(
      title: _title.text.trim().isEmpty ? 'Untitled recipe' : _title.text.trim(),
      summary: _summary.text.trim(),
    );
    final ready = const RecipeValidator().validateForReady(recipe.copyWith(status: RecipeStatus.ready)).isValid;
    recipe = recipe.copyWith(status: ready ? RecipeStatus.ready : RecipeStatus.draft);

    final res = await ref.read(importRepositoryProvider).acceptImportReview(jobId: widget.jobId, recipe: recipe);
    if (!mounted) return;
    setState(() => _saving = false);
    res.when(
      ok: (saved) {
        router.pushReplacement('/recipe/${saved.id}');
        ChefToastService.show(
          title: 'Recipe saved',
          description: ready ? saved.title : '${saved.title} · saved as a draft until it has a title, ingredients and steps',
          type: ChefToastType.success,
        );
      },
      err: (f) => ChefToastService.show(context: context, title: 'Could not save the recipe', description: f.message, type: ChefToastType.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(singleImportJobProvider(widget.jobId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review recipe'),
        leading: IconButton(tooltip: 'Discard', icon: const Icon(Icons.close_rounded), onPressed: _discard),
      ),
      body: jobAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => const ErrorView(message: 'This import could not be loaded.'),
        data: (job) {
          if (job == null) {
            return ErrorView(
              title: 'Import not found',
              message: 'It may have been discarded.',
              extraAction: FilledButton(onPressed: () => context.go('/'), child: const Text('Back to recipes')),
            );
          }
          switch (job.status) {
            case ImportStatus.queued:
            case ImportStatus.preprocessing:
            case ImportStatus.extracting:
              return LoadingView(message: _progressMessage(job.source.kind));
            case ImportStatus.failed:
              final needsAi = (job.failureReason ?? '').contains('AI');
              return ErrorView(
                title: 'Couldn’t import this recipe',
                message: job.failureReason ?? 'Something went wrong.',
                onRetry: () => context.pop(),
                extraAction: needsAi
                    ? FilledButton.tonal(onPressed: () => context.go('/settings?section=ai'), child: const Text('AI settings'))
                    : null,
              );
            case ImportStatus.reviewRequired:
            case ImportStatus.completed:
              final extracted = job.extractedDraft;
              if (extracted == null) return const ErrorView(message: 'No recipe was extracted.');
              _adopt(extracted);
              return _buildReview(context, job, _draft!);
          }
        },
      ),
    );
  }

  String _progressMessage(ImportSourceKind kind) => switch (kind) {
        ImportSourceKind.prompt => 'Writing your recipe…\nThis can take up to a minute.',
        ImportSourceKind.image => 'Reading the recipe in your photo…',
        ImportSourceKind.url => 'Fetching the page and finding the recipe…',
        _ => 'Organizing ingredients and steps…',
      };

  Widget _buildReview(BuildContext context, ImportJob job, Recipe draft) {
    final c = context.chefColors;
    final t = context.chefText;
    final confidence = job.overallConfidence;
    final (String level, Color color) = confidence >= 0.85
        ? ('High confidence', c.stateSuccess)
        : confidence >= 0.6
            ? ('Medium confidence', c.stateWarning)
            : ('Low confidence — please check carefully', c.stateDanger);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ChefRadius.tile),
                    child: SizedBox(height: 180, child: RecipeImage(source: draft.coverImage, theme: draft.theme)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 18, color: color),
                      const SizedBox(width: 6),
                      Expanded(child: Text('$level · ${_engineLabel(job)}', style: t.bodySmall)),
                    ],
                  ),
                  if (job.reviewQuestions.isNotEmpty || job.warnings.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ChefCard(
                      color: c.yolkSoft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Please check', style: t.titleSmall),
                          const SizedBox(height: 6),
                          for (final note in [...job.reviewQuestions, ...job.warnings])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(padding: EdgeInsets.only(top: 7), child: Icon(Icons.circle, size: 6)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(note, style: t.bodyMedium)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _summary,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Servings', style: t.labelLarge),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Fewer servings',
                        onPressed: draft.baseServings.toDouble() > 1
                            ? () => setState(() => _draft = draft.copyWith(baseServings: Rational(draft.baseServings.toDouble().round() - 1)))
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      Text(draft.baseServings.toDisplayString(), style: t.titleMedium),
                      IconButton(
                        tooltip: 'More servings',
                        onPressed: () => setState(() => _draft = draft.copyWith(baseServings: Rational(draft.baseServings.toDouble().round() + 1))),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionHeader('Ingredients', subtitle: '${draft.ingredients.length} found'),
                  const SizedBox(height: 4),
                  for (final ing in draft.ingredients)
                    _ReviewRow(
                      text: [
                        KitchenFormat.amount(ing.quantity, ing.unitCode, authored: ing.authoredQuantity) ?? '',
                        ing.displayName,
                        if (ing.prepText?.isNotEmpty ?? false) '· ${ing.prepText}',
                      ].where((s) => s.isNotEmpty).join(' '),
                      onRemove: () => setState(
                        () => _draft = draft.copyWith(ingredients: draft.ingredients.where((i) => i.id != ing.id).toList()),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SectionHeader('Steps', subtitle: '${draft.steps.length} found'),
                  const SizedBox(height: 4),
                  for (var i = 0; i < draft.steps.length; i++)
                    _ReviewRow(
                      leading: '${i + 1}.',
                      text: draft.steps[i].instructionShort,
                      detail: draft.steps[i].instructionDetail,
                      onRemove: () => setState(
                        () => _draft = draft.copyWith(steps: draft.steps.where((s) => s.id != draft.steps[i].id).toList()),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text('You can edit everything later from the recipe page.', style: t.bodySmall),
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
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Row(
                    children: [
                      OutlinedButton(onPressed: _saving ? null : _discard, child: const Text('Discard')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _accept,
                          icon: _saving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.check_rounded),
                          label: const Text('Save recipe'),
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

  String _engineLabel(ImportJob job) {
    if (job.source.kind == ImportSourceKind.prompt) return 'written by AI';
    if (job.source.kind == ImportSourceKind.image) return 'read from your photo by AI';
    return job.overallConfidence >= 0.95 ? 'from the page’s recipe data' : 'parsed from the text';
  }
}

class _ReviewRow extends StatelessWidget {
  final String? leading;
  final String text;
  final String? detail;
  final VoidCallback onRemove;
  const _ReviewRow({this.leading, required this.text, this.detail, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null)
          SizedBox(width: 28, child: Padding(padding: const EdgeInsets.only(top: 12), child: Text(leading!, style: t.labelLarge))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: t.bodyMedium),
                if (detail != null && detail!.isNotEmpty) Text(detail!, style: t.bodySmall),
              ],
            ),
          ),
        ),
        IconButton(tooltip: 'Remove', onPressed: onRemove, icon: const Icon(Icons.close_rounded, size: 20)),
      ],
    );
  }
}
