import 'package:meta/meta.dart';

/// Sealed hierarchy of application failures with safe user messages and recovery hints.
@immutable
sealed class AppFailure {
  final String message;
  final String? recoveryAction;
  final String code;

  const AppFailure({
    required this.message,
    this.recoveryAction,
    required this.code,
  });

  @override
  String toString() => 'AppFailure($code): $message (recovery: $recoveryAction)';
}

class ValidationFailure extends AppFailure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.recoveryAction = 'Please correct the highlighted fields and try again.',
  }) : super(code: 'VALIDATION_ERROR');
}

class NotFoundFailure extends AppFailure {
  final String resourceType;
  final String resourceId;

  const NotFoundFailure({
    required this.resourceType,
    required this.resourceId,
    super.message = 'The requested item could not be found.',
    super.recoveryAction = 'Return to the recipe library.',
  }) : super(code: 'NOT_FOUND');
}

class PermissionDeniedFailure extends AppFailure {
  final String capability;

  const PermissionDeniedFailure({
    required this.capability,
    super.message = 'Permission is required to use this feature.',
    super.recoveryAction = 'You can grant permission in device Settings, or continue with manual controls.',
  }) : super(code: 'PERMISSION_DENIED');
}

class CapabilityUnavailableFailure extends AppFailure {
  final String capability;
  final String reason;

  const CapabilityUnavailableFailure({
    required this.capability,
    required this.reason,
    super.message = 'This capability is not available on your device or browser.',
    super.recoveryAction = 'Use standard on-screen buttons.',
  }) : super(code: 'CAPABILITY_UNAVAILABLE');
}

class StorageFailure extends AppFailure {
  final Object? cause;

  const StorageFailure({
    required super.message,
    this.cause,
    super.recoveryAction = 'Check available storage or restart the app.',
  }) : super(code: 'STORAGE_ERROR');
}

class NetworkUnavailableFailure extends AppFailure {
  const NetworkUnavailableFailure({
    super.message = 'You are currently offline.',
    super.recoveryAction = 'All saved recipes are available offline. AI tasks will resume when connected.',
  }) : super(code: 'NETWORK_UNAVAILABLE');
}

class RemoteFailure extends AppFailure {
  final int? statusCode;

  const RemoteFailure({
    required super.message,
    this.statusCode,
    super.recoveryAction = 'Try again later or continue editing manually.',
  }) : super(code: 'REMOTE_ERROR');
}

class RateLimitedFailure extends AppFailure {
  final int? retryAfterSeconds;

  const RateLimitedFailure({
    super.message = 'Daily or monthly usage limit reached.',
    this.retryAfterSeconds,
    super.recoveryAction = 'Try again tomorrow or create your recipe manually.',
  }) : super(code: 'RATE_LIMITED');
}

class SafetyReviewRequiredFailure extends AppFailure {
  final List<String> flaggedTerms;

  const SafetyReviewRequiredFailure({
    required this.flaggedTerms,
    super.message = 'Safety or allergen ambiguity requires manual confirmation.',
    super.recoveryAction = 'Review and confirm the safety notes before cooking.',
  }) : super(code: 'SAFETY_REVIEW_REQUIRED');
}

class ConflictFailure extends AppFailure {
  final String conflictingVersionId;

  const ConflictFailure({
    required this.conflictingVersionId,
    super.message = 'This recipe was modified elsewhere.',
    super.recoveryAction = 'Review the conflicting draft.',
  }) : super(code: 'CONFLICT');
}

class CancelledFailure extends AppFailure {
  const CancelledFailure({
    super.message = 'Operation was cancelled.',
    super.recoveryAction,
  }) : super(code: 'CANCELLED');
}

class UnexpectedFailure extends AppFailure {
  final Object? error;
  final StackTrace? stackTrace;

  const UnexpectedFailure({
    required super.message,
    this.error,
    this.stackTrace,
    super.recoveryAction = 'An unexpected error occurred. Please try again.',
  }) : super(code: 'UNEXPECTED');
}
