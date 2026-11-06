import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_contracts/app_contracts.dart';
import 'package:http/http.dart' as http;

import 'ai_client.dart';
import 'ai_usage.dart';
import 'claude_client.dart';

/// Where an OpenAI-compatible gateway listens, and which of its models to use.
class GatewayConfig {
  /// The gateway's address, e.g. `http://192.168.1.20:18899`. A trailing
  /// `/v1` is optional.
  final Uri baseUri;

  /// Sent as `Authorization: Bearer …`; gateways on a trusted network may
  /// not need one.
  final String? apiKey;
  final String model;
  final Duration timeout;
  final int maxRetries;

  const GatewayConfig({
    required this.baseUri,
    this.apiKey,
    required this.model,
    this.timeout = const Duration(seconds: 150),
    this.maxRetries = 2,
  });

  /// The address as typed, tidied: scheme added, `/v1` and slashes dropped.
  static Uri? parseAddress(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;
    if (!text.contains('://')) text = 'http://$text';
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty || !(uri.scheme == 'http' || uri.scheme == 'https')) return null;
    var path = uri.path.replaceAll(RegExp(r'/+$'), '');
    if (path.endsWith('/v1')) path = path.substring(0, path.length - 3);
    return uri.replace(path: path, query: null, fragment: null);
  }
}

/// A client for gateways that speak the OpenAI Chat Completions API — such
/// as a self-hosted free-model gateway, Ollama or LM Studio.
///
/// Structured answers are asked for in the prompt (with JSON mode when the
/// gateway supports it) and checked on arrival. Rate limits reported in
/// response headers, and 429 refusals, are passed to an [AiUsageMeter].
class GatewayClient implements AiClient {
  static const _maxServerRequestedWait = Duration(seconds: 30);

  final GatewayConfig config;
  final AiUsageMeter? meter;
  final http.Client _http;
  final Random _random;
  final Future<void> Function(Duration) _sleep;
  final AppLogger? _logger;

  GatewayClient(
    this.config, {
    this.meter,
    http.Client? httpClient,
    Random? random,
    Future<void> Function(Duration)? sleep,
    AppLogger? logger,
  }) : _http = httpClient ?? http.Client(),
       _random = random ?? Random(),
       _sleep = sleep ?? Future<void>.delayed,
       _logger = logger;

  @override
  void close() => _http.close();

  Uri _url(String path) {
    final base = config.baseUri;
    return base.replace(path: '${base.path}$path');
  }

  Map<String, String> get _headers => {
    'content-type': 'application/json',
    if (config.apiKey != null && config.apiKey!.isNotEmpty) 'authorization': 'Bearer ${config.apiKey}',
  };

  /// The gateway's models, by id.
  Future<Result<List<String>, AppFailure>> listModels() async {
    try {
      final response = await _http
          .get(_url('/v1/models'), headers: _headers..remove('content-type'))
          .timeout(const Duration(seconds: 15));
      meter?.record(response.statusCode, response.headers);
      if (response.statusCode != 200) return Result.err(_mapError(response));
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      final data = body is Map ? body['data'] : body;
      if (data is! List) {
        return const Result.err(RemoteFailure(message: 'The gateway listed its models in an unexpected format.'));
      }
      return Result.ok([
        for (final m in data)
          if (m is Map && m['id'] is String) m['id'] as String,
      ]);
    } on TimeoutException {
      return const Result.err(RemoteFailure(message: 'The gateway did not respond in time.'));
    } catch (_) {
      return const Result.err(
        NetworkUnavailableFailure(
          message: "Couldn't reach the gateway.",
          recoveryAction: 'Check its address, and that this device can reach it.',
        ),
      );
    }
  }

  @override
  Future<Result<void, AppFailure>> checkAccess() async {
    final res = await listModels();
    return res.flatMap((models) {
      if (models.isNotEmpty && !models.contains(config.model)) {
        return Result.err(RemoteFailure(message: 'The gateway no longer offers "${config.model}".'));
      }
      return const Result.ok(null);
    });
  }

  @override
  Future<Result<ClaudeJsonResponse, AppFailure>> createStructured({
    required String system,
    required List<ClaudeContent> content,
    required Map<String, dynamic> schema,
    String effort = 'medium',
    int maxTokens = 16000,
    String feature = 'ai',
  }) async {
    final hasImages = content.any((c) => c is ClaudeImage);
    final user = hasImages
        ? [
            for (final c in content)
              switch (c) {
                ClaudeText(:final text) => {'type': 'text', 'text': text},
                ClaudeImage(:final mediaType, :final bytes) => {
                  'type': 'image_url',
                  'image_url': {'url': 'data:$mediaType;base64,${base64Encode(bytes)}'},
                },
              },
          ]
        : content.whereType<ClaudeText>().map((t) => t.text).join('\n\n');
    var jsonMode = true;
    String body() => jsonEncode({
      'model': config.model,
      'max_tokens': maxTokens,
      'stream': false,
      'messages': [
        {
          'role': 'system',
          'content':
              '$system\n\nReply with only a JSON object that matches this JSON Schema, and nothing else:\n'
              '${jsonEncode(schema)}',
        },
        {'role': 'user', 'content': user},
      ],
      if (jsonMode) 'response_format': {'type': 'json_object'},
    });

    final started = DateTime.now();
    for (var attempt = 0; ; attempt++) {
      http.Response response;
      try {
        response = await _http.post(_url('/v1/chat/completions'), headers: _headers, body: body()).timeout(config.timeout);
      } on TimeoutException {
        if (attempt < config.maxRetries) {
          await _sleep(_backoff(attempt));
          continue;
        }
        return const Result.err(
          RemoteFailure(message: 'The AI took too long to respond.', recoveryAction: 'Try again in a moment.'),
        );
      } catch (e) {
        if (attempt < config.maxRetries) {
          await _sleep(_backoff(attempt));
          continue;
        }
        _logger?.warning('Gateway request failed before a response', feature: feature, metadata: {'error': '$e'});
        return const Result.err(
          NetworkUnavailableFailure(
            message: "Couldn't reach the AI gateway.",
            recoveryAction: 'Check that it is running and that this device can reach it.',
          ),
        );
      }
      meter?.record(response.statusCode, response.headers);

      if (response.statusCode == 200) {
        _logger?.info(
          'Gateway request succeeded',
          feature: feature,
          elapsedMs: DateTime.now().difference(started).inMilliseconds,
          metadata: {'attempts': attempt + 1},
        );
        return _parse(response);
      }
      // Some models don't do JSON mode: ask again without it.
      if (response.statusCode == 400 && jsonMode && utf8.decode(response.bodyBytes).contains('response_format')) {
        jsonMode = false;
        continue;
      }
      final wait = _retryDelay(response, attempt);
      if (wait != null && attempt < config.maxRetries) {
        await _sleep(wait);
        continue;
      }
      _logger?.warning('Gateway request failed', feature: feature, failureCode: '${response.statusCode}');
      return Result.err(_mapError(response));
    }
  }

  Result<ClaudeJsonResponse, AppFailure> _parse(http.Response response) {
    final Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return const Result.err(RemoteFailure(message: 'The AI returned an unreadable response.'));
    }
    final choice = (body['choices'] as List?)?.whereType<Map<String, dynamic>>().firstOrNull;
    final finish = choice?['finish_reason'] as String?;
    if (finish == 'content_filter') return const Result.err(ContentRefusedFailure());
    if (finish == 'length') {
      return const Result.err(
        RemoteFailure(
          message: 'The AI response was cut off before it finished.',
          recoveryAction: 'Try again with a simpler request.',
        ),
      );
    }
    final message = choice?['message'];
    final raw = message is Map ? message['content'] : null;
    final text = switch (raw) {
      String s => s,
      List parts => parts.whereType<Map>().map((p) => p['text'] ?? '').join(),
      _ => '',
    };
    final decoded = extractJsonObject(text);
    if (decoded == null) {
      return const Result.err(RemoteFailure(message: 'The AI returned data in an unexpected format.'));
    }
    final usage = body['usage'] as Map<String, dynamic>? ?? const {};
    return Result.ok(
      ClaudeJsonResponse(
        json: decoded,
        model: body['model'] as String? ?? config.model,
        requestId: body['id'] as String?,
        usage: ClaudeUsage(
          (usage['prompt_tokens'] as num?)?.toInt() ?? 0,
          (usage['completion_tokens'] as num?)?.toInt() ?? 0,
        ),
      ),
    );
  }

  /// The JSON object in a model's reply, which may come wrapped in a code
  /// fence or a sentence of preamble.
  static Map<String, dynamic>? extractJsonObject(String text) {
    final start = text.indexOf('{'), end = text.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final value = jsonDecode(text.substring(start, end + 1));
      return value is Map<String, dynamic> ? value : null;
    } catch (_) {
      return null;
    }
  }

  Duration? _retryDelay(http.Response response, int attempt) {
    final status = response.statusCode;
    if (status == 429) {
      // Wait only when the gateway says how long, and not for long.
      final asked = AiUsageMeter.retryAfterOf(response.headers, DateTime.now());
      return asked != null && asked <= _maxServerRequestedWait ? asked : null;
    }
    if (status == 408 || status >= 500) return _backoff(attempt);
    return null;
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
      final error = body is Map ? body['error'] : null;
      apiMessage = error is Map ? error['message'] as String? : (error is String ? error : null);
    } catch (_) {}
    switch (response.statusCode) {
      case 401 || 403:
        return AuthenticationFailure(
          statusCode: response.statusCode,
          message: apiMessage ?? 'The gateway did not accept the key.',
        );
      case 404:
        return RemoteFailure(statusCode: 404, message: 'The gateway has no model "${config.model}".');
      case 413:
        return const ValidationFailure(
          message: 'That image is too large to analyze.',
          recoveryAction: 'Try a smaller photo or crop it closer to the food.',
        );
      case 429:
        return RateLimitedFailure(
          message: 'The free models are busy or out of requests for now.',
          retryAfterSeconds: AiUsageMeter.retryAfterOf(response.headers, DateTime.now())?.inSeconds,
          recoveryAction: 'Wait a minute and try again, or pick another model in Settings.',
        );
      case >= 500:
        return RemoteFailure(
          statusCode: response.statusCode,
          message: 'The AI gateway is having trouble.',
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
