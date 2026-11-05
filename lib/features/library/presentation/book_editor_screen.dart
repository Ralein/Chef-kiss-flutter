import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// "Edit your book": how a recipe stands in the library — title, cover or
/// spine, and the spine's cloth, lettering, size and pattern — with a live
/// preview on a lit shelf.
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
  bool _spineTab = false;
  bool _saving = false;

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

  Future<void> _changeCover() async {
    final choice = await showCoverPhotoSheet(context, theme: _theme);
    if (choice != null && mounted) setState(() => _cover = choice.source);
  }

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfStyleProvider).valueOrNull ?? const ShelfStyle();
    final async = ref.watch(singleRecipeProvider(widget.recipeId));
    final recipe = async.valueOrNull;
    if (recipe != null) _load(recipe);
    final theme = shelf.isDark ? ChefTheme.dark() : ChefTheme.light();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: shelf.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Theme(
        data: theme,
        child: Builder(
          builder: (context) => PopScope(
            canPop: !_dirty,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final leave = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text('Your edits to this book haven’t been saved.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
                  ],
                ),
              );
              if (leave == true && context.mounted) {
                _original = null;
                setState(() {});
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              backgroundColor: shelf.wallColor,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: WallPainter(style: shelf.wall, tint: shelf.wallColor),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: _original == null
                        ? (async.hasError
                              ? const ErrorView(message: 'This recipe could not be loaded.')
                              : const LoadingView())
                        : _body(context, shelf),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ShelfStyle shelf) {
    final c = context.chefColors;
    final t = context.chefText;
    final draft = _draft;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton.outlined(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Edit your '),
                          TextSpan(
                            text: 'book',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: c.isDark ? const Color(0xFFE3C77F) : c.accentTomato,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(fontFamily: kSerifFamily, fontSize: 32, color: c.contentPrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Preview(recipe: draft, shelf: shelf),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _title,
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() {}),
                    maxLines: 2,
                    minLines: 1,
                    style: TextStyle(
                      fontFamily: kSerifFamily,
                      fontStyle: FontStyle.italic,
                      fontSize: 24,
                      color: c.contentPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      hintText: 'Title',
                      suffixIcon: Icon(LucideIcons.squarePen, size: 18, color: c.contentSecondary),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: c.outlineSubtle)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.outlineSubtle)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      '${KitchenFormat.minutes(draft.totalMinutes)} · serves ${draft.baseServings.toDisplayString()} · '
                      '${draft.ingredients.length} ingredients',
                      style: t.bodySmall?.copyWith(color: c.contentSecondary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: false, icon: Icon(LucideIcons.info, size: 18), label: Text('Details')),
                      ButtonSegment(value: true, icon: Icon(LucideIcons.brush, size: 18), label: Text('Spine')),
                    ],
                    selected: {_spineTab},
                    onSelectionChanged: (s) => setState(() => _spineTab = s.first),
                  ),
                  const SizedBox(height: 18),
                  ...(_spineTab ? _spineOptions(context) : _detailOptions(context)),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: c.isDark ? const Color(0xFFFBF6EC) : c.contentPrimary,
                  foregroundColor: c.isDark ? const Color(0xFF1C1A18) : c.surfacePaper,
                  textStyle: t.titleMedium,
                ),
                child: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _detailOptions(BuildContext context) => [
    _Section(
      label: 'On the shelf',
      hint: 'Automatic shows one favorite per shelf face-out.',
      child: Wrap(
        spacing: 8,
        children: [
          for (final d in BookDisplay.values)
            ChoiceChip(
              label: Text(d.label),
              selected: _style.display == d,
              onSelected: (_) => setState(() => _style = _style.copyWith(display: d)),
            ),
        ],
      ),
    ),
    _Section(
      label: 'Cover',
      hint: 'Sets the journal pages’ accent and the spine, unless you pick a spine colour.',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 48,
              height: 64,
              child: RecipeImage(source: _cover, theme: _theme),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _changeCover,
            icon: const Icon(LucideIcons.imagePlus, size: 18),
            label: const Text('Change cover'),
          ),
        ],
      ),
    ),
    _Section(
      label: 'Colour family',
      child: Wrap(
        spacing: 8,
        children: [
          for (final th in ScrapbookTheme.values)
            ChoiceChip(
              avatar: CircleAvatar(backgroundColor: th.accent(context.chefColors), radius: 8),
              label: Text(th.label),
              selected: _theme == th,
              onSelected: (_) => setState(() => _theme = th),
            ),
        ],
      ),
    ),
  ];

  List<Widget> _spineOptions(BuildContext context) => [
    _Section(
      label: 'Lettering',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final f in SpineFont.values)
            ChoiceChip(
              label: Text(
                f.label,
                style: switch (f) {
                  SpineFont.serif => const TextStyle(fontFamily: kSerifFamily, fontSize: 15),
                  SpineFont.serifItalic => const TextStyle(
                    fontFamily: kSerifFamily,
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                  ),
                  SpineFont.sans => const TextStyle(fontWeight: FontWeight.w700),
                },
              ),
              selected: _style.font == f,
              onSelected: (_) => setState(() => _style = _style.copyWith(font: f)),
            ),
        ],
      ),
    ),
    _Section(
      label: 'Text size',
      child: _scale(_style.textSize, (v) => _style.copyWith(textSize: v)),
    ),
    _Section(
      label: 'Text colour',
      child: _swatches(
        selected: _style.textColor,
        auto: 'Auto',
        options: spineInks,
        onPick: (hex) => setState(
          () => _style = hex == null ? _style.copyWith(clearTextColor: true) : _style.copyWith(textColor: hex),
        ),
      ),
    ),
    _Section(
      label: 'Spine colour',
      child: _swatches(
        selected: _style.spineColor,
        auto: 'Theme',
        options: spineCloths,
        onPick: (hex) => setState(
          () => _style = hex == null ? _style.copyWith(clearSpineColor: true) : _style.copyWith(spineColor: hex),
        ),
      ),
    ),
    _Section(
      label: 'Height',
      child: _scale(_style.height, (v) => _style.copyWith(height: v)),
    ),
    _Section(
      label: 'Thickness',
      child: _scale(_style.width, (v) => _style.copyWith(width: v)),
    ),
    _Section(
      label: 'Pattern',
      child: Wrap(
        spacing: 8,
        children: [
          for (final p in SpinePattern.values)
            ChoiceChip(
              label: Text(p.label),
              selected: _style.pattern == p,
              onSelected: (_) => setState(() => _style = _style.copyWith(pattern: p)),
            ),
        ],
      ),
    ),
  ];

  Widget _scale(SpineScale value, BookStyle Function(SpineScale) apply) => SegmentedButton<SpineScale>(
    showSelectedIcon: false,
    segments: [for (final s in SpineScale.values) ButtonSegment(value: s, label: Text(s.label))],
    selected: {value},
    onSelectionChanged: (s) => setState(() => _style = apply(s.first)),
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
              border: Border.all(
                color: isSelected ? (c.isDark ? const Color(0xFFE3C77F) : c.accentTomato) : c.outlineSubtle,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: color == null ? Icon(LucideIcons.wandSparkles, size: 16, color: c.contentSecondary) : null,
          ),
        ),
      ),
    );
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        dot(null, auto, selected == null, () => onPick(null)),
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
    final c = context.chefColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkle, size: 14, color: c.isDark ? const Color(0xFFE3C77F) : c.accentTomato),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: kSerifFamily,
                  fontStyle: FontStyle.italic,
                  fontSize: 19,
                  color: c.contentPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(hint!, style: context.chefText.bodySmall?.copyWith(color: c.contentSecondary)),
          ],
        ],
      ),
    );
  }
}

/// The book standing on a lit shelf: cover beside its spine.
class _Preview extends StatelessWidget {
  final Recipe recipe;
  final ShelfStyle shelf;
  const _Preview({required this.recipe, required this.shelf});

  @override
  Widget build(BuildContext context) {
    const shelfH = 230.0;
    final spineH = BookMetrics.spineHeight(recipe, shelfH);
    final spineW = BookMetrics.spineWidth(recipe, 1.25);
    return SizedBox(
      height: shelfH + 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
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
                    child: BookSpine(recipe: recipe, scale: 1.25),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: -20,
            right: -20,
            bottom: 0,
            child: ShelfPlank(wood: shelf.wood, glow: shelf.glow, height: 14),
          ),
        ],
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
