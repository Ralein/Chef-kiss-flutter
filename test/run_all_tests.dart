import 'data/drift_database_test.dart' as db_test;
import 'data/cooking_session_repository_test.dart' as session_test;
import 'data/drift_backup_test.dart' as backup_test;
import 'features/import_pipeline_test.dart' as import_test;
import 'features/voice_cook_assistant_test.dart' as voice_test;

void main() {
  db_test.main();
  session_test.main();
  backup_test.main();
  import_test.main();
  voice_test.main();
}
