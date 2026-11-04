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

DatabaseConnection openInMemoryConnection() {
  // In-memory databases are only used by tests and previews, which run on the
  // VM. Fail loudly rather than silently persisting to IndexedDB.
  throw UnsupportedError('In-memory databases are not supported on the web build.');
}
