import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_image_store.dart' as device;

/// Persists user photos (scan thumbnails, recipe covers).
abstract interface class ImageStore {
  /// Returns the stored path, or null if photos can't be kept on this platform.
  Future<String?> persist(Uint8List bytes, {required String folder, required String fileName});
  Future<void> delete(String? path);
}

/// App-documents storage on native platforms; no-op on the web.
class DeviceImageStore implements ImageStore {
  const DeviceImageStore();

  @override
  Future<String?> persist(Uint8List bytes, {required String folder, required String fileName}) =>
      device.persistLocalImage(bytes, folder: folder, fileName: fileName);

  @override
  Future<void> delete(String? path) => device.deleteLocalImage(path);
}

/// Keeps nothing. Used in tests and previews.
class NoopImageStore implements ImageStore {
  const NoopImageStore();

  @override
  Future<String?> persist(Uint8List bytes, {required String folder, required String fileName}) async => null;

  @override
  Future<void> delete(String? path) async {}
}

final imageStoreProvider = Provider<ImageStore>((ref) => const DeviceImageStore());
