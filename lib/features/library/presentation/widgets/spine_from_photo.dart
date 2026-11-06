import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/media/local_image_store.dart';

/// The cloth a book is bound in to match its photo: the photo's strongest
/// colour, deepened so it reads as cloth and its gilt lettering stays
/// legible. [rgba] is raw pixel data, four bytes a pixel. Null when the
/// image is empty or fully transparent.
Color? clothFromPixels(Uint8List rgba) {
  // Twelve hue bins for colourful pixels; greys are tallied apart.
  final weight = List<double>.filled(12, 0);
  final r = List<double>.filled(12, 0), g = List<double>.filled(12, 0), b = List<double>.filled(12, 0);
  var greys = 0.0, gr = 0.0, gg = 0.0, gb = 0.0;
  for (var i = 0; i + 3 < rgba.length; i += 4) {
    if (rgba[i + 3] < 128) continue;
    final c = Color.fromARGB(255, rgba[i], rgba[i + 1], rgba[i + 2]);
    final hsl = HSLColor.fromColor(c);
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
  var best = 0;
  for (var i = 1; i < 12; i++) {
    if (weight[i] > weight[best]) best = i;
  }
  final Color picked;
  if (weight[best] > 0 && weight[best] * 4 >= greys * 0.15) {
    final w = weight[best];
    picked = Color.fromARGB(255, (r[best] / w).round(), (g[best] / w).round(), (b[best] / w).round());
  } else if (greys > 0) {
    picked = Color.fromARGB(255, (gr / greys).round(), (gg / greys).round(), (gb / greys).round());
  } else {
    return null;
  }
  final hsl = HSLColor.fromColor(picked);
  return hsl.withLightness(hsl.lightness.clamp(0.2, 0.38)).withSaturation(math.min(hsl.saturation, 0.62)).toColor();
}

/// Reads the photo at [source] (asset, web address or saved file) at a
/// thumbnail's size and picks its cloth. Null if it can't be read.
Future<Color?> clothFromPhoto(String source) async {
  final ImageProvider? provider = source.startsWith('http://') || source.startsWith('https://')
      ? NetworkImage(source)
      : source.startsWith('assets/')
      ? AssetImage(source)
      : localImageProvider(source);
  if (provider == null) return null;
  final stream = ResizeImage(provider, width: 32, height: 32).resolve(ImageConfiguration.empty);
  final done = Completer<ui.Image?>();
  final listener = ImageStreamListener(
    (info, _) => done.isCompleted ? null : done.complete(info.image.clone()),
    onError: (_, _) => done.isCompleted ? null : done.complete(null),
  );
  stream.addListener(listener);
  try {
    final image = await done.future.timeout(const Duration(seconds: 10), onTimeout: () => null);
    if (image == null) return null;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data == null ? null : clothFromPixels(data.buffer.asUint8List());
  } finally {
    stream.removeListener(listener);
  }
}
