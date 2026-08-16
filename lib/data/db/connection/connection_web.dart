import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openDefaultConnection() {
  return DatabaseConnection(
    LazyDatabase(() async {
      final result = await WasmDatabase.open(
        databaseName: 'chefs_kiss_web',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    }),
  );
}
