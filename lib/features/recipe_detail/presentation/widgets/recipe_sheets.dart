import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/chef_toast_service.dart';
import '../../../../app/providers.dart';
import '../../../../core/media/image_prep.dart';
import '../../../../core/media/image_store.dart';
import '../../../../core/media/local_image_store.dart';
import '../../../../core/media/photo_picker.dart';
import '../../../library/domain/book_covers.dart';

/// Result of the cover picker: a new image source, or [remove].
class CoverChoice {
  final String? source;
  const CoverChoice(this.source);
  static const remove = CoverChoice(null);
}

Future<CoverChoice?> showCoverPhotoSheet(BuildContext context) {
  return showModalBottomSheet<CoverChoice>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _CoverSheet(),
  );
}

class _CoverSheet extends ConsumerStatefulWidget {
  const _CoverSheet();

  @override
  ConsumerState<_CoverSheet> createState() => _CoverSheetState();
}

class _CoverSheetState extends ConsumerState<_CoverSheet> {
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    final images = ref.read(imageStoreProvider);
    final picked = await PhotoPicker.pick(source, maxEdge: 1600, quality: 85);
    if (!mounted) return;
    if (picked.isFailure) {
      setState(() => _busy = false);
      ChefToastService.show(context: context, title: picked.error!.message, type: ChefToastType.error);
      return;
    }
    final bytes = picked.orNull;
    if (bytes == null) {
      setState(() => _busy = false);
      return;
    }
    final prepared = await ImagePrep.prepare(bytes, maxEdge: 1600);
    final image = prepared.orNull;
    final path = image == null
        ? null
        : await images.persist(image.bytes, folder: 'covers', fileName: '${const Uuid().v4()}.${image.extension}');
    if (!mounted) return;
    if (path == null) {
      setState(() => _busy = false);
      ChefToastService.show(context: context, title: 'That photo could not be saved', type: ChefToastType.error);
      return;
    }
    Navigator.pop(context, CoverChoice(path));
  }

  Future<void> _link() async {
    final url = await showTextPromptDialog(
      context,
      title: 'Image link',
      hint: 'https://…',
      keyboardType: TextInputType.url,
      validator: (v) {
        final uri = Uri.tryParse(v.trim());
        return uri != null && (uri.isScheme('https') || uri.isScheme('http')) && uri.host.isNotEmpty
            ? null
            : 'Enter a full image address';
      },
    );
    if (url != null && mounted) Navigator.pop(context, CoverChoice(url.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cover photo', style: t.headlineSmall),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            if (supportsLocalImages) ...[
              if (PhotoPicker.cameraAvailable)
                ListTile(
                  leading: const Icon(LucideIcons.camera),
                  title: const Text('Take a photo'),
                  onTap: _busy ? null : () => _pick(ImageSource.camera),
                ),
              ListTile(
                leading: const Icon(LucideIcons.images),
                title: const Text('Choose from photos'),
                onTap: _busy ? null : () => _pick(ImageSource.gallery),
              ),
            ],
            ListTile(
              leading: const Icon(LucideIcons.link),
              title: const Text('Use an image link'),
              onTap: _busy ? null : _link,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, CoverChoice.remove),
              icon: const Icon(LucideIcons.imageOff),
              label: const Text('Remove cover'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Adds a recipe to cookbooks (or takes it out), or starts a new cookbook.
/// Moves [recipe] to another book — My Recipes, one of your cookbooks, or a
/// new one. A recipe is in one book at a time.
Future<void> showMoveToBookSheet(BuildContext context, Recipe recipe) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MoveToBookSheet(recipe: recipe),
  );
}

/// Asks for a name and makes a new, empty book.
Future<RecipeCollection?> createBook(BuildContext context, WidgetRef ref) async {
  final name = await showTextPromptDialog(context, title: 'New book', hint: 'e.g. French', confirmLabel: 'Create');
  if (name == null || name.trim().isEmpty) return null;
  final res = await ref
      .read(collectionRepositoryProvider)
      .createCollection(profileId: 'default', name: name.trim(), colorToken: 'accent.herb');
  return res.orNull;
}

class _MoveToBookSheet extends ConsumerWidget {
  final Recipe recipe;
  const _MoveToBookSheet({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final c = context.chefColors;
    final books = ref.watch(collectionsStreamProvider).valueOrNull ?? const <RecipeCollection>[];
    final covers = ref.watch(bookCoversProvider).valueOrNull ?? const <String, BookCover>{};
    final current = bookOf(books, recipe.id);

    Future<void> moveTo(String bookId) async {
      final navigator = Navigator.of(context);
      final name = bookName(bookId, books, covers);
      if (bookId != current) {
        await moveRecipeToBook(ref.read(collectionRepositoryProvider), books, recipe.id, bookId);
      }
      navigator.pop();
      if (bookId != current) {
        // The sheet is gone: the app's own messenger shows it.
        ChefToastService.show(
          title: 'Moved to $name',
          description: recipe.title,
          type: ChefToastType.success,
          duration: const Duration(seconds: 2),
        );
      }
    }

    Widget tile(String bookId, String name, String count) => ListTile(
      leading: Icon(bookId == myRecipesId ? LucideIcons.bookHeart : LucideIcons.book),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(count),
      trailing: bookId == current ? Icon(LucideIcons.check, color: c.accentTomato) : null,
      selected: bookId == current,
      onTap: () => moveTo(bookId),
    );

    String count(int n) => n == 1 ? '1 recipe' : '$n recipes';
    final filed = {for (final b in books) ...b.recipeIds};
    final all = ref.watch(allRecipesProvider).valueOrNull ?? const <Recipe>[];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
              child: Text('Move to a book', style: t.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(recipe.title, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            tile(
              myRecipesId,
              bookName(myRecipesId, books, covers),
              count(all.where((r) => !filed.contains(r.id)).length),
            ),
            for (final b in books) tile(b.id, b.name, count(b.recipeIds.length)),
            ListTile(
              leading: const Icon(LucideIcons.bookPlus),
              title: const Text('New book'),
              onTap: () async {
                final created = await createBook(context, ref);
                if (created != null && context.mounted) {
                  await moveRecipeToBook(ref.read(collectionRepositoryProvider), books, recipe.id, created.id);
                  if (context.mounted) Navigator.of(context).pop();
                  ChefToastService.show(
                    title: 'Moved to ${created.name}',
                    description: recipe.title,
                    type: ChefToastType.success,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Single-field text dialog that owns (and disposes) its controller.
Future<String?> showTextPromptDialog(
  BuildContext context, {
  required String title,
  String? initial,
  String? hint,
  String confirmLabel = 'Save',
  int maxLines = 1,
  TextInputType? keyboardType,
  String? Function(String value)? validator,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextPromptDialog(
      title: title,
      initial: initial,
      hint: hint,
      confirmLabel: confirmLabel,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    ),
  );
}

class _TextPromptDialog extends StatefulWidget {
  final String title;
  final String? initial;
  final String? hint;
  final String confirmLabel;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String value)? validator;

  const _TextPromptDialog({
    required this.title,
    this.initial,
    this.hint,
    required this.confirmLabel,
    required this.maxLines,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.validator?.call(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
        decoration: InputDecoration(hintText: widget.hint, errorText: _error),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
