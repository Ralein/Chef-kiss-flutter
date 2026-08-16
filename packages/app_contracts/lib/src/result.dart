import 'package:meta/meta.dart';
import 'failures.dart';

/// Functional Result type representing either Success (T) or Failure (E).
@immutable
sealed class Result<T, E extends AppFailure> {
  const Result();

  const factory Result.ok(T value) = Success<T, E>;
  const factory Result.err(E failure) = Failure<T, E>;

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  T? get orNull => when(
        ok: (val) => val,
        err: (_) => null,
      );

  E? get error => when(
        ok: (_) => null,
        err: (f) => f,
      );

  E? get failureOrNull => error;

  T getOrElse(T Function(E failure) fallback) => when(
        ok: (val) => val,
        err: (err) => fallback(err),
      );

  R when<R>({
    required R Function(T value) ok,
    required R Function(E failure) err,
  });

  Result<R, E> map<R>(R Function(T value) transform) {
    return when(
      ok: (val) => Result.ok(transform(val)),
      err: (failure) => Result.err(failure),
    );
  }

  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) {
    return when(
      ok: (val) => transform(val),
      err: (failure) => Result.err(failure),
    );
  }
}

class Success<T, E extends AppFailure> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  R when<R>({
    required R Function(T value) ok,
    required R Function(E failure) err,
  }) =>
      ok(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

class Failure<T, E extends AppFailure> extends Result<T, E> {
  final E failure;

  const Failure(this.failure);

  @override
  R when<R>({
    required R Function(T value) ok,
    required R Function(E failure) err,
  }) =>
      err(failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failure($failure)';
}
