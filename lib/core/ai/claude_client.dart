import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:app_contracts/app_contracts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show parseHttpDate;

import 'ai_client.dart';
import 'ai_usage.dart';

/// Content blocks for a single user turn.
sealed class ClaudeContent {
  const ClaudeContent();
  Map<String, dynamic> toJson();
}

class ClaudeText extends ClaudeContent {
  final String text;
  const ClaudeText(this.text);

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

class ClaudeImage extends ClaudeContent {
  /// Supported by the API: image/jpeg, image/png, image/gif, image/webp.
  static const supportedMediaTypes = {'image/jpeg', 'image/png', 'image/gif', 'image/webp'};

  final Uint8List bytes;
  final String mediaType;

  ClaudeImage(this.bytes, this.mediaType) : assert(supportedMediaTypes.contains(mediaType));

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'source': {'type': 'base64', 'media_type': mediaType, 'data': base64Encode(bytes)},
      };
}

/// Connection settings. Either an [apiKey] (direct "bring your own key"
/// mode) or a [baseUri] pointing at the operator's proxy, which injects the
/// key server-side, must be provided.
class ClaudeConfig {
  static const defaultModel = 'claude-opus-5-5';
  static const apiVersion = '2026-10-21';
  static const fallbackBeta = 'server-side-fallback-2026-07-01';

  final Uri baseUri;
  final String? apiKey;
  final String? workspaceId;
  final Map<String, String> extraHeaders;
  final String model;

  /// Direct browser calls must opt in to CORS explicitly.
  final bool directBrowserAccess;

  /// Server-side refusal fallbacks (`fallbacks: "default"`). Recommended for
  /// Claude Opus 5.5; disable only if a proxy rejects the field.
  final bool serverFallbacks;
  final Duration timeout;
  final int maxRetries;

  const ClaudeConfig({
    required this.baseUri,
    this.apiKey,
    this.workspaceId,
    this.extraHeaders = const {},
    this.model = defaultModel,
    this.directBrowserAccess = false,
    this.serverFallbacks = true,
    this.timeout = const Duration(seconds: 150),
    this.maxRetries = 2,
  });

  static final Uri anthropicApi = Uri.parse('https://api.anthropic.com');
}

class ClaudeUsage {
  final int inputTokens;
  final int outputTokens;
  const ClaudeUsage(this.inputTokens, this.outputTokens);
}

class ClaudeJsonResponse {
  final Map<String, dynamic> json;
  final String model;
  final String? requestId;
  final ClaudeUsage usage;

  const ClaudeJsonResponse({required this.json, required this.model, required this.requestId, required this.usage});
}

/// Minimal Claude Messages API client (Dart has no official SDK).
///
/// Behaviour mirrors the official SDKs: up to [ClaudeConfig.maxRetries]
/// retries on 408/409/429/5xx and network errors, honouring `x-should-retry`,
/// `retry-after-ms` and `retry-after`, otherwise exponential backoff from
/// 0.5 s capped at 8 s with up to 25 % jitter.
class ClaudeClient implements AiClient {
  static const _maxServerRequestedWait = Duration(seconds: 30);

  final ClaudeConfig config;

  /// Told about every response, for the rate limit shown in Settings.
  final AiUsageMeter? meter;
  final http.Client _http;
  final Random _random;
  final Future<void> Function(Duration) _sleep;
  final AppLogger? _logger;

  ClaudeClient(
    this.config, {
    this.meter,
    http.Client? httpClient,
    Random? random,
    Future<void> Function(Duration)? sleep,
    AppLogger? logger,
  })  : _http = httpClient ?? http.Client(),
        _random = random ?? Random(),
        _sleep = sleep ?? Future<void>.delayed,
        _logger = logger;

  @override
  void close() => _http.close();

  /// Verifies credentials and model access with `GET /v1/models/{id}`,
  /// which costs no tokens.
  @override
  Future<Result<void, AppFailure>> checkAccess() async {
    try {
      final headers = _headers()..remove('content-type');
      final response =
          await _http.get(config.baseUri.resolve('/v1/models/${config.model}'), headers: headers).timeout(
                const Duration(seconds: 20),
              );
      meter?.record(response.statusCode, response.headers);
      if (response.statusCode == 200) return const Result.ok(null);
      return Result.err(_mapError(response));
    } on TimeoutException {
      return const Result.err(RemoteFailure(message: 'The AI service did not respond in time.'));
    } catch (_) {
      return const Result.err(NetworkUnavailableFailure(message: "Couldn't reach the AI service."));
    }
  }

  /// Sends one user turn and returns the model's JSON object, constrained by
  /// [schema] through structured outputs (`output_config.format`).
  @override
  Future<Result<ClaudeJsonResponse, AppFailure>> createStructured({
    required String system,
    required List<ClaudeContent> content,
    required Map<String, dynamic> schema,
    String effort = 'medium',
    int maxTokens = 16000,
    String feature = 'ai',
  }) async {
    final body = jsonEncode({
      'model': config.model,
      'max_tokens': maxTokens,
      'system': system,
      'messages': [
        {'role': 'user', 'content': content.map((c) => c.toJson()).toList()},
      ],
      'output_config': {
        'effort': effort,
        'format': {'type': 'json_schema', 'schema': schema},
      },
      if (config.serverFallbacks) 'fallbacks': 'default',
    });

    final started = DateTime.now();
    for (var attempt = 0;; attempt++) {
      http.Response response;
      try {
        response = await _http
            .post(config.baseUri.resolve('/v1/messages'), headers: _headers(), body: body)
            .timeout(config.timeout);
      } on TimeoutException {
        if (attempt < config.maxRetries) {
          await _sleep(_backoff(attempt));
          continue;
        }
        return const Result.err(RemoteFailure(
          message: 'The AI took too long to respond.',
          recoveryAction: 'Check your connection and try again.',
        ));
      } catch (e) {
        // Socket/DNS/TLS failures surface as ClientException or IOException.
        if (attempt < config.maxRetries) {
          await _sleep(_backoff(attempt));
          continue;
        }
        _logger?.warning('AI request failed before a response', feature: feature, metadata: {'error': '$e'});
        return const Result.err(NetworkUnavailableFailure(
          message: "Couldn't reach the AI service.",
          recoveryAction: 'Check your internet connection and try again.',
        ));
      }

      meter?.record(response.statusCode, response.headers);
      if (response.statusCode == 200) {
        _logger?.info(
          'AI request succeeded',
          feature: feature,
          elapsedMs: DateTime.now().difference(started).inMilliseconds,
          metadata: {'attempts': attempt + 1, 'request_id': response.headers['request-id']},
        );
        return _parseSuccess(response);
      }

      final wait = _retryDelay(response, attempt);
      if (wait != null && attempt < config.maxRetries) {
        await _sleep(wait);
        continue;
      }
      _logger?.warning('AI request failed', feature: feature, failureCode: '${response.statusCode}', metadata: {
        'request_id': response.headers['request-id'],
      });
      return Result.err(_mapError(response));
    }
  }

  Map<String, String> _headers() => {
        'content-type': 'application/json',
        'anthropic-version': ClaudeConfig.apiVersion,
        if (config.apiKey != null && config.apiKey!.isNotEmpty) 'x-api-key': config.apiKey!,
        if (config.workspaceId != null && config.workspaceId!.isNotEmpty) 'anthropic-workspace-id': config.workspaceId!,
        if (config.serverFallbacks) 'anthropic-beta': ClaudeConfig.fallbackBeta,
        if (config.directBrowserAccess) 'anthropic-dangerous-direct-browser-access': 'true',
        ...config.extraHeaders,
      };

  Result<ClaudeJsonResponse, AppFailure> _parseSuccess(http.Response response) {
    final Map<String, dynamic> message;
    try {
      message = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return const Result.err(RemoteFailure(message: 'The AI returned an unreadable response.'));
    }

    final stopReason = message['stop_reason'] as String?;
    if (stopReason == 'refusal') {
      final details = message['stop_details'];
      return Result.err(ContentRefusedFailure(category: details is Map ? details['category'] as String? : null));
    }
    if (stopReason == 'max_tokens') {
      return const Result.err(RemoteFailure(
        message: 'The AI response was cut off before it finished.',
        recoveryAction: 'Try again with a simpler request.',
      ));
    }

    // Structured output arrives in the text block(s); thinking blocks may precede it.
    final text = (message['content'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String? ?? '')
        .join();
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      return const Result.err(RemoteFailure(message: 'The AI returned data in an unexpected format.'));
    }
    if (decoded is! Map<String, dynamic>) {
      return const Result.err(RemoteFailure(message: 'The AI returned data in an unexpected format.'));
    }

    final usage = message['usage'] as Map<String, dynamic>? ?? const {};
    return Result.ok(ClaudeJsonResponse(
      json: decoded,
      model: message['model'] as String? ?? config.model,
      requestId: response.headers['request-id'],
      usage: ClaudeUsage((usage['input_tokens'] as num?)?.toInt() ?? 0, (usage['output_tokens'] as num?)?.toInt() ?? 0),
    ));
  }

  /// Delay before retrying [response], or null when it must not be retried.
  Duration? _retryDelay(http.Response response, int attempt) {
    final shouldRetry = response.headers['x-should-retry'];
    if (shouldRetry == 'false') return null;
    final status = response.statusCode;
    final retryable = shouldRetry == 'true' || status == 408 || status == 409 || status == 429 || status >= 500;
    if (!retryable) return null;

    final server = _serverRequestedDelay(response.headers);
    if (server != null) {
      // Don't keep a person staring at a spinner for minutes.
      return server <= _maxServerRequestedWait ? server : null;
    }
    return _backoff(attempt);
  }

  static Duration? _serverRequestedDelay(Map<String, String> headers) {
    final ms = double.tryParse(headers['retry-after-ms'] ?? '');
    if (ms != null && ms > 0) return Duration(microseconds: (ms * 1000).round());
    final raw = headers['retry-after'];
    if (raw == null) return null;
    final seconds = double.tryParse(raw);
    if (seconds != null && seconds > 0) return Duration(microseconds: (seconds * 1e6).round());
    try {
      final at = parseHttpDate(raw);
      final d = at.difference(DateTime.now().toUtc());
      return d.isNegative ? null : d;
    } catch (_) {
      return null;
    }
  }

  Duration _backoff(int attempt) {
    final base = min(0.5 * pow(2, attempt), 8.0);
    final jitter = 1 - _random.nextDouble() * 0.25;
    return Duration(microseconds: (base * jitter * 1e6).round());
  }

  AppFailure _mapError(http.Response response) {
    String? apiMessage;
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      apiMessage = (body is Map && body['error'] is Map) ? body['error']['message'] as String? : null;
    } catch (_) {}

    switch (response.statusCode) {
      case 401:
        return const AuthenticationFailure(statusCode: 401, message: 'The API key was not accepted.');
      case 403:
        return AuthenticationFailure(
          statusCode: 403,
          message: apiMessage ?? 'This API key is not allowed to use the AI model.',
        );
      case 404:
        return RemoteFailure(statusCode: 404, message: 'The AI model "${config.model}" is not available for this key.');
      case 413:
        return const ValidationFailure(
          message: 'That image is too large to analyze.',
          recoveryAction: 'Try a smaller photo or crop it closer to the food.',
        );
      case 429:
        return RateLimitedFailure(
          message: 'The AI service is rate limiting requests right now.',
          retryAfterSeconds: _serverRequestedDelay(response.headers)?.inSeconds,
          recoveryAction: 'Wait a moment and try again.',
        );
      case >= 500:
        return RemoteFailure(
          statusCode: response.statusCode,
          message: 'The AI service is temporarily unavailable.',
          recoveryAction: 'Try again in a minute.',
        );
      default:
        return RemoteFailure(
          statusCode: response.statusCode,
          message: apiMessage != null ? 'The AI request was rejected: $apiMessage' : 'The AI request was rejected.',
        );
    }
  }
}
