import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/chef_toast_service.dart';
import '../../../../app/providers.dart';
import '../../../../app/widgets/recipe_image.dart';
import '../../../../core/media/image_prep.dart';
import '../../../../core/media/image_store.dart';
import '../../../../core/media/local_image_store.dart';
import '../../../../core/media/photo_picker.dart';
import '../../../../core/media/recipe_art.dart';

/// Result of the cover picker: a new image source, or [remove].
class CoverChoice {
  final String? source;
  const CoverChoice(this.source);
  static const remove = CoverChoice(null);
}

Future<CoverChoice?> showCoverPhotoSheet(BuildContext context, {required ScrapbookTheme theme}) {
  return showModalBottomSheet<CoverChoice>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _CoverSheet(theme: theme),
  );
}

class _CoverSheet extends ConsumerStatefulWidget {
  final ScrapbookTheme theme;
  const _CoverSheet({required this.theme});

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
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: _busy ? null : () => _pick(ImageSource.camera),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from photos'),
                onTap: _busy ? null : () => _pick(ImageSource.gallery),
              ),
            ],
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Use an image link'),
              onTap: _busy ? null : _link,
            ),
            const SizedBox(height: 8),
            Text('Illustrations', style: t.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: RecipeArt.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context, CoverChoice(RecipeArt.all[i])),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(width: 112, child: RecipeImage(source: RecipeArt.all[i], theme: widget.theme)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, CoverChoice.remove),
              icon: const Icon(Icons.hide_image_outlined),
              label: const Text('Remove cover'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Adds a recipe to cookbooks (or takes it out), or starts a new cookbook.
Future<void> showAddToCollectionSheet(BuildContext context, Recipe recipe) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _CollectionsSheet(recipe: recipe),
  );
}

class _CollectionsSheet extends ConsumerWidget {
  final Recipe recipe;
  const _CollectionsSheet({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final collections = ref.watch(collectionsStreamProvider).valueOrNull ?? const [];
    final repo = ref.read(collectionRepositoryProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('Add to a cookbook', style: t.headlineSmall),
            ),
            const SizedBox(height: 8),
            for (final col in collections)
              CheckboxListTile(
                value: col.recipeIds.contains(recipe.id),
                title: Text(col.name),
                subtitle: Text('${col.recipeIds.length} recipes'),
                onChanged: (checked) => checked == true
                    ? repo.addRecipeToCollection(col.id, recipe.id)
                    : repo.removeRecipeFromCollection(col.id, recipe.id),
              ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('New cookbook'),
              onTap: () async {
                final name = await showTextPromptDialog(context, title: 'New cookbook', hint: 'e.g. French');
                if (name == null || name.trim().isEmpty) return;
                final res = await repo.createCollection(profileId: 'default', name: name.trim(), colorToken: 'accent.herb');
                final created = res.orNull;
                if (created != null) await repo.addRecipeToCollection(created.id, recipe.id);
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
