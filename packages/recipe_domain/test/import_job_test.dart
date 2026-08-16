import 'package:test/test.dart';
import 'package:recipe_domain/recipe_domain.dart';

void main() {
  group('ImportJob & ExtractedField', () {
    test('confidence level categorisation works as expected', () {
      const highField = ExtractedField<String>(value: 'Chocolate Cake', confidence: 0.95);
      const medField = ExtractedField<String>(value: '2 cups sugar', confidence: 0.75);
      const lowField = ExtractedField<String>(value: 'bake until done', confidence: 0.40);

      expect(highField.isHighConfidence, isTrue);
      expect(medField.isMediumConfidence, isTrue);
      expect(lowField.isLowConfidence, isTrue);
    });

    test('state transitions and status string conversions', () {
      final source = ImportSource(
        id: 'src_1',
        kind: ImportSourceKind.text,
        rawText: 'Grandma’s Apple Pie',
        sha256Checksum: 'abcdef123456',
        byteSize: 200,
        createdAt: 1000,
      );

      final job = ImportJob(
        id: 'job_1',
        profileId: 'default',
        source: source,
        status: ImportStatus.queued,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(job.status, equals(ImportStatus.queued));
      expect(job.status.toDbString(), equals('queued'));

      final processing = job.copyWith(status: ImportStatus.extracting);
      expect(processing.status, equals(ImportStatus.extracting));
    });
  });
}
