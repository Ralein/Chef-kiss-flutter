import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

DatabaseConnection openDefaultConnection() {
  return DatabaseConnection(
    LazyDatabase(() async {
      String dbFolder;
      try {
        final docs = await getApplicationDocumentsDirectory();
        dbFolder = docs.path;
      } catch (_) {
        final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? Directory.current.path;
        dbFolder = p.join(home, '.chefs_kiss');
      }
      final dbDir = Directory(dbFolder);
      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }
      final file = File(p.join(dbDir.path, 'chefs_kiss.sqlite'));
      return NativeDatabase.createInBackground(file);
    }),
  );
}
