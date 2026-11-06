import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// Texture painted on the wall behind the bookcase. Kitchen surfaces first:
/// tiles, a stainless freezer, a retro fridge, pegboard and a chalkboard.
enum WallStyle {
  subway('Subway tile'),
  zellige('Glazed tile'),
  steel('Stainless'),
  fridge('Retro fridge'),
  pegboard('Pegboard'),
  chalkboard('Chalkboard'),
  plaster('Plaster'),
  brick('Brick'),
  panels('Wood panels'),
  linen('Linen');

  final String label;
  const WallStyle(this.label);
}

/// Wall colours: six moody darks and two light options.
const wallTints = <({String name, Color color})>[
  (name: 'Charcoal', color: Color(0xFF1C1B1D)),
  (name: 'Midnight', color: Color(0xFF1A2234)),
  (name: 'Forest', color: Color(0xFF1C2A21)),
  (name: 'Teal', color: Color(0xFF17292B)),
  (name: 'Plum', color: Color(0xFF251D2C)),
  (name: 'Wine', color: Color(0xFF2B1A1C)),
  (name: 'Cream', color: Color(0xFFEDE5D8)),
  (name: 'Sage', color: Color(0xFFD9E0D6)),
];

enum ShelfWood {
  walnut('Walnut', [Color(0xFF6E4C34), Color(0xFF51372A), Color(0xFF3A271B)]),
  oak('Oak', [Color(0xFFBF9264), Color(0xFFA0764B), Color(0xFF7F5B38)]),
  ebony('Ebony', [Color(0xFF3B3634), Color(0xFF2A2624), Color(0xFF1B1817)]),
  birch('Birch', [Color(0xFFE6D6BB), Color(0xFFD0BB97), Color(0xFFB4A07A)]);

  final String label;
  final List<Color> grain;
  const ShelfWood(this.label, this.grain);
}

/// The LED strip under each shelf.
enum ShelfGlow {
  off('Off', null),
  warm('Warm', Color(0xFFFFD79B)),
  cool('Cool', Color(0xFFDDEBFF));

  final String label;
  final Color? color;
  const ShelfGlow(this.label, this.color);
}

enum FlowerKind { roses, sunflowers, hydrangeas, daisies }

/// The style editor's palettes of decorations.
enum DecorGroup { kitchen, plants, lights }

/// Something to stand on a shelf, or to hang from the shelf above.
enum DecorPiece {
  crock('Utensil crock', DecorGroup.kitchen, Size(54, 116)),
  rail('Utensil rail', DecorGroup.kitchen, Size(128, 100), hangs: true),
  jars('Pantry jars', DecorGroup.kitchen, Size(80, 86)),
  pot('Cast-iron pot', DecorGroup.kitchen, Size(92, 62)),
  kettle('Kettle', DecorGroup.kitchen, Size(72, 76)),
  bottles('Oil & vinegar', DecorGroup.kitchen, Size(46, 104)),
  mortar('Mortar & pestle', DecorGroup.kitchen, Size(60, 62)),
  plant('Potted plant', DecorGroup.plants, Size(64, 92)),
  herbs('Basil pot', DecorGroup.plants, Size(54, 72)),
  ivy('Trailing ivy', DecorGroup.plants, Size(104, 96), hangs: true),
  roses('Roses', DecorGroup.plants, Size(58, 96)),
  sunflowers('Sunflowers', DecorGroup.plants, Size(58, 96)),
  hydrangeas('Hydrangeas', DecorGroup.plants, Size(58, 96)),
  daisies('Daisies', DecorGroup.plants, Size(58, 96)),
  pillar('Pillar candle', DecorGroup.lights, Size(24, 42)),
  tallCandle('Tall candle', DecorGroup.lights, Size(26, 64)),
  candlePair('Candle pair', DecorGroup.lights, Size(44, 74));

  final String label;
  final DecorGroup group;

  /// Natural size on a phone-width shelf.
  final Size size;

  /// Hangs from the shelf above rather than standing on one.
  final bool hangs;

  const DecorPiece(this.label, this.group, this.size, {this.hangs = false});
}

/// A decoration put somewhere on the bookcase.
@immutable
class PlacedDecor {
  final String id;
  final DecorPiece piece;

  /// The shelf it stands on, or hangs into from above; 0 is the top shelf.
  final int shelf;

  /// Across the shelf: 0 against the left end, 1 against the right end.
  final double x;

  /// Relative to the piece's natural size.
  final double size;
  final bool flipped;

  /// Picks a glaze, enamel or leaf pattern.
  final int seed;

  static const minSize = 0.6;
  static const maxSize = 1.5;
  static const maxShelf = 99;

  const PlacedDecor({
    required this.id,
    required this.piece,
    required this.shelf,
    required this.x,
    this.size = 1,
    this.flipped = false,
    this.seed = 0,
  });

  PlacedDecor copyWith({String? id, int? shelf, double? x, double? size, bool? flipped}) => PlacedDecor(
    id: id ?? this.id,
    piece: piece,
    shelf: (shelf ?? this.shelf).clamp(0, maxShelf),
    x: (x ?? this.x).clamp(0.0, 1.0),
    size: (size ?? this.size).clamp(minSize, maxSize),
    flipped: flipped ?? this.flipped,
    seed: seed,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'piece': piece.name,
    'shelf': shelf,
    'x': x,
    'size': size,
    if (flipped) 'flip': true,
    if (seed != 0) 'seed': seed,
  };

  /// Null for anything unreadable, or a piece this version doesn't have.
  static PlacedDecor? fromJson(Object? json) {
    if (json is! Map) return null;
    final piece = DecorPiece.values.where((p) => p.name == json['piece']).firstOrNull;
    final (id, shelf, x, size, seed) = (json['id'], json['shelf'], json['x'], json['size'], json['seed']);
    if (piece == null || id is! String || shelf is! int || x is! num) return null;
    return PlacedDecor(
      id: id,
      piece: piece,
      shelf: shelf.clamp(0, maxShelf),
      x: x.toDouble().clamp(0.0, 1.0),
      size: size is num ? size.toDouble().clamp(minSize, maxSize) : 1,
      flipped: json['flip'] == true,
      seed: seed is int ? seed : 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlacedDecor &&
      other.id == id &&
      other.piece == piece &&
      other.shelf == shelf &&
      other.x == x &&
      other.size == size &&
      other.flipped == flipped &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(id, piece, shelf, x, size, flipped, seed);
}

T _byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.where((v) => v.name == name).firstOrNull ?? fallback;

/// How the library's bookcase is dressed. Stored in app preferences.
@immutable
class ShelfStyle {
  final WallStyle wall;
  final int tint;
  final ShelfWood wood;
  final ShelfGlow glow;

  /// Decorations as arranged by hand. Null until then: the shelves start
  /// dressed as a cosy kitchen.
  final List<PlacedDecor>? decor;

  const ShelfStyle({
    this.wall = WallStyle.subway,
    this.tint = 0,
    this.wood = ShelfWood.walnut,
    this.glow = ShelfGlow.warm,
    this.decor,
  });

  List<PlacedDecor> get pieces => decor ?? cozyKitchenDecor;

  Color get wallColor => wallTints[tint.clamp(0, wallTints.length - 1)].color;

  /// Dark walls get light text and the dark theme for the controls on them.
  bool get isDark => wallColor.computeLuminance() < 0.25;

  ShelfStyle copyWith({WallStyle? wall, int? tint, ShelfWood? wood, ShelfGlow? glow, List<PlacedDecor>? decor}) =>
      ShelfStyle(
        wall: wall ?? this.wall,
        tint: tint ?? this.tint,
        wood: wood ?? this.wood,
        glow: glow ?? this.glow,
        decor: decor ?? this.decor,
      );

  /// Same room, ignoring whether the decorations were ever arranged by hand.
  bool looksLike(ShelfStyle other) =>
      other.wall == wall &&
      other.tint == tint &&
      other.wood == wood &&
      other.glow == glow &&
      listEquals(other.pieces, pieces);

  Map<String, dynamic> toJson() => {
    'wall': wall.name,
    'tint': tint,
    'wood': wood.name,
    'glow': glow.name,
    if (decor case final decor?) 'decor': [for (final d in decor) d.toJson()],
  };

  factory ShelfStyle.fromJson(Object? json) {
    if (json is! Map) return const ShelfStyle();
    final tint = json['tint'];
    final decor = json['decor'];
    return ShelfStyle(
      wall: _byName(WallStyle.values, json['wall'], WallStyle.subway),
      tint: tint is int && tint >= 0 && tint < wallTints.length ? tint : 0,
      wood: _byName(ShelfWood.values, json['wood'], ShelfWood.walnut),
      glow: _byName(ShelfGlow.values, json['glow'], ShelfGlow.warm),
      decor: decor is List ? [...decor.map(PlacedDecor.fromJson).nonNulls] : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShelfStyle &&
      other.wall == wall &&
      other.tint == tint &&
      other.wood == wood &&
      other.glow == glow &&
      listEquals(other.decor, decor);

  @override
  int get hashCode => Object.hash(wall, tint, wood, glow, decor == null ? null : Object.hashAll(decor!));
}

/// The first three shelves of a kitchen: utensils, pantry jars, a pot and a
/// kettle, candles, a basil pot and trailing ivy.
const cozyKitchenDecor = <PlacedDecor>[
  PlacedDecor(id: 'k1', piece: DecorPiece.crock, shelf: 0, x: 0),
  PlacedDecor(id: 'k2', piece: DecorPiece.pillar, shelf: 0, x: 0.18, seed: 2),
  PlacedDecor(id: 'k3', piece: DecorPiece.plant, shelf: 0, x: 1, seed: 1),
  PlacedDecor(id: 'k4', piece: DecorPiece.ivy, shelf: 0, x: 0.86, seed: 3),
  PlacedDecor(id: 'k5', piece: DecorPiece.jars, shelf: 1, x: 0),
  PlacedDecor(id: 'k6', piece: DecorPiece.pot, shelf: 1, x: 0.93),
  PlacedDecor(id: 'k7', piece: DecorPiece.rail, shelf: 1, x: 1, seed: 1),
  PlacedDecor(id: 'k8', piece: DecorPiece.kettle, shelf: 2, x: 0, seed: 1),
  PlacedDecor(id: 'k9', piece: DecorPiece.candlePair, shelf: 2, x: 0.25, seed: 4),
  PlacedDecor(id: 'k10', piece: DecorPiece.herbs, shelf: 2, x: 1),
];

/// A ready-made room to start from: wall, shelves and decorations together.
typedef ShelfLook = ({String name, ShelfStyle style});

const shelfLooks = <ShelfLook>[
  (name: 'Cozy kitchen', style: ShelfStyle(decor: cozyKitchenDecor)),
  (
    name: 'Herb garden',
    style: ShelfStyle(
      wall: WallStyle.zellige,
      tint: 7,
      wood: ShelfWood.oak,
      decor: [
        PlacedDecor(id: 'h1', piece: DecorPiece.herbs, shelf: 0, x: 0),
        PlacedDecor(id: 'h2', piece: DecorPiece.ivy, shelf: 0, x: 0.55, seed: 1),
        PlacedDecor(id: 'h3', piece: DecorPiece.plant, shelf: 0, x: 1, seed: 2),
        PlacedDecor(id: 'h4', piece: DecorPiece.daisies, shelf: 1, x: 0, seed: 1),
        PlacedDecor(id: 'h5', piece: DecorPiece.mortar, shelf: 1, x: 1),
        PlacedDecor(id: 'h6', piece: DecorPiece.plant, shelf: 2, x: 0, seed: 4),
        PlacedDecor(id: 'h7', piece: DecorPiece.ivy, shelf: 2, x: 0.08, seed: 5),
        PlacedDecor(id: 'h8', piece: DecorPiece.sunflowers, shelf: 2, x: 1, seed: 2),
      ],
    ),
  ),
  (
    name: 'Bistro',
    style: ShelfStyle(
      wall: WallStyle.steel,
      wood: ShelfWood.ebony,
      glow: ShelfGlow.cool,
      decor: [
        PlacedDecor(id: 'b1', piece: DecorPiece.rail, shelf: 0, x: 0),
        PlacedDecor(id: 'b2', piece: DecorPiece.pot, shelf: 0, x: 0.02, seed: 1),
        PlacedDecor(id: 'b3', piece: DecorPiece.bottles, shelf: 0, x: 1),
        PlacedDecor(id: 'b4', piece: DecorPiece.crock, shelf: 1, x: 0, seed: 2),
        PlacedDecor(id: 'b5', piece: DecorPiece.tallCandle, shelf: 1, x: 0.82, seed: 1),
        PlacedDecor(id: 'b6', piece: DecorPiece.mortar, shelf: 1, x: 1, seed: 1),
        PlacedDecor(id: 'b7', piece: DecorPiece.jars, shelf: 2, x: 0, seed: 1),
        PlacedDecor(id: 'b8', piece: DecorPiece.kettle, shelf: 2, x: 1, seed: 2),
      ],
    ),
  ),
  (
    name: 'Retro diner',
    style: ShelfStyle(
      wall: WallStyle.fridge,
      tint: 7,
      wood: ShelfWood.birch,
      decor: [
        PlacedDecor(id: 'r1', piece: DecorPiece.kettle, shelf: 0, x: 0, seed: 3),
        PlacedDecor(id: 'r2', piece: DecorPiece.roses, shelf: 0, x: 1),
        PlacedDecor(id: 'r3', piece: DecorPiece.jars, shelf: 1, x: 0, seed: 2),
        PlacedDecor(id: 'r4', piece: DecorPiece.crock, shelf: 1, x: 1, seed: 1),
        PlacedDecor(id: 'r5', piece: DecorPiece.daisies, shelf: 2, x: 0),
        PlacedDecor(id: 'r6', piece: DecorPiece.pot, shelf: 2, x: 1, seed: 2),
      ],
    ),
  ),
];

const shelfStyleKey = 'library.shelf';

final shelfStyleProvider = StreamProvider<ShelfStyle>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(shelfStyleKey).map(ShelfStyle.fromJson);
});

Future<void> saveShelfStyle(WidgetRef ref, ShelfStyle style) =>
    ref.read(preferencesRepositoryProvider).writeJson(shelfStyleKey, style.toJson());
