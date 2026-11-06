import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../core/media/local_image_store.dart';
import 'library_books.dart';

/// A photo's colours as a book's: a deep cloth, a lighter accent to print a
/// pattern in, and a third colour for small details. Picked from its most
/// vivid hues; a grey photo gives tones of grey. [rgba] is raw pixel data,
/// four bytes a pixel. Empty when there's nothing to go on.
List<Color> paletteFromPixels(Uint8List rgba) {
  // Twelve hue bins for colourful pixels; greys are tallied apart.
  final weight = List<double>.filled(12, 0);
  final r = List<double>.filled(12, 0), g = List<double>.filled(12, 0), b = List<double>.filled(12, 0);
  var greys = 0.0, gr = 0.0, gg = 0.0, gb = 0.0;
  for (var i = 0; i + 3 < rgba.length; i += 4) {
    if (rgba[i + 3] < 128) continue;
    final hsl = HSLColor.fromColor(Color.fromARGB(255, rgba[i], rgba[i + 1], rgba[i + 2]));
    // Vivid, mid-light pixels say most about a photo's colour.
    final w = hsl.saturation * (1 - (hsl.lightness - 0.5).abs() * 2);
    if (w < 0.08) {
      greys += 1;
      gr += rgba[i];
      gg += rgba[i + 1];
      gb += rgba[i + 2];
      continue;
    }
    final bin = (hsl.hue / 30).floor() % 12;
    weight[bin] += w;
    r[bin] += rgba[i] * w;
    g[bin] += rgba[i + 1] * w;
    b[bin] += rgba[i + 2] * w;
  }
  Color average(int bin) => Color.fromARGB(
    255,
    (r[bin] / weight[bin]).round(),
    (g[bin] / weight[bin]).round(),
    (b[bin] / weight[bin]).round(),
  );

  // Up to three hues, each at least 60° from the others.
  final order = List.generate(12, (i) => i)..sort((x, y) => weight[y].compareTo(weight[x]));
  final hues = <int>[];
  for (final bin in order) {
    if (weight[bin] <= 0 || weight[bin] * 4 < greys * 0.15) break;
    if (hues.every((h) => math.min((h - bin).abs(), 12 - (h - bin).abs()) >= 2)) hues.add(bin);
    if (hues.length == 3) break;
  }
  final List<Color> picked;
  if (hues.isNotEmpty) {
    picked = hues.map(average).toList();
  } else if (greys > 0) {
    picked = [Color.fromARGB(255, (gr / greys).round(), (gg / greys).round(), (gb / greys).round())];
  } else {
    return const [];
  }

  HSLColor hsl(Color c) => HSLColor.fromColor(c);
  final first = hsl(picked.first);
  // Fewer hues than parts: tones of the ones there are.
  final second = picked.length > 1 ? hsl(picked[1]) : first.withSaturation(first.saturation * 0.7);
  final third = picked.length > 2 ? hsl(picked[2]) : second.withHue((second.hue + 24) % 360);
  return [
    first.withLightness(first.lightness.clamp(0.2, 0.34)).withSaturation(math.min(first.saturation, 0.6)).toColor(),
    second.withLightness(second.lightness.clamp(0.62, 0.76)).withSaturation(math.min(second.saturation, 0.6)).toColor(),
    third.withLightness(third.lightness.clamp(0.46, 0.58)).withSaturation(math.min(third.saturation, 0.65)).toColor(),
  ];
}

/// Reads the photo at [source] (asset, web address or saved file) at a
/// thumbnail's size and picks its palette. Empty if it can't be read.
Future<List<Color>> paletteFromPhoto(String source) async {
  final ImageProvider? provider = source.startsWith('http://') || source.startsWith('https://')
      ? NetworkImage(source)
      : source.startsWith('assets/')
      ? AssetImage(source)
      : localImageProvider(source);
  if (provider == null) return const [];
  final stream = ResizeImage(provider, width: 32, height: 32).resolve(ImageConfiguration.empty);
  final done = Completer<ui.Image?>();
  final listener = ImageStreamListener(
    (info, _) => done.isCompleted ? null : done.complete(info.image.clone()),
    onError: (_, _) => done.isCompleted ? null : done.complete(null),
  );
  stream.addListener(listener);
  try {
    final image = await done.future.timeout(const Duration(seconds: 10), onTimeout: () => null);
    if (image == null) return const [];
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data == null ? const [] : paletteFromPixels(data.buffer.asUint8List());
  } finally {
    stream.removeListener(listener);
  }
}

/// A spine made from a palette: the cloth, then a printed pattern in one of
/// its other colours. [turn] steps through the patterns and accents, so
/// Shuffle can try each in turn.
BookStyle spineFromPalette(BookStyle style, List<String> palette, {int turn = 0}) {
  if (palette.isEmpty) return style;
  const patterns = SpinePattern.printed;
  final accents = palette.length > 1 ? palette.sublist(1) : [palette.first];
  return style.copyWith(
    spineColor: palette.first,
    accentColor: accents[(turn ~/ patterns.length) % accents.length],
    pattern: patterns[turn % patterns.length],
    clearTextColor: true,
  );
}

/// Hex strings for a palette.
List<String> paletteHex(List<Color> colors) => [for (final c in colors) colorToHex(c)];
