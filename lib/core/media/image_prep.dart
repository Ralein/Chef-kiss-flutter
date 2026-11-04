import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_contracts/app_contracts.dart';

/// Image bytes in a format the vision API accepts.
class PreparedImage {
  final Uint8List bytes;
  final String mediaType;

  const PreparedImage(this.bytes, this.mediaType);

  String get extension => switch (mediaType) {
        'image/png' => 'png',
        'image/gif' => 'gif',
        'image/webp' => 'webp',
        _ => 'jpg',
      };
}

/// Normalizes a picked photo for upload.
///
/// Camera/gallery pickers on mobile and web already return a resized JPEG, so
/// supported, reasonably sized images pass through untouched. Anything else
/// (HEIC from macOS, huge originals) is decoded with the Flutter engine,
/// downscaled so its long edge is at most [maxEdge], and re-encoded as PNG.
class ImagePrep {
  ImagePrep._();

  /// Keeps the base64 payload comfortably under the API's 10 MB per-image cap.
  static const int passThroughLimitBytes = 3 * 1024 * 1024;

  static String? sniffMediaType(Uint8List b) {
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return 'image/jpeg';
    if (b.length >= 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'image/png';
    if (b.length >= 6 && b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) return 'image/gif';
    if (b.length >= 12 &&
        b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 && // RIFF
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return 'image/webp';
    }
    return null;
  }

  static Future<Result<PreparedImage, AppFailure>> prepare(Uint8List raw, {int maxEdge = 1568}) async {
    if (raw.isEmpty) {
      return const Result.err(ValidationFailure(message: 'The photo was empty.'));
    }
    final sniffed = sniffMediaType(raw);
    if (sniffed != null && raw.length <= passThroughLimitBytes) {
      return Result.ok(PreparedImage(raw, sniffed));
    }

    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(raw);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final longEdge = descriptor.width > descriptor.height ? descriptor.width : descriptor.height;
      final scale = longEdge > maxEdge ? maxEdge / longEdge : 1.0;
      final codec = await descriptor.instantiateCodec(
        targetWidth: (descriptor.width * scale).round(),
        targetHeight: (descriptor.height * scale).round(),
      );
      final frame = await codec.getNextFrame();
      final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      frame.image.dispose();
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
      if (png == null) throw const FormatException('encode failed');
      return Result.ok(PreparedImage(png.buffer.asUint8List(), 'image/png'));
    } catch (_) {
      return const Result.err(ValidationFailure(
        message: "That image format isn't supported.",
        recoveryAction: 'Use a JPEG, PNG or WebP photo.',
      ));
    }
  }
}
