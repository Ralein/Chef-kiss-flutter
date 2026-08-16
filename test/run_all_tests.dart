import 'data/drift_database_test.dart' as db_test;
import 'data/cooking_session_repository_test.dart' as session_test;
import 'data/drift_backup_test.dart' as backup_test;
import 'features/import_pipeline_test.dart' as import_test;
import 'features/voice_cook_assistant_test.dart' as voice_test;
import 'features/illustration_governance_test.dart' as governance_test;
import 'sync/cloud_encryption_test.dart' as encryption_test;
import 'sync/sync_convergence_test.dart' as sync_test;

void main() {
  db_test.main();
  session_test.main();
  backup_test.main();
  import_test.main();
  voice_test.main();
  governance_test.main();
  encryption_test.main();
  sync_test.main();
}
