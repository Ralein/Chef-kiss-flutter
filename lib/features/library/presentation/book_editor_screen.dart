import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../app/widgets/recipe_image.dart';
import '../../journal/application/recipe_edits.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart';
import '../domain/shelf_style.dart';
import 'widgets/library_books.dart';
import 'widgets/shelf_art.dart';
import 'widgets/spine_from_photo.dart';

/// How a recipe stands in the library: its title, cover photo, whether it
/// shows its spine or its cover, and the spine's cloth, lettering, size and
/// pattern — previewed on a shelf. A new cover photo binds the spine to match.
class BookEditorScreen extends ConsumerStatefulWidget {
  final String recipeId;
  const BookEditorScreen({super.key, required this.recipeId});

  @override
  ConsumerState<BookEditorScreen> createState() => _BookEditorScreenState();
}

class _BookEditorScreenState extends ConsumerState<BookEditorScreen> {
  final _title = TextEditingController();
  Recipe? _original;
  BookStyle _style = const BookStyle();
  ScrapbookTheme _theme = ScrapbookTheme.terracottaClassic;
  String? _cover;
  bool _saving = false;

  /// True once the spine was made from a newly added photo.
  bool _spineFromPhoto = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _load(Recipe r) {
    if (_original != null) return;
    _original = r;
    _style = r.bookStyle;
    _theme = r.theme;
    _cover = r.coverImage;
    _title.text = r.title;
  }

  Recipe get _draft => _original!.copyWith(
    title: _title.text.trim().isEmpty ? _original!.title : _title.text.trim(),
    bookStyle: _style,
    theme: _theme,
    coverImage: _cover,
    clearCoverImage: _cover == null,
  );

  bool get _dirty {
    final o = _original;
    if (o == null) return false;
    return _title.text.trim() != o.title || _style != o.bookStyle || _theme != o.theme || _cover != o.coverImage;
  }

  void _restyle(BookStyle style) => setState(() => _style = style);

  Future<void> _save() async {
    final o = _original;
    if (o == null || _saving) return;
    setState(() => _saving = true);
    final draft = _draft;
    final res = await ref
        .read(recipeEditQueueProvider)
        .apply(
          o,
          (r) => r.copyWith(
            title: draft.title,
            bookStyle: draft.bookStyle,
            theme: draft.theme,
            coverImage: draft.coverImage,
            clearCoverImage: draft.coverImage == null,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (res.isFailure) {
      ChefToastService.show(context: context, title: 'Could not save the book', type: ChefToastType.error);
      return;
    }
    context.pop();
  }

  /// A new photo becomes the spine too: a strip of it, edged in its colour.
  Future<void> _changeCover() async {
    final choice = await showCoverPhotoSheet(context, theme: _theme);
    if (choice == null || !mounted) return;
    final source = choice.source;
    setState(() {
      _cover = source;
      if (source == null && _style.pattern == SpinePattern.photo) {
        _style = _style.copyWith(pattern: SpinePattern.bands, clearSpineColor: _spineFromPhoto);
        _spineFromPhoto = false;
      }
    });
    if (source == null) return;
    final cloth = await clothFromPhoto(source);
    if (!mounted || _cover != source) return;
    setState(() {
      _style = _style.copyWith(pattern: SpinePattern.photo, spineColor: cloth == null ? null : colorToHex(cloth));
      _spineFromPhoto = true;
    });
  }

  Future<bool> _confirmDiscard() async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('Your edits to this book haven’t been saved.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfStyleProvider).valueOrNull ?? const ShelfStyle();
    final async = ref.watch(singleRecipeProvider(widget.recipeId));
    final recipe = async.valueOrNull;
    if (recipe != null) _load(recipe);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard() && mounted) {
          setState(() => _original = null);
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit book'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: _saving || _original == null ? null : _save,
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ),
          ],
        ),
        body: _original == null
            ? (async.hasError ? const ErrorView(message: 'This recipe could not be loaded.') : const LoadingView())
            : _body(context, shelf),
      ),
    );
  }

  Widget _body(BuildContext context, ShelfStyle shelf) {
    final c = context.chefColors;
    final t = context.chefText;
    final draft = _draft;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _Preview(recipe: draft, shelf: shelf),
            const SizedBox(height: 20),
            TextField(
              controller: _title,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 6),
            Text(
              '${KitchenFormat.minutes(draft.totalMinutes)} · serves ${draft.baseServings.toDisplayString()} · '
              '${draft.ingredients.length} ingredients',
              style: t.bodySmall,
            ),
            const SizedBox(height: 24),
            _Section(
              label: 'Cover photo',
              hint: _cover == null
                  ? 'Add a photo and the spine is made from it too.'
                  : _spineFromPhoto
                  ? 'The spine now matches your photo.'
                  : null,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 52,
                      height: 68,
                      child: RecipeImage(source: _cover, theme: _theme),
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton.icon(
                    onPressed: _changeCover,
                    icon: const Icon(LucideIcons.imagePlus, size: 18),
                    label: Text(_cover == null ? 'Add photo' : 'Change photo'),
                  ),
                ],
              ),
            ),
            _Section(
              label: 'On the shelf',
              hint: 'Automatic stands one favorite per shelf face-out.',
              child: _segments<BookDisplay>(
                values: BookDisplay.values,
                selected: _style.display,
                label: (d) => d.label,
                onPick: (d) => _restyle(_style.copyWith(display: d)),
              ),
            ),
            _Section(
              label: 'Spine',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _segments<SpinePattern>(
                    values: [
                      for (final p in SpinePattern.values)
                        if (p != SpinePattern.photo || _cover != null) p,
                    ],
                    selected: _style.pattern,
                    label: (p) => switch (p) {
                      SpinePattern.plain => 'Plain',
                      SpinePattern.bands => 'Bands',
                      SpinePattern.ribs => 'Ribs',
                      SpinePattern.photo => 'Photo',
                    },
                    onPick: (p) => _restyle(_style.copyWith(pattern: p)),
                  ),
                  const SizedBox(height: 14),
                  _swatches(
                    selected: _style.spineColor,
                    auto: 'Theme colour',
                    options: spineCloths,
                    onPick: (hex) => _restyle(
                      hex == null ? _style.copyWith(clearSpineColor: true) : _style.copyWith(spineColor: hex),
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              label: 'Lettering',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _segments<SpineFont>(
                    values: SpineFont.values,
                    selected: _style.font,
                    label: (f) => switch (f) {
                      SpineFont.serif => 'Serif',
                      SpineFont.serifItalic => 'Italic serif',
                      SpineFont.sans => 'Sans',
                    },
                    onPick: (f) => _restyle(_style.copyWith(font: f)),
                  ),
                  const SizedBox(height: 14),
                  _swatches(
                    selected: _style.textColor,
                    auto: 'Automatic',
                    options: spineInks,
                    onPick: (hex) =>
                        _restyle(hex == null ? _style.copyWith(clearTextColor: true) : _style.copyWith(textColor: hex)),
                  ),
                ],
              ),
            ),
            _Section(
              label: 'Size',
              child: Column(
                children: [
                  _sizeRow('Height', _style.height, (v) => _style.copyWith(height: v)),
                  _sizeRow('Thickness', _style.width, (v) => _style.copyWith(width: v)),
                  _sizeRow('Lettering', _style.textSize, (v) => _style.copyWith(textSize: v)),
                ],
              ),
            ),
            _Section(
              label: 'Journal colour',
              hint: 'The accent of this recipe’s journal pages.',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final th in ScrapbookTheme.values)
                    ChoiceChip(
                      avatar: CircleAvatar(backgroundColor: th.accent(c), radius: 8),
                      label: Text(th.label),
                      selected: _theme == th,
                      onSelected: (_) => setState(() => _theme = th),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segments<T>({
    required List<T> values,
    required T selected,
    required String Function(T) label,
    required ValueChanged<T> onPick,
  }) => SizedBox(
    width: double.infinity,
    child: SegmentedButton<T>(
      showSelectedIcon: false,
      segments: [for (final v in values) ButtonSegment(value: v, label: Text(label(v)))],
      selected: {selected},
      onSelectionChanged: (s) => onPick(s.first),
    ),
  );

  Widget _sizeRow(String label, SpineScale value, BookStyle Function(SpineScale) apply) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(width: 92, child: Text(label, style: context.chefText.labelLarge)),
        Expanded(
          child: _segments<SpineScale>(
            values: SpineScale.values,
            selected: value,
            label: (s) => s.label,
            onPick: (s) => _restyle(apply(s)),
          ),
        ),
      ],
    ),
  );

  Widget _swatches({
    required String? selected,
    required String auto,
    required List<({String name, String hex})> options,
    required ValueChanged<String?> onPick,
  }) {
    final c = context.chefColors;
    Widget dot(Color? color, String label, bool isSelected, VoidCallback onTap) => Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: ChefMotion.quick,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color ?? Colors.transparent,
              border: Border.all(color: isSelected ? c.accentTomato : c.outlineSubtle, width: isSelected ? 2.5 : 1),
            ),
            child: color == null ? Icon(LucideIcons.wandSparkles, size: 16, color: c.contentSecondary) : null,
          ),
        ),
      ),
    );
    // A colour picked from a photo isn't one of the cloths: show it too.
    final custom = selected != null && !options.any((o) => o.hex == selected) ? selected : null;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        dot(null, auto, selected == null, () => onPick(null)),
        if (custom != null)
          dot(Color(0xFF000000 | int.parse(custom.substring(1), radix: 16)), 'From photo', true, () => onPick(custom)),
        for (final o in options)
          dot(
            Color(0xFF000000 | int.parse(o.hex.substring(1), radix: 16)),
            o.name,
            selected == o.hex,
            () => onPick(o.hex),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  final String? hint;
  const _Section({required this.label, required this.child, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(label, style: context.chefText.titleMedium)),
          const SizedBox(height: 10),
          child,
          if (hint != null) ...[const SizedBox(height: 6), Text(hint!, style: context.chefText.bodySmall)],
        ],
      ),
    );
  }
}

/// The book on a lit shelf against the library's wall: cover beside spine.
class _Preview extends StatelessWidget {
  final Recipe recipe;
  final ShelfStyle shelf;
  const _Preview({required this.recipe, required this.shelf});

  @override
  Widget build(BuildContext context) {
    const shelfH = 190.0;
    final spineH = BookMetrics.spineHeight(recipe, shelfH);
    final spineW = BookMetrics.spineWidth(recipe, 1.15);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: shelfH + 56,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: WallPainter(style: shelf.wall, tint: shelf.wallColor),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 17,
              height: shelfH,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _shadowed(
                    SizedBox(
                      width: BookMetrics.coverWidth(shelfH),
                      height: BookMetrics.coverHeight(shelfH),
                      child: BookCoverFace(recipe: recipe),
                    ),
                  ),
                  const SizedBox(width: 18),
                  _shadowed(
                    SizedBox(
                      width: spineW,
                      height: spineH,
                      child: BookSpine(recipe: recipe, scale: 1.15),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ShelfPlank(wood: shelf.wood, glow: shelf.glow, height: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shadowed(Widget child) => DecoratedBox(
    decoration: BoxDecoration(
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(3, 4))],
    ),
    child: child,
  );
}
