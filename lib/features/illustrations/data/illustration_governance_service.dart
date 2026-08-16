import 'dart:async';
import 'package:meta/meta.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';

enum AssetApprovalStatus {
  pending,
  approved,
  rejected;
}

@immutable
class IllustrationCandidate {
  final String id;
  final String subjectKey;
  final String styleVersion;
  final String assetPath;
  final AssetApprovalStatus status;
  final String? promptTemplate;
  final int createdAt;
  final int? reviewedAt;

  const IllustrationCandidate({
    required this.id,
    required this.subjectKey,
    this.styleVersion = 'v1_linocut',
    required this.assetPath,
    this.status = AssetApprovalStatus.pending,
    this.promptTemplate,
    required this.createdAt,
    this.reviewedAt,
  });

  IllustrationCandidate copyWith({
    String? id,
    String? subjectKey,
    String? styleVersion,
    String? assetPath,
    AssetApprovalStatus? status,
    String? promptTemplate,
    int? createdAt,
    int? reviewedAt,
  }) {
    return IllustrationCandidate(
      id: id ?? this.id,
      subjectKey: subjectKey ?? this.subjectKey,
      styleVersion: styleVersion ?? this.styleVersion,
      assetPath: assetPath ?? this.assetPath,
      status: status ?? this.status,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectKey': subjectKey,
        'styleVersion': styleVersion,
        'assetPath': assetPath,
        'status': status.name,
        'promptTemplate': promptTemplate,
        'createdAt': createdAt,
        'reviewedAt': reviewedAt,
      };

  factory IllustrationCandidate.fromJson(Map<String, dynamic> json) => IllustrationCandidate(
        id: json['id'] as String,
        subjectKey: json['subjectKey'] as String,
        styleVersion: json['styleVersion'] as String? ?? 'v1_linocut',
        assetPath: json['assetPath'] as String,
        status: AssetApprovalStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AssetApprovalStatus.pending,
        ),
        promptTemplate: json['promptTemplate'] as String?,
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
        reviewedAt: (json['reviewedAt'] as num?)?.toInt(),
      );
}

class IllustrationGovernanceService {
  final Uuid _uuid = const Uuid();
  final List<IllustrationCandidate> _candidates = [];
  final StreamController<List<IllustrationCandidate>> _candidatesController =
      StreamController<List<IllustrationCandidate>>.broadcast();

  IllustrationGovernanceService({List<IllustrationCandidate>? initialCandidates}) {
    if (initialCandidates != null) {
      _candidates.addAll(initialCandidates);
    } else {
      // Seed default candidate for testing review queue
      _candidates.add(IllustrationCandidate(
        id: 'cand_art_1',
        subjectKey: 'culinary.pasta.tagliatelle',
        styleVersion: 'v1_linocut',
        assetPath: 'assets/illustrations/pasta.webp',
        status: AssetApprovalStatus.pending,
        promptTemplate: 'Editorial linocut illustration of fresh tagliatelle nests with semolina dusting',
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch - 3600000,
      ));
    }
    _candidatesController.add(List.unmodifiable(_candidates));
  }

  Stream<List<IllustrationCandidate>> watchCandidates() async* {
    yield List.unmodifiable(_candidates);
    yield* _candidatesController.stream;
  }

  List<IllustrationCandidate> getCandidates({AssetApprovalStatus? statusFilter}) {
    if (statusFilter == null) return List.unmodifiable(_candidates);
    return List.unmodifiable(_candidates.where((c) => c.status == statusFilter));
  }

  Future<Result<IllustrationCandidate, AppFailure>> submitCandidate({
    required String subjectKey,
    required String assetPath,
    String? promptTemplate,
    String styleVersion = 'v1_linocut',
  }) async {
    final candidate = IllustrationCandidate(
      id: 'cand_${_uuid.v4().substring(0, 8)}',
      subjectKey: subjectKey.trim().toLowerCase(),
      styleVersion: styleVersion,
      assetPath: assetPath,
      status: AssetApprovalStatus.pending,
      promptTemplate: promptTemplate,
      createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    _candidates.add(candidate);
    _candidatesController.add(List.unmodifiable(_candidates));
    return Result.ok(candidate);
  }

  Future<Result<IllustrationCandidate, AppFailure>> approveCandidate(String candidateId) async {
    final idx = _candidates.indexWhere((c) => c.id == candidateId);
    if (idx == -1) {
      return Result.err(NotFoundFailure(resourceType: 'IllustrationCandidate', resourceId: candidateId));
    }

    final updated = _candidates[idx].copyWith(
      status: AssetApprovalStatus.approved,
      reviewedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    _candidates[idx] = updated;
    _candidatesController.add(List.unmodifiable(_candidates));
    return Result.ok(updated);
  }

  Future<Result<IllustrationCandidate, AppFailure>> rejectCandidate(String candidateId) async {
    final idx = _candidates.indexWhere((c) => c.id == candidateId);
    if (idx == -1) {
      return Result.err(NotFoundFailure(resourceType: 'IllustrationCandidate', resourceId: candidateId));
    }

    final updated = _candidates[idx].copyWith(
      status: AssetApprovalStatus.rejected,
      reviewedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    _candidates[idx] = updated;
    _candidatesController.add(List.unmodifiable(_candidates));
    return Result.ok(updated);
  }

  Future<Result<bool, AppFailure>> deleteCandidate(String candidateId) async {
    _candidates.removeWhere((c) => c.id == candidateId);
    _candidatesController.add(List.unmodifiable(_candidates));
    return Result.ok(true);
  }

  /// Checks whether a subjectKey has an approved generated asset
  String? getApprovedAssetPath(String subjectKey) {
    final key = subjectKey.trim().toLowerCase();
    final match = _candidates.firstWhere(
      (c) => c.subjectKey == key && c.status == AssetApprovalStatus.approved,
      orElse: () => const IllustrationCandidate(
        id: '',
        subjectKey: '',
        assetPath: '',
        createdAt: 0,
      ),
    );
    return match.assetPath.isNotEmpty ? match.assetPath : null;
  }

  void dispose() {
    _candidatesController.close();
  }
}
