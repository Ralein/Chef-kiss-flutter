import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> persistLocalImage(Uint8List bytes, {required String folder, required String fileName}) async {
  try {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'media', folder));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } catch (_) {
    // Storage full or sandbox denied: the feature still works without a photo.
    return null;
  }
}

Future<void> deleteLocalImage(String? path) async {
  if (path == null || path.isEmpty) return;
  try {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  } catch (_) {}
}

ImageProvider? localImageProvider(String path) {
  final file = File(path);
  return file.existsSync() ? FileImage(file) : null;
}

bool get supportsLocalImages => true;
