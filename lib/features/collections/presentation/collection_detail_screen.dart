import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/recipe_image.dart';
import '../../library/presentation/widgets/recipe_card.dart';
import 'collections_screen.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final String collectionId;
  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final collectionsAsync = ref.watch(collectionsStreamProvider);
    final recipes = ref.watch(allRecipesProvider).valueOrNull ?? const <Recipe>[];

    return collectionsAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(appBar: AppBar(), body: const ErrorView(message: 'This collection could not be loaded.')),
      data: (collections) {
        final col = collections.where((c) => c.id == collectionId).firstOrNull;
        if (col == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyStateScene(
              icon: Icons.collections_bookmark_outlined,
              title: 'Collection not found',
              message: 'It may have been deleted.',
              actionLabel: 'All collections',
              onAction: () => context.go('/collections'),
            ),
          );
        }
        final members = col.recipeIds.toSet();
        final inCollection = recipes.where((r) => members.contains(r.id)).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(col.name),
            actions: [
              IconButton(
                tooltip: 'Add or remove recipes',
                icon: const Icon(Icons.playlist_add_check_rounded),
                onPressed: () => _manage(context, ref, col, recipes),
              ),
              PopupMenuButton<String>(
                tooltip: 'Collection options',
                onSelected: (v) async {
                  if (v == 'rename') {
                    await CollectionActions.rename(context, ref, col);
                  } else if (await CollectionActions.delete(context, ref, col) && context.mounted) {
                    context.go('/collections');
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete collection')),
                ],
              ),
            ],
          ),
          body: inCollection.isEmpty
              ? EmptyStateScene(
                  icon: LucideIcons.folderPlus,
                  title: 'No recipes here yet',
                  message: 'Add recipes from your cookbook to this collection.',
                  actionLabel: 'Add recipes',
                  onAction: () => _manage(context, ref, col, recipes),
                )
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: Text('${inCollection.length} recipe${inCollection.length == 1 ? '' : 's'}', style: t.bodySmall),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: RecipeGrid(
                        recipes: inCollection,
                        onOpen: (r) => context.push('/recipe/${r.id}'),
                        onToggleFavorite: (r) => ref.read(recipeRepositoryProvider).toggleFavorite(r.id),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _manage(BuildContext context, WidgetRef ref, RecipeCollection col, List<Recipe> recipes) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _MembershipSheet(collectionId: col.id, recipes: recipes),
    );
  }
}

class _MembershipSheet extends ConsumerWidget {
  final String collectionId;
  final List<Recipe> recipes;
  const _MembershipSheet({required this.collectionId, required this.recipes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(collectionRepositoryProvider);
    final col = (ref.watch(collectionsStreamProvider).valueOrNull ?? const []).where((c) => c.id == collectionId).firstOrNull;
    final members = col?.recipeIds.toSet() ?? const <String>{};

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Recipes in ${col?.name ?? 'collection'}', style: context.chefText.headlineSmall),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemCount: recipes.length,
              itemBuilder: (context, i) {
                final r = recipes[i];
                final inIt = members.contains(r.id);
                return CheckboxListTile(
                  value: inIt,
                  secondary: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(width: 44, height: 44, child: RecipeImage(source: r.coverImage, theme: r.theme)),
                  ),
                  title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onChanged: (v) => v == true
                      ? repo.addRecipeToCollection(collectionId, r.id)
                      : repo.removeRecipeFromCollection(collectionId, r.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
