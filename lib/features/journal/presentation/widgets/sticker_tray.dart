import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/audio_chime_service.dart';
import 'sticker_art.dart';

/// What the sticker tray hands back: a sticker or a strip of washi tape,
/// ready to place on [pageSide].
sealed class ScrapbookAddition {
  const ScrapbookAddition();
}

class StickerAddition extends ScrapbookAddition {
  final ScrapbookSticker sticker;
  const StickerAddition(this.sticker);
}

class TapeAddition extends ScrapbookAddition {
  final WashiTapeDecoration tape;
  const TapeAddition(this.tape);
}

/// Stamps, doodles, wax seals, washi tape, icons and custom ink badges.
/// New items land near the top of the visible page with a little random
/// tilt so repeated stickers don't stack exactly.
Future<ScrapbookAddition?> showStickerTray(BuildContext context, {required String pageSide}) {
  return showModalBottomSheet<ScrapbookAddition>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _StickerTray(pageSide: pageSide),
  );
}

class _StickerTray extends StatefulWidget {
  final String pageSide;
  const _StickerTray({required this.pageSide});

  @override
  State<_StickerTray> createState() => _StickerTrayState();
}

class _StickerTrayState extends State<_StickerTray> {
  final _random = math.Random();
  final _badgeText = TextEditingController(text: 'Grandma’s secret');
  final _doodleQuery = TextEditingController();
  String _badgeShape = 'oval';
  int _badgeInk = 0;
  int _iconInk = 0;

  @override
  void dispose() {
    _badgeText.dispose();
    _doodleQuery.dispose();
    super.dispose();
  }

  String _id(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 20)}';
  double _jitter(double spread) => (_random.nextDouble() - 0.5) * spread;

  void _done(ScrapbookAddition addition) {
    audioChime.playTap();
    Navigator.of(context).pop(addition);
  }

  ScrapbookSticker _sticker({
    required String content,
    required String type,
    String? label,
    String? color,
    String? bgColor,
    double rotation = 0,
  }) => ScrapbookSticker(
    id: _id('stk'),
    content: content,
    type: type,
    iconId: type == 'icon' || type == 'badge' ? null : content,
    label: label,
    color: color,
    bgColor: bgColor,
    pageSide: widget.pageSide,
    x: 50 + _jitter(30),
    y: 22 + _jitter(14),
    rotation: rotation + _jitter(8),
    scale: 1,
    zIndex: DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
  );

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final height = MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: height,
      child: DefaultTabController(
        length: 6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(child: Text('Add to your page', style: t.titleLarge)),
                  Text(widget.pageSide == 'right' ? 'Method page' : 'Story page', style: t.labelMedium),
                ],
              ),
            ),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Stamps'),
                Tab(text: 'Doodles'),
                Tab(text: 'Seals'),
                Tab(text: 'Washi tape'),
                Tab(text: 'Icons'),
                Tab(text: 'Ink badge'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ArtGrid(
                    items: postageStampDefs,
                    onPick: (d) => _done(
                      StickerAddition(
                        _sticker(content: d.id, type: 'stamp', label: d.name, rotation: d.defaultRotation),
                      ),
                    ),
                  ),
                  _doodles(),
                  _ArtGrid(
                    items: waxSealDefs,
                    onPick: (d) => _done(
                      StickerAddition(
                        _sticker(content: d.id, type: 'seal', label: d.name, rotation: d.defaultRotation),
                      ),
                    ),
                  ),
                  _tapes(),
                  _icons(),
                  _badge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doodles() {
    final q = _doodleQuery.text.trim().toLowerCase();
    final items = q.isEmpty ? foodDoodleDefs : foodDoodleDefs.where((d) => d.name.toLowerCase().contains(q)).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _doodleQuery,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search doodles — taco, croissant, matcha…',
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(child: Text('No doodles match “$q”.', style: context.chefText.bodyMedium))
              : _ArtGrid(
                  items: items,
                  onPick: (d) => _done(
                    StickerAddition(
                      _sticker(content: d.id, type: 'doodle', label: d.name, rotation: d.defaultRotation),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _tapes() {
    final c = context.chefColors;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: WashiTapePattern.values.length,
      itemBuilder: (context, i) {
        final pattern = WashiTapePattern.values[i];
        final name = '${pattern.name[0].toUpperCase()}${pattern.name.substring(1)}';
        return _TrayTile(
          semanticLabel: '$name washi tape',
          onTap: () => _done(
            TapeAddition(
              WashiTapeDecoration(
                id: _id('wash'),
                pattern: pattern.name,
                pageSide: widget.pageSide,
                x: 50 + _jitter(30),
                y: 8 + _jitter(8),
                width: 120 + _jitter(30),
                rotation: _jitter(16),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WashiTape(width: 110, height: 18, rotation: -0.04, pattern: pattern),
              const SizedBox(height: 8),
              Text(name, style: context.chefText.labelMedium?.copyWith(color: c.contentSecondary)),
            ],
          ),
        );
      },
    );
  }

  Widget _icons() {
    final ink = inkPalette[_iconInk];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: InkSwatches(selected: _iconInk, onSelected: (i) => setState(() => _iconInk = i)),
        ),
        Expanded(
          child: CulinaryIconGrid(
            ink: ink.ink,
            onPick: (item) => _done(
              StickerAddition(
                _sticker(
                  content: item.key,
                  type: 'icon',
                  label: item.label,
                  color: toHexColor(ink.ink),
                  bgColor: toHexColor(ink.paper),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge() {
    final t = context.chefText;
    final ink = inkPalette[_badgeInk];
    final text = _badgeText.text.trim().isEmpty ? 'Chef approved' : _badgeText.text.trim();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Transform.scale(
              scale: 1.4,
              child: DynamicCustomInkBadge(
                text: text,
                shape: _badgeShape,
                color: ink.ink,
                bgColor: ink.paper,
                rotation: -0.04,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _badgeText,
          maxLength: 28,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Badge text'),
        ),
        Text('Shape', style: t.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'oval', label: Text('Oval')),
            ButtonSegment(value: 'box', label: Text('Crest')),
            ButtonSegment(value: 'ribbon', label: Text('Ribbon')),
          ],
          selected: {_badgeShape},
          onSelectionChanged: (s) => setState(() => _badgeShape = s.first),
        ),
        const SizedBox(height: 16),
        Text('Ink', style: t.labelLarge),
        const SizedBox(height: 8),
        InkSwatches(selected: _badgeInk, onSelected: (i) => setState(() => _badgeInk = i)),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _done(
            StickerAddition(
              _sticker(
                content: 'custom-ink:$_badgeShape:$text',
                type: 'badge',
                label: text,
                color: toHexColor(ink.ink),
                bgColor: toHexColor(ink.paper),
                rotation: -4,
              ),
            ),
          ),
          icon: const Icon(Icons.verified_outlined),
          label: const Text('Place badge'),
        ),
      ],
    );
  }
}

class _ArtGrid extends StatelessWidget {
  final List<CulinaryStampDef> items;
  final ValueChanged<CulinaryStampDef> onPick;
  const _ArtGrid({required this.items, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.paddingOf(context).bottom),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final d = items[i];
        return _TrayTile(
          semanticLabel: d.name,
          onTap: () => onPick(d),
          child: Column(
            children: [
              Expanded(child: FittedBox(child: d.builder(size: 72, rotation: 0))),
              const SizedBox(height: 4),
              Text(
                d.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.chefText.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrayTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;
  const _TrayTile({required this.child, required this.onTap, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(8), child: child),
        ),
      ),
    );
  }
}

/// Row of ink colour swatches.
class InkSwatches extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const InkSwatches({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < inkPalette.length; i++)
          Semantics(
            button: true,
            selected: i == selected,
            label: '${inkPalette[i].name} ink',
            excludeSemantics: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: ChefMotion.quick,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inkPalette[i].ink,
                  border: Border.all(
                    color: i == selected ? c.contentPrimary : c.outlineSubtle,
                    width: i == selected ? 3 : 1,
                  ),
                ),
                child: i == selected ? Icon(Icons.check_rounded, size: 18, color: inkPalette[i].paper) : null,
              ),
            ),
          ),
      ],
    );
  }
}

/// All culinary icons, grouped by category.
class CulinaryIconGrid extends StatelessWidget {
  final Color ink;
  final ValueChanged<CulinaryIconItem> onPick;
  final String? selectedKey;
  const CulinaryIconGrid({super.key, required this.ink, required this.onPick, this.selectedKey});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final byCategory = <String, List<CulinaryIconItem>>{};
    for (final item in culinaryIconsCatalog) {
      if (item.category.isEmpty) continue;
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }
    return CustomScrollView(
      slivers: [
        for (final entry in byCategory.entries) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(child: Text(entry.key, style: context.chefText.labelLarge)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 64,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, i) {
                final item = entry.value[i];
                final isSelected = item.key == selectedKey;
                return Tooltip(
                  message: item.label,
                  child: Material(
                    color: isSelected ? ink.withValues(alpha: 0.16) : c.surfaceRaised,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: isSelected ? BorderSide(color: ink, width: 2) : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onPick(item),
                      child: Center(
                        child: Icon(
                          item.icon,
                          color: c.isDark ? Color.lerp(ink, Colors.white, 0.35) : ink,
                          semanticLabel: item.label,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: 16 + MediaQuery.paddingOf(context).bottom)),
      ],
    );
  }
}

/// Picks an icon and ink colour for an ingredient, step or tip.
Future<({String key, Color ink})?> showCulinaryIconPicker(
  BuildContext context, {
  String? currentKey,
  Color? currentInk,
  String title = 'Choose an icon',
}) {
  return showModalBottomSheet<({String key, Color ink})>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      var inkIndex = inkPalette.indexWhere((p) => p.ink.toARGB32() == currentInk?.toARGB32());
      if (inkIndex < 0) inkIndex = 0;
      return StatefulBuilder(
        builder: (ctx, setState) {
          return SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(title, style: ctx.chefText.titleLarge),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkSwatches(selected: inkIndex, onSelected: (i) => setState(() => inkIndex = i)),
                ),
                Expanded(
                  child: CulinaryIconGrid(
                    ink: inkPalette[inkIndex].ink,
                    selectedKey: currentKey,
                    onPick: (item) => Navigator.of(ctx).pop((key: item.key, ink: inkPalette[inkIndex].ink)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
