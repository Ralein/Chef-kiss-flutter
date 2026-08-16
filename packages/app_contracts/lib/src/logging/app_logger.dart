import 'package:meta/meta.dart';

enum LogSeverity {
  debug,
  info,
  warning,
  error;

  String toShortString() => name.toUpperCase();
}

@immutable
class AppLog {
  final String event;
  final String feature;
  final LogSeverity severity;
  final String? correlationId;
  final String? failureCode;
  final String? capabilityState;
  final int? elapsedMs;
  final Map<String, Object?> metadata;
  final int timestamp;

  const AppLog({
    required this.event,
    required this.feature,
    required this.severity,
    this.correlationId,
    this.failureCode,
    this.capabilityState,
    this.elapsedMs,
    this.metadata = const {},
    required this.timestamp,
  });

  Map<String, Object?> toJson() {
    return {
      'event': event,
      'feature': feature,
      'severity': severity.toShortString(),
      if (correlationId != null) 'correlation_id': correlationId,
      if (failureCode != null) 'failure_code': failureCode,
      if (capabilityState != null) 'capability_state': capabilityState,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (metadata.isNotEmpty) 'metadata': metadata,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() =>
      '[${severity.toShortString()}][$feature] $event ${failureCode != null ? "($failureCode)" : ""} ${elapsedMs != null ? "${elapsedMs}ms" : ""}';
}

/// Redacts sensitive text, recipe content, and PII from telemetry and logs.
class Redactor {
  static const Set<String> _forbiddenKeys = {
    'title',
    'recipe_title',
    'ingredient',
    'ingredients',
    'instruction',
    'step_instruction',
    'notes',
    'body',
    'prompt',
    'transcript',
    'audio',
    'image',
    'path',
    'raw_text',
    'email',
    'name',
  };

  static Map<String, Object?> sanitizeMap(Map<String, Object?> input) {
    final sanitized = <String, Object?>{};
    for (final entry in input.entries) {
      final key = entry.key.toLowerCase();
      if (_forbiddenKeys.contains(key)) {
        sanitized[entry.key] = '[REDACTED]';
      } else if (entry.value is Map<String, Object?>) {
        sanitized[entry.key] = sanitizeMap(entry.value as Map<String, Object?>);
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }
}

abstract interface class AppLogger {
  void log(AppLog log);

  void debug(
    String event, {
    required String feature,
    Map<String, Object?> metadata = const {},
    String? correlationId,
  });

  void info(
    String event, {
    required String feature,
    Map<String, Object?> metadata = const {},
    String? correlationId,
    int? elapsedMs,
  });

  void warning(
    String event, {
    required String feature,
    String? failureCode,
    Map<String, Object?> metadata = const {},
    String? correlationId,
  });

  void error(
    String event, {
    required String feature,
    String? failureCode,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
    String? correlationId,
  });
}

class StandardAppLogger implements AppLogger {
  final void Function(AppLog log)? onLogOutput;

  const StandardAppLogger({this.onLogOutput});

  @override
  void log(AppLog appLog) {
    final sanitizedMetadata = Redactor.sanitizeMap(appLog.metadata);
    final sanitizedLog = AppLog(
      event: appLog.event,
      feature: appLog.feature,
      severity: appLog.severity,
      correlationId: appLog.correlationId,
      failureCode: appLog.failureCode,
      capabilityState: appLog.capabilityState,
      elapsedMs: appLog.elapsedMs,
      metadata: sanitizedMetadata,
      timestamp: appLog.timestamp,
    );

    if (onLogOutput != null) {
      onLogOutput!(sanitizedLog);
    } else {
      // In release/dev default to printing formatted string without leaking recipe content
      // ignore: avoid_print
      print(sanitizedLog.toString());
    }
  }

  @override
  void debug(
    String event, {
    required String feature,
    Map<String, Object?> metadata = const {},
    String? correlationId,
  }) {
    log(AppLog(
      event: event,
      feature: feature,
      severity: LogSeverity.debug,
      correlationId: correlationId,
      metadata: metadata,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
    ));
  }

  @override
  void info(
    String event, {
    required String feature,
    Map<String, Object?> metadata = const {},
    String? correlationId,
    int? elapsedMs,
  }) {
    log(AppLog(
      event: event,
      feature: feature,
      severity: LogSeverity.info,
      correlationId: correlationId,
      elapsedMs: elapsedMs,
      metadata: metadata,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
    ));
  }

  @override
  void warning(
    String event, {
    required String feature,
    String? failureCode,
    Map<String, Object?> metadata = const {},
    String? correlationId,
  }) {
    log(AppLog(
      event: event,
      feature: feature,
      severity: LogSeverity.warning,
      failureCode: failureCode,
      correlationId: correlationId,
      metadata: metadata,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
    ));
  }

  @override
  void error(
    String event, {
    required String feature,
    String? failureCode,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
    String? correlationId,
  }) {
    final meta = Map<String, Object?>.from(metadata);
    if (error != null) meta['error_type'] = error.runtimeType.toString();
    log(AppLog(
      event: event,
      feature: feature,
      severity: LogSeverity.error,
      failureCode: failureCode,
      correlationId: correlationId,
      metadata: meta,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
    ));
  }
}
