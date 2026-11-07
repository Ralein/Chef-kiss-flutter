import 'package:app_contracts/app_contracts.dart';
import 'package:http/http.dart' as http;

import 'ai_client.dart';
import 'ai_usage.dart';
import 'claude_client.dart';
import 'gateway_client.dart';

/// Chef's Kiss AI: free, shared models through a public AI gateway — no
/// account or key needed. The gateway allows each internet address a set
/// number of free requests an hour; every request is counted on [meter].
///
/// Each request goes to the first model that isn't resting; a model that is
/// busy (429), failing (5xx), gone (404), slow or answers in the wrong shape
/// rests for a while and the next one is tried. Photos go only to models
/// that can see. Thinking is switched off: the models answer straight away
/// instead of spending their budget reasoning.
class ChefKissAi implements AiClient {
  static final gateway = Uri.parse('https://ai-gateway.kilo.ai/api');

  /// Models that read photos and follow a JSON format, best first.
  static const visionModels = [
    'nvidia/nemotron-3.5-super-vl:free',
    'dots-studio/dots-3-note-preview:free',
    'stealth/crouton-alpha',
  ];

  /// Models for text, best first; the photo models can do text too.
  static const textModels = [
    'nvidia/nemotron-3.5-super-vl:free',
    'cohere/north-mini-code:free',
    'reflection/beam-free',
    'nvidia/nemotron-3.5-lightning:free',
    'dots-studio/dots-3-note-preview:free',
  ];

  static const _restAfterBusy = Duration(minutes: 2);
  static const _restAfterFailure = Duration(minutes: 1);

  final AiUsageMeter? meter;
  final http.Client _http;
  final DateTime Function() _clock;
  final AppLogger? _logger;
  final Duration _timeout;

  /// Models resting until a time, after being busy or failing.
  final _resting = <String, DateTime>{};

  ChefKissAi({
    this.meter,
    http.Client? httpClient,
    DateTime Function()? clock,
    AppLogger? logger,
    Duration timeout = const Duration(seconds: 90),
  }) : _http = httpClient ?? http.Client(),
       _clock = clock ?? DateTime.now,
       _logger = logger,
       _timeout = timeout;

  @override
  void close() => _http.close();

  GatewayClient _client(String model) => GatewayClient(
    GatewayConfig(
      baseUri: gateway,
      model: model,
      timeout: _timeout,
      maxRetries: 0,
      extraBody: const {
        'reasoning': {'enabled': false},
      },
    ),
    // Shared: these per-model clients are never closed themselves.
    httpClient: _http,
    logger: _logger,
  );

  @override
  Future<Result<void, AppFailure>> checkAccess() async {
    final res = await _client(textModels.first).listModels();
    return res.flatMap((_) => const Result.ok(null));
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
    final models = content.any((c) => c is ClaudeImage) ? visionModels : textModels;
    final now = _clock();
    final ready = [
      for (final m in models)
        if (!(_resting[m]?.isAfter(now) ?? false)) m,
    ];
    for (final model in ready) {
      // Every try counts against the hourly allowance, answered or not.
      meter?.noteRequest();
      final res = await _client(model).createStructured(
        system: system,
        content: content,
        schema: schema,
        effort: effort,
        maxTokens: maxTokens,
        feature: feature,
      );
      if (res.isSuccess) {
        meter?.record(200, const {});
        return res;
      }
      final failure = res.error!;
      // A request that's wrong for every model gains nothing from another.
      if (failure is ValidationFailure || failure is ContentRefusedFailure) return res;
      // Offline isn't the model's fault: stop, and leave every model ready.
      if (failure is NetworkUnavailableFailure) {
        return const Result.err(
          NetworkUnavailableFailure(
            message: 'Chef’s Kiss AI is out of reach.',
            recoveryAction: 'Check your internet connection and try again.',
          ),
        );
      }
      _resting[model] = _clock().add(failure is RateLimitedFailure ? _restAfterBusy : _restAfterFailure);
      _logger?.warning('Free model unavailable, trying the next', feature: feature, metadata: {'model': model});
    }
    // Every model is resting: say when the first is back.
    final back = models
        .map((m) => _resting[m])
        .nonNulls
        .fold<DateTime?>(null, (soonest, t) => soonest == null || t.isBefore(soonest) ? t : soonest);
    final wait = back?.difference(_clock());
    meter?.record(429, {if (wait != null && !wait.isNegative) 'retry-after': '${wait.inSeconds}'});
    return Result.err(
      RateLimitedFailure(
        message: 'Chef’s Kiss AI is busy right now.',
        retryAfterSeconds: wait == null || wait.isNegative ? null : wait.inSeconds,
        recoveryAction: 'It’s free and shared: try again in a minute or two.',
      ),
    );
  }
}
