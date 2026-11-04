import 'dart:typed_data';
import 'package:flutter/widgets.dart';

Future<String?> persistLocalImage(Uint8List bytes, {required String folder, required String fileName}) async => null;

Future<void> deleteLocalImage(String? path) async {}

ImageProvider? localImageProvider(String path) => null;

bool get supportsLocalImages => false;
