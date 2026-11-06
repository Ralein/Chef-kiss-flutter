import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart' show parseHttpDate;

/// How much this session has asked of the AI service, and what the service
/// last said about its rate limit.
@immutable
class AiUsage {
  /// Requests sent since the app started.
  final int requests;

  /// The service's request limit and what is left of it, when it says.
  final int? limit;
  final int? remaining;

  /// When the limit window starts over, when the service says.
  final DateTime? resetsAt;

  /// Set after the service turned a request away for going too fast.
  final DateTime? limitedUntil;

  const AiUsage({this.requests = 0, this.limit, this.remaining, this.resetsAt, this.limitedUntil});

  static const none = AiUsage();

  bool limitedAt(DateTime now) => limitedUntil != null && limitedUntil!.isAfter(now);
}

/// Collects [AiUsage] from every AI response's status and headers.
class AiUsageMeter extends ChangeNotifier {
  AiUsageMeter({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  AiUsage _usage = AiUsage.none;

  AiUsage get usage => _usage;

  /// Notes one response: its [status] and rate-limit [headers] (lower-case
  /// names, as package:http gives them).
  void record(int status, Map<String, String> headers) {
    final now = _clock();
    final limit = _int(headers, const [
      'x-ratelimit-limit-requests',
      'anthropic-ratelimit-requests-limit',
      'ratelimit-limit',
      'x-ratelimit-limit',
    ]);
    final remaining = _int(headers, const [
      'x-ratelimit-remaining-requests',
      'anthropic-ratelimit-requests-remaining',
      'ratelimit-remaining',
      'x-ratelimit-remaining',
    ]);
    final reset = _reset(headers, now);
    final retryAfter = retryAfterOf(headers, now);
    _usage = AiUsage(
      requests: _usage.requests + 1,
      limit: limit ?? _usage.limit,
      remaining: remaining ?? (status == 429 ? 0 : _usage.remaining),
      resetsAt: reset ?? (limit == null ? _usage.resetsAt : null),
      limitedUntil: status == 429
          ? now.add(retryAfter ?? const Duration(minutes: 1))
          : (_usage.limitedAt(now) ? _usage.limitedUntil : null),
    );
    notifyListeners();
  }

  static int? _int(Map<String, String> headers, List<String> names) {
    for (final name in names) {
      final v = int.tryParse(headers[name]?.split(',').first.trim() ?? '');
      if (v != null) return v;
    }
    return null;
  }

  static DateTime? _reset(Map<String, String> headers, DateTime now) {
    // OpenAI style: a duration such as "6m0s" or "120ms".
    final span = parseSpan(headers['x-ratelimit-reset-requests']);
    if (span != null) return now.add(span);
    // Anthropic style: an RFC 3339 time.
    final at = DateTime.tryParse(headers['anthropic-ratelimit-requests-reset'] ?? '');
    if (at != null) return at.toLocal();
    // IETF style: seconds; some gateways send a Unix time instead.
    final raw = num.tryParse(headers['ratelimit-reset'] ?? headers['x-ratelimit-reset'] ?? '');
    if (raw == null) return null;
    return raw > 1e9
        ? DateTime.fromMillisecondsSinceEpoch((raw * 1000).round())
        : now.add(Duration(milliseconds: (raw * 1000).round()));
  }

  /// How long `retry-after` (or `retry-after-ms`) asks the client to wait.
  static Duration? retryAfterOf(Map<String, String> headers, DateTime now) {
    final ms = double.tryParse(headers['retry-after-ms'] ?? '');
    if (ms != null && ms > 0) return Duration(microseconds: (ms * 1000).round());
    final raw = headers['retry-after'];
    if (raw == null) return null;
    final seconds = double.tryParse(raw);
    if (seconds != null) return seconds > 0 ? Duration(microseconds: (seconds * 1e6).round()) : null;
    try {
      final d = parseHttpDate(raw).difference(now.toUtc());
      return d.isNegative ? null : d;
    } catch (_) {
      return null;
    }
  }

  /// Parses durations like "1m30s", "6m0s", "1.5s" or "120ms".
  static Duration? parseSpan(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = RegExp(r'(\d+(?:\.\d+)?)(ms|h|m|s)').allMatches(raw);
    if (parts.isEmpty) return null;
    var micros = 0.0;
    for (final p in parts) {
      final v = double.parse(p.group(1)!);
      micros += switch (p.group(2)) {
        'h' => v * 3.6e9,
        'm' => v * 6e7,
        's' => v * 1e6,
        _ => v * 1e3,
      };
    }
    return Duration(microseconds: micros.round());
  }
}

final aiUsageProvider = ChangeNotifierProvider<AiUsageMeter>((ref) => AiUsageMeter());
