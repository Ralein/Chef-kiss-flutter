import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/recipe_image.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart' show showCoverPhotoSheet;
import '../domain/book_covers.dart';
import '../domain/cookbook.dart';
import '../domain/shelf_style.dart';
import 'widgets/library_books.dart';
import 'widgets/shelf_art.dart';
import 'widgets/spine_from_photo.dart';

/// How a book stands in the library — My Recipes or a cookbook: its title,
/// cover photo, spine and lettering, and whether it shows its spine or its
/// cover, previewed on a shelf. A new photo prints the spine in the photo's
/// colours; Shuffle tries another pattern.
class BookEditorScreen extends ConsumerStatefulWidget {
  /// A cookbook's id, or [myRecipesId].
  final String bookId;
  const BookEditorScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookEditorScreen> createState() => _BookEditorScreenState();
}

class _BookEditorScreenState extends ConsumerState<BookEditorScreen> {
  final _title = TextEditingController();
  BookCover? _original;
  BookCover _draft = const BookCover();
  String _name = '';

  /// How far Shuffle has gone through the photo's patterns.
  int _turn = 0;
  bool _saving = false;

  /// Reading a new photo's colours.
  bool _reading = false;

  bool get _isMyRecipes => widget.bookId == myRecipesId;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _load(BookCover cover, String name) {
    if (_original != null) return;
    _original = cover;
    _draft = cover;
    _name = name;
    _title.text = name;
    _turn = SpinePattern.printed.indexOf(cover.style.pattern).clamp(0, SpinePattern.printed.length);
  }

  String get _titleText => _title.text.trim().isEmpty ? _name : _title.text.trim();

  bool get _dirty => _original != null && (_draft != _original || _titleText != _name);

  void _restyle(BookStyle style) => setState(() => _draft = _draft.copyWith(style: style));

  Future<void> _save() async {
    if (_original == null || _saving) return;
    setState(() => _saving = true);
    final name = _titleText;
    final cover = _isMyRecipes
        ? BookCover(
            title: name == 'My Recipes' ? null : name,
            photo: _draft.photo,
            style: _draft.style,
            palette: _draft.palette,
          )
        : _draft;
    var ok = (await saveBookCover(ref.read(preferencesRepositoryProvider), widget.bookId, cover)).isSuccess;
    if (ok && !_isMyRecipes && name != _name) {
      final books = ref.read(collectionsStreamProvider).valueOrNull ?? const <RecipeCollection>[];
      final book = books.where((b) => b.id == widget.bookId).firstOrNull;
      if (book != null) {
        final renamed = await ref
            .read(collectionRepositoryProvider)
            .updateCollection(book.copyWith(name: name, updatedAt: DateTime.now().millisecondsSinceEpoch));
        ok = renamed.isSuccess;
      }
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      ChefToastService.show(context: context, title: 'Could not save the book', type: ChefToastType.error);
      return;
    }
    context.pop();
  }

  /// A new photo prints the spine in its colours, in a pattern of this
  /// book's own; Shuffle tries the others.
  Future<void> _changePhoto() async {
    final choice = await showCoverPhotoSheet(context, theme: ScrapbookTheme.terracottaClassic);
    if (choice == null || !mounted) return;
    final source = choice.source;
    if (source == null) {
      // The spine keeps its print; only the photo goes.
      setState(() {
        _draft = _draft.copyWith(clearPhoto: true, palette: const []);
        _reading = false;
      });
      return;
    }
    setState(() {
      _draft = _draft.copyWith(photo: source);
      _reading = true;
    });
    final palette = paletteHex(await paletteFromPhoto(source));
    if (!mounted || _draft.photo != source) return;
    setState(() {
      _reading = false;
      if (palette.isEmpty) return;
      _turn = widget.bookId.hashCode.abs() % SpinePattern.printed.length;
      _draft = _draft.copyWith(
        palette: palette,
        style: spineFromPalette(_draft.style, palette, turn: _turn),
      );
    });
  }

  void _shuffle() => setState(() {
    _turn++;
    _draft = _draft.copyWith(style: spineFromPalette(_draft.style, _draft.palette, turn: _turn));
  });

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
    final coversAsync = ref.watch(bookCoversProvider);
    final booksAsync = ref.watch(collectionsStreamProvider);
    final all = ref.watch(allRecipesProvider).valueOrNull ?? const <Recipe>[];
    final books = booksAsync.valueOrNull;
    final covers = coversAsync.valueOrNull;
    final book = books?.where((b) => b.id == widget.bookId).firstOrNull;
    final missing = books != null && !_isMyRecipes && book == null;
    if (covers != null && books != null && !missing) {
      _load(covers[widget.bookId] ?? const BookCover(), bookName(widget.bookId, books, covers));
    }

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
            ? (missing || coversAsync.hasError || booksAsync.hasError
                  ? const ErrorView(message: 'This book could not be found.')
                  : const LoadingView())
            : _body(context, shelf, _volume(all, books ?? const [], book)),
      ),
    );
  }

  /// The book as it stands on the shelf, with the edits so far.
  Recipe _volume(List<Recipe> all, List<RecipeCollection> books, RecipeCollection? book) {
    if (book == null) {
      return Cookbook.myRecipes(
        recipes: unfiledRecipes(all, books).length,
        cover: _draft.copyWith(title: _titleText),
      );
    }
    final ids = {for (final r in all) r.id};
    return Cookbook.volume(
      book.copyWith(name: _titleText),
      recipes: book.recipeIds.where(ids.contains).length,
      cover: _draft,
    );
  }

  Widget _body(BuildContext context, ShelfStyle shelf, Recipe volume) {
    final t = context.chefText;
    final style = _draft.style;
    final photo = _draft.photo;
    final palette = _draft.palette;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _Preview(recipe: volume, shelf: shelf),
            const SizedBox(height: 20),
            TextField(
              controller: _title,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 6),
            Text(volume.summary ?? '', style: t.bodySmall),
            const SizedBox(height: 24),
            _Section(
              label: 'Cover photo',
              hint: photo == null ? 'Add a photo and the spine is printed in its colours.' : null,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 52,
                      height: 68,
                      child: RecipeImage(source: photo, theme: volume.theme),
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton.icon(
                    onPressed: _reading ? null : _changePhoto,
                    icon: _reading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(LucideIcons.imagePlus, size: 18),
                    label: Text(photo == null ? 'Add photo' : 'Change photo'),
                  ),
                ],
              ),
            ),
            _Section(
              label: 'Spine',
              trailing: palette.isEmpty
                  ? null
                  : TextButton.icon(
                      onPressed: _shuffle,
                      icon: const Icon(LucideIcons.shuffle, size: 18),
                      label: const Text('Shuffle'),
                    ),
              hint: palette.isEmpty ? null : 'Printed in your photo’s colours.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 12,
                    children: [
                      for (final p in SpinePattern.values)
                        _PatternChoice(
                          volume: volume,
                          pattern: p,
                          selected: style.pattern == p,
                          onTap: () => _restyle(style.copyWith(pattern: p)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Cloth', style: t.labelLarge),
                  const SizedBox(height: 8),
                  _swatches(
                    selected: style.spineColor,
                    fromPhoto: palette,
                    options: spineCloths,
                    onPick: (hex) =>
                        _restyle(hex == null ? style.copyWith(clearSpineColor: true) : style.copyWith(spineColor: hex)),
                  ),
                  if (SpinePattern.printed.contains(style.pattern)) ...[
                    const SizedBox(height: 18),
                    Text('Pattern', style: t.labelLarge),
                    const SizedBox(height: 8),
                    _swatches(
                      selected: style.accentColor,
                      fromPhoto: palette.skip(1).toList(),
                      options: spineInks,
                      onPick: (hex) => _restyle(
                        hex == null ? style.copyWith(clearAccentColor: true) : style.copyWith(accentColor: hex),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _Section(
              label: 'On the shelf',
              child: _segments<BookDisplay>(
                values: const [BookDisplay.spine, BookDisplay.cover],
                selected: style.display == BookDisplay.cover ? BookDisplay.cover : BookDisplay.spine,
                label: (d) => d == BookDisplay.cover ? 'Cover out' : 'Spine out',
                onPick: (d) => _restyle(style.copyWith(display: d)),
              ),
            ),
            _Section(
              label: 'Lettering',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _segments<SpineFont>(
                    values: SpineFont.values,
                    selected: style.font,
                    label: (f) => switch (f) {
                      SpineFont.serif => 'Serif',
                      SpineFont.serifItalic => 'Italic',
                      SpineFont.sans => 'Sans',
                    },
                    onPick: (f) => _restyle(style.copyWith(font: f)),
                  ),
                  const SizedBox(height: 14),
                  _swatches(
                    selected: style.textColor,
                    options: spineInks,
                    onPick: (hex) =>
                        _restyle(hex == null ? style.copyWith(clearTextColor: true) : style.copyWith(textColor: hex)),
                  ),
                ],
              ),
            ),
            _Section(
              label: 'Size',
              child: Column(
                children: [
                  _sizeRow('Height', style.height, (v) => style.copyWith(height: v)),
                  _sizeRow('Thickness', style.width, (v) => style.copyWith(width: v)),
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

  /// Automatic, then the photo's colours, then the standard ones.
  Widget _swatches({
    required String? selected,
    List<String> fromPhoto = const [],
    required List<({String name, String hex})> options,
    required ValueChanged<String?> onPick,
  }) {
    final c = context.chefColors;
    Color colorOf(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
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
    final known = {...fromPhoto, for (final o in options) o.hex};
    // A colour picked from an earlier photo: show it too.
    final custom = selected != null && !known.contains(selected) ? selected : null;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        dot(null, 'Automatic', selected == null, () => onPick(null)),
        for (final hex in [...fromPhoto, ?custom]) dot(colorOf(hex), 'From photo', selected == hex, () => onPick(hex)),
        for (final o in options) dot(colorOf(o.hex), o.name, selected == o.hex, () => onPick(o.hex)),
      ],
    );
  }
}

/// One spine pattern to pick: a short spine printed with it, named below.
class _PatternChoice extends StatelessWidget {
  final Recipe volume;
  final SpinePattern pattern;
  final bool selected;
  final VoidCallback onTap;
  const _PatternChoice({required this.volume, required this.pattern, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final look = BookLook.of(volume.copyWith(bookStyle: volume.bookStyle.copyWith(pattern: pattern)));
    return Semantics(
      button: true,
      selected: selected,
      label: pattern.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 62,
          child: Column(
            children: [
              AnimatedContainer(
                duration: ChefMotion.quick,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selected ? c.accentTomato : Colors.transparent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.5),
                  child: SizedBox(width: 26, height: 64, child: CustomPaint(painter: _SwatchPainter(look))),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pattern.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.chefText.labelSmall?.copyWith(
                  color: selected ? c.contentPrimary : c.contentSecondary,
                  fontWeight: selected ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  final BookLook look;
  _SwatchPainter(this.look);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = look.cloth);
    paintBookPattern(canvas, size, look, margin: size.height * 0.13);
    if (look.printed) {
      // The label a printed spine's title sits on.
      final label = RRect.fromRectAndRadius(
        Rect.fromLTRB(3, size.height * 0.3, size.width - 3, size.height * 0.7),
        const Radius.circular(2),
      );
      canvas.drawRRect(label, Paint()..color = look.cloth);
      canvas.drawRRect(
        label,
        Paint()
          ..color = look.ink.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter old) =>
      old.look.pattern != look.pattern ||
      old.look.cloth != look.cloth ||
      old.look.accent != look.accent ||
      old.look.ink != look.ink;
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  final String? hint;
  final Widget? trailing;
  const _Section({required this.label, required this.child, this.hint, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: Semantics(header: true, child: Text(label, style: context.chefText.titleMedium)),
                ),
                ?trailing,
              ],
            ),
          ),
          const SizedBox(height: 4),
          child,
          if (hint != null) ...[const SizedBox(height: 8), Text(hint!, style: context.chefText.bodySmall)],
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
