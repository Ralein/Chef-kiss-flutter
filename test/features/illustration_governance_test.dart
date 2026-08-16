import 'package:test/test.dart';
import 'package:chefs_kiss/features/illustrations/data/illustration_governance_service.dart';

void main() {
  group('IllustrationGovernanceService', () {
    late IllustrationGovernanceService service;

    setUp(() {
      service = IllustrationGovernanceService(initialCandidates: []);
    });

    test('candidate lifecycle: submit -> pending -> approve -> resolved', () async {
      // 1. Submit candidate
      final submitRes = await service.submitCandidate(
        subjectKey: 'culinary.soup.ramen',
        assetPath: 'assets/illustrations/ramen.webp',
        promptTemplate: 'Editorial linocut of steaming bowl of tonkotsu ramen with soft egg',
      );

      expect(submitRes.isSuccess, isTrue);
      final candidate = submitRes.orNull!;
      expect(candidate.status, equals(AssetApprovalStatus.pending));
      expect(candidate.subjectKey, equals('culinary.soup.ramen'));

      // Pending candidate must NOT resolve as approved
      expect(service.getApprovedAssetPath('culinary.soup.ramen'), isNull);

      // 2. Approve candidate
      final approveRes = await service.approveCandidate(candidate.id);
      expect(approveRes.isSuccess, isTrue);
      expect(approveRes.orNull!.status, equals(AssetApprovalStatus.approved));

      // Approved candidate resolves accurately
      expect(service.getApprovedAssetPath('culinary.soup.ramen'), equals('assets/illustrations/ramen.webp'));
    });

    test('rejection prevents approval and resolution', () async {
      final submitRes = await service.submitCandidate(
        subjectKey: 'culinary.dessert.flan',
        assetPath: 'assets/illustrations/flan.webp',
      );

      final candidate = submitRes.orNull!;
      final rejectRes = await service.rejectCandidate(candidate.id);
      expect(rejectRes.isSuccess, isTrue);
      expect(rejectRes.orNull!.status, equals(AssetApprovalStatus.rejected));

      expect(service.getApprovedAssetPath('culinary.dessert.flan'), isNull);
    });

    test('deletion removes candidate from registry', () async {
      final submitRes = await service.submitCandidate(
        subjectKey: 'culinary.salad.caesar',
        assetPath: 'assets/illustrations/caesar.webp',
      );

      final candidate = submitRes.orNull!;
      final delRes = await service.deleteCandidate(candidate.id);
      expect(delRes.isSuccess, isTrue);

      final list = service.getCandidates();
      expect(list.isEmpty, isTrue);
    });
  });
}
