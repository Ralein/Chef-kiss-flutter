import 'package:flutter/material.dart';

import '../../domain/shelf_style.dart';
import 'kitchen_art.dart';
import 'shelf_art.dart';

/// The art for one decoration, filling the box it is given.
class DecorArt extends StatelessWidget {
  final DecorPiece piece;
  final int seed;
  final bool flipped;

  const DecorArt(this.piece, {super.key, this.seed = 0, this.flipped = false});

  @override
  Widget build(BuildContext context) {
    final art = switch (piece) {
      DecorPiece.crock => UtensilCrock(seed: seed),
      DecorPiece.rail => HangingUtensils(seed: seed),
      DecorPiece.jars => PantryJars(seed: seed),
      DecorPiece.pot => DutchOven(seed: seed),
      DecorPiece.kettle => Kettle(seed: seed),
      DecorPiece.bottles => OilBottles(seed: seed),
      DecorPiece.mortar => MortarAndPestle(seed: seed),
      DecorPiece.plant => PottedPlant(seed: seed),
      DecorPiece.herbs => HerbPot(seed: seed),
      DecorPiece.ivy => TrailingIvy(seed: seed),
      DecorPiece.roses => FlowerVase(kind: FlowerKind.roses, seed: seed),
      DecorPiece.sunflowers => FlowerVase(kind: FlowerKind.sunflowers, seed: seed),
      DecorPiece.hydrangeas => FlowerVase(kind: FlowerKind.hydrangeas, seed: seed),
      DecorPiece.daisies => FlowerVase(kind: FlowerKind.daisies, seed: seed),
      DecorPiece.pillar => Candle(kind: CandleKind.pillar, seed: seed),
      DecorPiece.tallCandle => Candle(kind: CandleKind.tall, seed: seed),
      DecorPiece.candlePair => CandlePair(seed: seed),
    };
    return flipped ? Transform.flip(flipX: true, child: art) : art;
  }
}
