import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:app_contracts/app_contracts.dart';
import '../../../app/providers.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final collectionsAsync = ref.watch(collectionsStreamProvider);

    return Scaffold(
      backgroundColor: colors.surfaceCanvas,
      appBar: AppBar(
        title: Text('Collections', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCollectionDialog(context, ref),
            tooltip: 'New Collection',
          ),
        ],
      ),
      body: collectionsAsync.when(
        data: (collections) {
          if (collections.isEmpty) {
            return EmptyStateScene(
              icon: Icons.folder_open_outlined,
              title: 'No collections yet',
              message: 'Organize your recipes into custom private collections for easy meal planning.',
              actionLabel: 'Create Collection',
              onAction: () => _showCreateCollectionDialog(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(ChefSpacing.space4),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final col = collections[index];
              final colAccent = _getColorFromToken(col.colorToken, colors);

              return Card(
                margin: const EdgeInsets.only(bottom: ChefSpacing.space3),
                color: colors.surfacePaper,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ChefRadius.card),
                  side: BorderSide(color: colors.outlineSubtle),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: ChefSpacing.space4,
                    vertical: ChefSpacing.space2,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.folder, color: colAccent, size: 24),
                  ),
                  title: Text(
                    col.name,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    col.description != null && col.description!.isNotEmpty
                        ? col.description!
                        : '${col.recipeIds.length} recipes',
                    style: textTheme.bodyMedium,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ref.read(recipeFilterProvider.notifier).state = RecipeFilter(collectionId: col.id);
                    context.go('/');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Color _getColorFromToken(String token, ChefColors colors) {
    if (token.contains('tomato')) return colors.accentTomato;
    if (token.contains('yolk')) return colors.accentYolk;
    return colors.accentHerb;
  }

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedColor = 'accent.herb';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('New Collection'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Collection Name', hintText: 'e.g. Weeknight Dinners'),
                ),
                const SizedBox(height: ChefSpacing.space3),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    ref.read(collectionRepositoryProvider).createCollection(
                          profileId: 'default',
                          name: name,
                          colorToken: selectedColor,
                          description: descController.text.trim(),
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}
