import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../core/ai/ai_connection.dart';
import '../../../core/media/photo_picker.dart';

/// Creates an import job and opens its review screen. With [cookbookId],
/// the recipe goes into that cookbook once it is saved.
///
/// [context] and [ref] must belong to a long-lived widget (a screen), not a
/// sheet that is closing: both are captured before the first await.
Future<void> startImport(BuildContext context, WidgetRef ref, ImportSource source, {String? cookbookId}) async {
  final router = GoRouter.of(context);
  final repo = ref.read(importRepositoryProvider);
  final res = await repo.createJob(profileId: 'default', source: source);
  res.when(
    ok: (job) => router.push(
      Uri(path: '/import/review/${job.id}', queryParameters: cookbookId == null ? null : {'cookbook': cookbookId}).toString(),
    ),
    err: (f) => ChefToastService.show(title: f.message, type: ChefToastType.error),
  );
}

ImportSource buildSource(ImportSourceKind kind, {String? text, String? url, Uint8List? bytes, String? mediaType}) {
  final payload = bytes ?? utf8.encode(text ?? url ?? '');
  return ImportSource(
    id: const Uuid().v4(),
    kind: kind,
    rawText: text,
    sourceUrl: url,
    inlineData: bytes,
    mediaType: mediaType,
    sha256Checksum: sha256.convert(payload).toString(),
    byteSize: payload.length,
    createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
  );
}

/// Photo of a cookbook page or handwritten card → AI transcription.
Future<void> importRecipePhoto(BuildContext context, WidgetRef ref, ImageSource source) async {
  if (ref.read(aiConnectionProvider).valueOrNull?.isAvailable != true) {
    await showAiRequiredSheet(context, feature: 'recipe photo import');
    return;
  }
  final picked = await PhotoPicker.pick(source);
  if (!context.mounted) return;
  if (picked.isFailure) {
    ChefToastService.show(context: context, title: picked.error!.message, description: picked.error!.recoveryAction, type: ChefToastType.error);
    return;
  }
  final bytes = picked.orNull;
  if (bytes == null) return;
  await startImport(context, ref, buildSource(ImportSourceKind.image, bytes: bytes));
}

Future<void> showAiRequiredSheet(BuildContext context, {required String feature}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: AiSetupCard(feature: feature),
    ),
  );
}

enum _AddChoice { ai, photo, url, text, manual }

/// Entry point for every way of adding a recipe. The sheet only returns the
/// user's choice; the follow-up runs on the caller's (still mounted) context.
Future<void> showAddRecipeSheet(BuildContext context, WidgetRef ref) async {
  final choice = await showModalBottomSheet<_AddChoice>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _AddRecipeSheet(),
  );
  if (choice == null || !context.mounted) return;
  switch (choice) {
    case _AddChoice.ai:
      await showAiStudioSheet(context, ref);
    case _AddChoice.photo:
      final source = PhotoPicker.cameraAvailable ? await _chooseSource(context) : ImageSource.gallery;
      if (source != null && context.mounted) await importRecipePhoto(context, ref, source);
    case _AddChoice.url:
      await showUrlImportSheet(context, ref);
    case _AddChoice.text:
      await showPasteTextSheet(context, ref);
    case _AddChoice.manual:
      context.push('/editor');
  }
}

class _AddRecipeSheet extends ConsumerWidget {
  const _AddRecipeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    final t = context.chefText;
    final aiReady = ref.watch(aiConnectionProvider).valueOrNull?.isAvailable == true;

    Widget option({
      required IconData icon,
      required Color tint,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      bool needsAi = false,
    }) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: c.meterTrack(tint), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: tint),
        ),
        title: Text(title),
        subtitle: Text(
          needsAi && !aiReady ? '$subtitle · needs AI setup' : subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: onTap,
      );
    }

    void choose(_AddChoice choice) => Navigator.of(context).pop(choice);

    // Scrolls rather than spilling off a short screen or large text.
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Add a recipe', style: t.titleLarge),
          ),
          option(
            icon: LucideIcons.chefHat,
            tint: c.accentTomato,
            title: 'Create with AI',
            subtitle: 'Describe a dish, get the whole recipe',
            needsAi: true,
            onTap: () => choose(_AddChoice.ai),
          ),
          option(
            icon: LucideIcons.scanText,
            tint: c.accentHerb,
            title: 'Scan a recipe',
            subtitle: 'A cookbook page or handwritten card',
            needsAi: true,
            onTap: () => choose(_AddChoice.photo),
          ),
          option(
            icon: LucideIcons.link,
            tint: c.accentYolk,
            title: 'Import from a website',
            subtitle: 'Paste a link to any recipe page',
            onTap: () => choose(_AddChoice.url),
          ),
          option(
            icon: LucideIcons.clipboardPaste,
            tint: c.macroCarbs,
            title: 'Paste recipe text',
            subtitle: 'From notes, messages or email',
            onTap: () => choose(_AddChoice.text),
          ),
          option(
            icon: LucideIcons.notebookPen,
            tint: c.contentSecondary,
            title: 'Write it myself',
            subtitle: 'Start from a blank recipe',
            onTap: () => choose(_AddChoice.manual),
          ),
          const SizedBox(height: 12),
        ],
        ),
      ),
    );
  }
}

Future<ImageSource?> _chooseSource(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.camera),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(LucideIcons.images),
            title: const Text('Choose from photos'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<void> showUrlImportSheet(BuildContext context, WidgetRef ref) async {
  final source = await showModalBottomSheet<ImportSource>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _TextEntrySheet(
      title: 'Import from a website',
      hint: 'https://…',
      helper: 'Most recipe sites publish structured recipe data, which is read exactly. '
          'For other pages, AI reads the page text.',
      kind: ImportSourceKind.url,
      keyboardType: TextInputType.url,
      maxLines: 1,
    ),
  );
  if (source != null && context.mounted) await startImport(context, ref, source);
}

Future<void> showPasteTextSheet(BuildContext context, WidgetRef ref) async {
  final source = await showModalBottomSheet<ImportSource>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _TextEntrySheet(
      title: 'Paste recipe text',
      hint: 'Paste the title, ingredients and steps…',
      helper: 'Works offline. With AI set up, messy text is cleaned up more accurately.',
      kind: ImportSourceKind.text,
      keyboardType: TextInputType.multiline,
      maxLines: 12,
    ),
  );
  if (source != null && context.mounted) await startImport(context, ref, source);
}

class _TextEntrySheet extends StatefulWidget {
  final String title;
  final String hint;
  final String helper;
  final ImportSourceKind kind;
  final TextInputType keyboardType;
  final int maxLines;

  const _TextEntrySheet({
    required this.title,
    required this.hint,
    required this.helper,
    required this.kind,
    required this.keyboardType,
    required this.maxLines,
  });

  @override
  State<_TextEntrySheet> createState() => _TextEntrySheetState();
}

class _TextEntrySheetState extends State<_TextEntrySheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (widget.kind == ImportSourceKind.url) {
      final uri = Uri.tryParse(value);
      if (uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
        setState(() => _error = 'Enter a full web address, starting with https://');
        return;
      }
    } else if (value.length < 20) {
      setState(() => _error = 'Paste the whole recipe, including ingredients and steps.');
      return;
    }
    Navigator.of(context).pop(
      widget.kind == ImportSourceKind.url
          ? buildSource(ImportSourceKind.url, url: value)
          : buildSource(ImportSourceKind.text, text: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: t.headlineSmall),
          const SizedBox(height: 6),
          Text(widget.helper, style: t.bodySmall),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: widget.keyboardType,
            minLines: widget.maxLines > 1 ? 6 : 1,
            maxLines: widget.maxLines,
            textInputAction: widget.maxLines == 1 ? TextInputAction.go : TextInputAction.newline,
            onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
            decoration: InputDecoration(hintText: widget.hint, errorText: _error),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _submit, icon: const Icon(LucideIcons.download), label: const Text('Import')),
        ],
      ),
    );
  }
}

/// Real AI recipe generation (replaces the former keyword-matching mock).
Future<void> showAiStudioSheet(BuildContext context, WidgetRef ref, {String? initialPrompt}) async {
  final prompt = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AiStudioSheet(initialPrompt: initialPrompt),
  );
  if (prompt != null && prompt.isNotEmpty && context.mounted) {
    await startImport(context, ref, buildSource(ImportSourceKind.prompt, text: prompt));
  }
}

class _AiStudioSheet extends ConsumerStatefulWidget {
  final String? initialPrompt;
  const _AiStudioSheet({this.initialPrompt});

  @override
  ConsumerState<_AiStudioSheet> createState() => _AiStudioSheetState();
}

class _AiStudioSheetState extends ConsumerState<_AiStudioSheet> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialPrompt);

  /// A few dishes to start from: a short name on the chip, a fuller ask
  /// behind it.
  static const _ideas = [
    ('Chow mein', 'Chicken chow mein for 2, ready in 25 minutes'),
    ('Butter chicken', 'Butter chicken with basmati rice for 4'),
    ('Carbonara', 'Classic spaghetti carbonara for 2, no cream'),
    ('Shakshuka', 'Shakshuka with feta for a weekend brunch'),
    ('Pad thai', 'Prawn pad thai for 2'),
    ('Banana bread', 'Moist banana bread with walnuts'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    final prompt = _controller.text.trim();
    if (prompt.isNotEmpty) Navigator.of(context).pop(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final ai = ref.watch(aiConnectionProvider).valueOrNull;

    // Scrolls rather than spilling over when the keyboard is up.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create with AI', style: t.titleLarge),
          const SizedBox(height: 4),
          Text('Name a dish or describe what you’d like. You’ll check the recipe before it’s saved.', style: t.bodySmall),
          const SizedBox(height: 16),
          if (ai?.isAvailable != true) ...[
            const AiSetupCard(feature: 'recipe generation'),
          ] else ...[
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. Mushroom risotto for 4, no wine'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            Text('Ideas', style: t.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _ideas.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ActionChip(
                  label: Text(_ideas[i].$1),
                  onPressed: () => setState(() {
                    _controller.text = _ideas[i].$2;
                    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _controller.text.trim().isEmpty ? null : _generate,
              icon: const Icon(LucideIcons.chefHat),
              label: const Text('Create recipe'),
            ),
          ],
        ],
      ),
    );
  }
}
