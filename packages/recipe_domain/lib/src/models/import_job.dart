import 'package:meta/meta.dart';
import 'recipe.dart';

enum ImportSourceKind {
  image,
  pdf,
  text,
  url,
  dictation;

  static ImportSourceKind fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'image':
      case 'photo':
      case 'camera':
        return ImportSourceKind.image;
      case 'pdf':
        return ImportSourceKind.pdf;
      case 'url':
      case 'web':
        return ImportSourceKind.url;
      case 'dictation':
      case 'voice':
        return ImportSourceKind.dictation;
      case 'text':
      default:
        return ImportSourceKind.text;
    }
  }
}

enum ImportStatus {
  queued,
  preprocessing,
  extracting,
  reviewRequired,
  completed,
  failed;

  static ImportStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'queued':
        return ImportStatus.queued;
      case 'preprocessing':
        return ImportStatus.preprocessing;
      case 'extracting':
        return ImportStatus.extracting;
      case 'review_required':
      case 'reviewrequired':
        return ImportStatus.reviewRequired;
      case 'completed':
        return ImportStatus.completed;
      case 'failed':
      default:
        return ImportStatus.failed;
    }
  }

  String toDbString() {
    switch (this) {
      case ImportStatus.queued:
        return 'queued';
      case ImportStatus.preprocessing:
        return 'preprocessing';
      case ImportStatus.extracting:
        return 'extracting';
      case ImportStatus.reviewRequired:
        return 'review_required';
      case ImportStatus.completed:
        return 'completed';
      case ImportStatus.failed:
        return 'failed';
    }
  }
}

/// A field with an extraction confidence score and evidence references
@immutable
class ExtractedField<T> {
  final T value;
  final double confidence; // 0.0 to 1.0
  final List<String> evidence;
  final bool isAmbiguous;

  const ExtractedField({
    required this.value,
    this.confidence = 1.0,
    this.evidence = const [],
    this.isAmbiguous = false,
  });

  bool get isHighConfidence => confidence >= 0.85;
  bool get isMediumConfidence => confidence >= 0.60 && confidence < 0.85;
  bool get isLowConfidence => confidence < 0.60;

  ExtractedField<T> copyWith({
    T? value,
    double? confidence,
    List<String>? evidence,
    bool? isAmbiguous,
  }) {
    return ExtractedField<T>(
      value: value ?? this.value,
      confidence: confidence ?? this.confidence,
      evidence: evidence ?? this.evidence,
      isAmbiguous: isAmbiguous ?? this.isAmbiguous,
    );
  }

  @override
  String toString() => 'ExtractedField($value, conf: ${(confidence * 100).toStringAsFixed(0)}%)';
}

/// Represents the raw captured source for an import
@immutable
class ImportSource {
  final String id;
  final ImportSourceKind kind;
  final String? localFilePath;
  final String? rawText;
  final String? sourceUrl;
  final String sha256Checksum;
  final int byteSize;
  final int createdAt;

  const ImportSource({
    required this.id,
    required this.kind,
    this.localFilePath,
    this.rawText,
    this.sourceUrl,
    required this.sha256Checksum,
    required this.byteSize,
    required this.createdAt,
  });
}

/// Represents an active or completed import job
@immutable
class ImportJob {
  final String id;
  final String profileId;
  final ImportSource source;
  final ImportStatus status;
  final Recipe? extractedDraft;
  final double overallConfidence;
  final List<String> warnings;
  final List<String> reviewQuestions;
  final String? failureReason;
  final int createdAt;
  final int updatedAt;

  const ImportJob({
    required this.id,
    required this.profileId,
    required this.source,
    this.status = ImportStatus.queued,
    this.extractedDraft,
    this.overallConfidence = 0.0,
    this.warnings = const [],
    this.reviewQuestions = const [],
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  ImportJob copyWith({
    String? id,
    String? profileId,
    ImportSource? source,
    ImportStatus? status,
    Recipe? extractedDraft,
    double? overallConfidence,
    List<String>? warnings,
    List<String>? reviewQuestions,
    String? failureReason,
    int? createdAt,
    int? updatedAt,
  }) {
    return ImportJob(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      status: status ?? this.status,
      extractedDraft: extractedDraft ?? this.extractedDraft,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      warnings: warnings ?? this.warnings,
      reviewQuestions: reviewQuestions ?? this.reviewQuestions,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
