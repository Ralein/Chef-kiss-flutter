import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// Texture painted on the wall behind the bookcase. The tiles make it a
/// kitchen; the rest a study.
enum WallStyle {
  subway('Subway tile'),
  zellige('Glazed tile'),
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

enum CandleAmount {
  none('None'),
  few('A few'),
  many('Lots');

  final String label;
  const CandleAmount(this.label);
}

enum Greenery {
  none('None'),
  potted('Potted plants'),
  lush('Plants & ivy'),
  ivy('Trailing ivy');

  final String label;
  const Greenery(this.label);
  bool get hasPots => this == potted || this == lush;
  bool get hasIvy => this == lush || this == ivy;
}

enum FlowerKind {
  none('None'),
  roses('Red roses'),
  sunflowers('Sunflowers'),
  hydrangeas('Hydrangeas'),
  daisies('Daisy jar');

  final String label;
  const FlowerKind(this.label);
}

/// Kitchen things between the books: a crock of spatulas, whisks and spoons
/// with a utensil rail under the shelves, pantry jars, or a cast-iron pot and
/// a cutting board.
enum Kitchenware {
  none('None'),
  utensils('Utensils'),
  pantry('Pantry jars'),
  cookware('Pots & boards'),
  everything('Everything');

  final String label;
  const Kitchenware(this.label);
  bool get hasUtensils => this == utensils || this == everything;
  bool get hasPantry => this == pantry || this == everything;
  bool get hasCookware => this == cookware || this == everything;
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
  final CandleAmount candles;
  final Greenery greenery;
  final FlowerKind flowers;
  final Kitchenware kitchen;

  const ShelfStyle({
    this.wall = WallStyle.subway,
    this.tint = 0,
    this.wood = ShelfWood.walnut,
    this.glow = ShelfGlow.warm,
    this.candles = CandleAmount.few,
    this.greenery = Greenery.lush,
    this.flowers = FlowerKind.none,
    this.kitchen = Kitchenware.everything,
  });

  Color get wallColor => wallTints[tint.clamp(0, wallTints.length - 1)].color;

  /// Dark walls get light text and the dark theme for the controls on them.
  bool get isDark => wallColor.computeLuminance() < 0.25;

  ShelfStyle copyWith({
    WallStyle? wall,
    int? tint,
    ShelfWood? wood,
    ShelfGlow? glow,
    CandleAmount? candles,
    Greenery? greenery,
    FlowerKind? flowers,
    Kitchenware? kitchen,
  }) => ShelfStyle(
    wall: wall ?? this.wall,
    tint: tint ?? this.tint,
    wood: wood ?? this.wood,
    glow: glow ?? this.glow,
    candles: candles ?? this.candles,
    greenery: greenery ?? this.greenery,
    flowers: flowers ?? this.flowers,
    kitchen: kitchen ?? this.kitchen,
  );

  Map<String, dynamic> toJson() => {
    'wall': wall.name,
    'tint': tint,
    'wood': wood.name,
    'glow': glow.name,
    'candles': candles.name,
    'greenery': greenery.name,
    'flowers': flowers.name,
    'kitchen': kitchen.name,
  };

  factory ShelfStyle.fromJson(Object? json) {
    if (json is! Map) return const ShelfStyle();
    final tint = json['tint'];
    return ShelfStyle(
      wall: _byName(WallStyle.values, json['wall'], WallStyle.subway),
      tint: tint is int && tint >= 0 && tint < wallTints.length ? tint : 0,
      wood: _byName(ShelfWood.values, json['wood'], ShelfWood.walnut),
      glow: _byName(ShelfGlow.values, json['glow'], ShelfGlow.warm),
      candles: _byName(CandleAmount.values, json['candles'], CandleAmount.few),
      greenery: _byName(Greenery.values, json['greenery'], Greenery.lush),
      flowers: _byName(FlowerKind.values, json['flowers'], FlowerKind.none),
      kitchen: _byName(Kitchenware.values, json['kitchen'], Kitchenware.everything),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShelfStyle &&
      other.wall == wall &&
      other.tint == tint &&
      other.wood == wood &&
      other.glow == glow &&
      other.candles == candles &&
      other.greenery == greenery &&
      other.flowers == flowers &&
      other.kitchen == kitchen;

  @override
  int get hashCode => Object.hash(wall, tint, wood, glow, candles, greenery, flowers, kitchen);
}

const shelfStyleKey = 'library.shelf';

final shelfStyleProvider = StreamProvider<ShelfStyle>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(shelfStyleKey).map(ShelfStyle.fromJson);
});

Future<void> saveShelfStyle(WidgetRef ref, ShelfStyle style) =>
    ref.read(preferencesRepositoryProvider).writeJson(shelfStyleKey, style.toJson());
