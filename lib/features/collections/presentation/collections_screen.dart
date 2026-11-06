import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../library/domain/book_covers.dart';
import '../../library/domain/cookbook.dart';
import '../../library/presentation/widgets/library_books.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart';

/// Shared create/rename/delete actions for collections.
class CollectionActions {
  CollectionActions._();

  static Future<void> create(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(collectionRepositoryProvider);
    final name = await showTextPromptDialog(context, title: 'New book', hint: 'e.g. French', confirmLabel: 'Create');
    if (name == null || name.trim().isEmpty) return;
    final res = await repo.createCollection(profileId: 'default', name: name.trim(), colorToken: 'accent.herb');
    if (res.isFailure) ChefToastService.show(title: 'Could not create the book', type: ChefToastType.error);
  }

  static Future<void> rename(BuildContext context, WidgetRef ref, RecipeCollection col) async {
    final repo = ref.read(collectionRepositoryProvider);
    final name = await showTextPromptDialog(context, title: 'Rename book', initial: col.name);
    if (name == null || name.trim().isEmpty || name.trim() == col.name) return;
    await repo.updateCollection(col.copyWith(name: name.trim()));
  }

  static Future<bool> delete(BuildContext context, WidgetRef ref, RecipeCollection col) async {
    final repo = ref.read(collectionRepositoryProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('“${col.name}” comes off the shelf. Its recipes go back to My Recipes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return false;
    await repo.deleteCollection(col.id);
    await forgetBookCover(ref.read(preferencesRepositoryProvider), col.id);
    return true;
  }
}

/// Every book, cover-out, two to a row: My Recipes and your cookbooks. A
/// book opens in the Cookbook view; its menu edits, renames or deletes it.
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final collectionsAsync = ref.watch(collectionsStreamProvider);
    final recipes = ref.watch(allRecipesProvider).valueOrNull ?? const <Recipe>[];
    final covers = ref.watch(bookCoversProvider).valueOrNull ?? const <String, BookCover>{};
    final ids = {for (final r in recipes) r.id};

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: collectionsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(message: 'Books could not be loaded.', onRetry: () => ref.invalidate(collectionsStreamProvider)),
          data: (collections) {
            final loose = unfiledRecipes(recipes, collections).length;
            final books = [
              if (loose > 0 || collections.isEmpty) Cookbook.myRecipes(recipes: loose, cover: covers[myRecipesId]),
              for (final b in collections)
                Cookbook.volume(b, recipes: b.recipeIds.where(ids.contains).length, cover: covers[b.id]),
            ];
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          Expanded(child: Semantics(header: true, child: Text('Books', style: t.headlineMedium))),
                          FilledButton.tonalIcon(
                            onPressed: () => CollectionActions.create(context, ref),
                            icon: const Icon(LucideIcons.bookPlus, size: 18),
                            label: const Text('New book'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 20,
                      // A cover (5:7) and two lines under it.
                      childAspectRatio: 0.56,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      childCount: books.length,
                      (context, i) => _BookTile(
                        volume: books[i],
                        collection: collections
                            .where((c) => c.id == Cookbook.collectionIdOf(books[i]))
                            .firstOrNull,
                      ),
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

class _BookTile extends ConsumerWidget {
  final Recipe volume;

  /// The cookbook it is; null for My Recipes.
  final RecipeCollection? collection;
  const _BookTile({required this.volume, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final bookId = Cookbook.collectionIdOf(volume);
    void open() => context.go('/?view=journal&book=${Uri.encodeComponent(bookId)}');

    return Semantics(
      button: true,
      label: '${volume.title}, ${volume.summary}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: open,
        onLongPress: () => context.push('/book/$bookId'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(2), right: Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(2, 4)),
                  ],
                ),
                child: BookCoverFace(recipe: volume),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(volume.title, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(volume.summary ?? '', style: t.bodySmall),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Book options',
                  icon: const Icon(LucideIcons.ellipsisVertical, size: 18),
                  padding: EdgeInsets.zero,
                  onSelected: (v) => switch (v) {
                    'edit' => context.push('/book/$bookId'),
                    'rename' => CollectionActions.rename(context, ref, collection!),
                    _ => CollectionActions.delete(context, ref, collection!),
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit book')),
                    if (collection != null) ...[
                      const PopupMenuItem(value: 'rename', child: Text('Rename')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
