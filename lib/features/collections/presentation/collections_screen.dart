import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/recipe_image.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart';

/// Shared create/rename/delete actions for collections.
class CollectionActions {
  CollectionActions._();

  static Future<void> create(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(collectionRepositoryProvider);
    final name = await showTextPromptDialog(context, title: 'New cookbook', hint: 'e.g. French', confirmLabel: 'Create');
    if (name == null || name.trim().isEmpty) return;
    final res = await repo.createCollection(profileId: 'default', name: name.trim(), colorToken: 'accent.herb');
    if (res.isFailure) ChefToastService.show(title: 'Could not create the cookbook', type: ChefToastType.error);
  }

  static Future<void> rename(BuildContext context, WidgetRef ref, RecipeCollection col) async {
    final repo = ref.read(collectionRepositoryProvider);
    final name = await showTextPromptDialog(context, title: 'Rename cookbook', initial: col.name);
    if (name == null || name.trim().isEmpty || name.trim() == col.name) return;
    await repo.updateCollection(col.copyWith(name: name.trim()));
  }

  static Future<bool> delete(BuildContext context, WidgetRef ref, RecipeCollection col) async {
    final repo = ref.read(collectionRepositoryProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete cookbook?'),
        content: Text('“${col.name}” comes off the shelf. Its recipes go back to My Recipes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return false;
    await repo.deleteCollection(col.id);
    return true;
  }
}

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final collectionsAsync = ref.watch(collectionsStreamProvider);
    final recipes = ref.watch(allRecipesProvider).valueOrNull ?? const <Recipe>[];
    final byId = {for (final r in recipes) r.id: r};

    // One way to create a collection at a time: the empty screen has its own
    // button, so the floating one only appears once there is a list.
    final hasCollections = collectionsAsync.valueOrNull?.isNotEmpty ?? false;
    return Scaffold(
      floatingActionButton: hasCollections
          ? FloatingActionButton.extended(
              heroTag: 'collections-fab',
              onPressed: () => CollectionActions.create(context, ref),
              icon: const Icon(LucideIcons.folderPlus),
              label: const Text('New cookbook'),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: collectionsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(message: 'Cookbooks could not be loaded.', onRetry: () => ref.invalidate(collectionsStreamProvider)),
          data: (collections) {
            if (collections.isEmpty) {
              return EmptyStateScene(
                icon: LucideIcons.bookHeart,
                title: 'No cookbooks yet',
                message: 'Gather recipes into books, like French or Weeknight dinners. They stand on your shelf, and a recipe can live in several.',
                actionLabel: 'Create a cookbook',
                onAction: () => CollectionActions.create(context, ref),
              );
            }
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  sliver: SliverToBoxAdapter(child: Semantics(header: true, child: Text('Cookbooks', style: t.headlineMedium))),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 340,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 236,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      childCount: collections.length,
                      (context, i) {
                        final col = collections[i];
                        final live = col.recipeIds.map((id) => byId[id]).whereType<Recipe>().toList();
                        return _CollectionTile(collection: col, covers: live.take(3).toList(), count: live.length);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CollectionTile extends ConsumerWidget {
  final RecipeCollection collection;
  final List<Recipe> covers;
  final int count;
  const _CollectionTile({required this.collection, required this.covers, required this.count});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    final t = context.chefText;

    return Semantics(
      button: true,
      label: '${collection.name}, $count recipes',
      excludeSemantics: true,
      child: ChefCard(
        padding: EdgeInsets.zero,
        onTap: () => context.go('/collections/${collection.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: covers.isEmpty
                  ? ColoredBox(
                      color: c.herbSoft,
                      child: Icon(Icons.collections_bookmark_outlined, size: 40, color: c.accentHerb),
                    )
                  : Row(
                      children: [
                        for (var i = 0; i < covers.length; i++) ...[
                          if (i > 0) const SizedBox(width: 2),
                          Expanded(child: RecipeImage(source: covers[i].coverImage, theme: covers[i].theme)),
                        ],
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(collection.name, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('$count recipe${count == 1 ? '' : 's'}', style: t.bodySmall),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Cookbook options',
                    onSelected: (v) => v == 'rename'
                        ? CollectionActions.rename(context, ref, collection)
                        : CollectionActions.delete(context, ref, collection),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
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
