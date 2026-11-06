import 'dart:convert';
import 'dart:typed_data';

import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/core/ai/chef_kiss_ai.dart';
import 'package:chefs_kiss/core/ai/ai_usage.dart';
import 'package:chefs_kiss/core/ai/claude_client.dart';
import 'package:chefs_kiss/core/ai/gateway_client.dart';
import 'package:chefs_kiss/features/imports/services/ai_recipe_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _chat(String content, {Map<String, String> headers = const {}}) => http.Response(
  jsonEncode({
    'id': 'chatcmpl-1',
    'model': 'kimi-k3-free',
    'choices': [
      {
        'finish_reason': 'stop',
        'message': {'role': 'assistant', 'content': content},
      },
    ],
    'usage': {'prompt_tokens': 12, 'completion_tokens': 34},
  }),
  200,
  headers: {'content-type': 'application/json', ...headers},
);

GatewayClient _client(MockClient http, {AiUsageMeter? meter}) => GatewayClient(
  GatewayConfig(baseUri: Uri.parse('http://127.0.0.1:18899'), apiKey: 'forward-key', model: 'kimi-k3-free'),
  httpClient: http,
  meter: meter,
  sleep: (_) async {},
);

void main() {
  group('gateway address', () {
    test('takes an address as typed', () {
      expect(GatewayConfig.parseAddress('127.0.0.1:18899').toString(), 'http://127.0.0.1:18899');
      expect(GatewayConfig.parseAddress(' http://192.168.1.20:18899/v1/ ').toString(), 'http://192.168.1.20:18899');
      expect(GatewayConfig.parseAddress('https://ai.example.com/gw/v1').toString(), 'https://ai.example.com/gw');
      expect(GatewayConfig.parseAddress(''), isNull);
      expect(GatewayConfig.parseAddress('ftp://x'), isNull);
    });
  });

  test('lists the gateway models', () async {
    late http.Request seen;
    final client = _client(
      MockClient((r) async {
        seen = r;
        return http.Response(
          jsonEncode({
            'data': [
              {'id': 'kimi-k3-free'},
              {'id': 'mimo-v2.6-flash-free'},
            ],
          }),
          200,
        );
      }),
    );
    expect((await client.listModels()).orNull, ['kimi-k3-free', 'mimo-v2.6-flash-free']);
    expect(seen.url.toString(), 'http://127.0.0.1:18899/v1/models');
    expect(seen.headers['authorization'], 'Bearer forward-key');
  });

  test('asks for JSON, sends photos as image parts, and reads fenced JSON back', () async {
    late Map<String, dynamic> body;
    final client = _client(
      MockClient((r) async {
        body = jsonDecode(r.body) as Map<String, dynamic>;
        return _chat('Here you go:\n```json\n{"title": "Shakshuka"}\n```');
      }),
    );
    final res = await client.createStructured(
      system: 'Be helpful.',
      content: [
        ClaudeImage(Uint8List.fromList([1, 2, 3]), 'image/jpeg'),
        const ClaudeText('What is this?'),
      ],
      schema: const {'type': 'object'},
    );
    expect(res.orNull!.json, {'title': 'Shakshuka'});
    expect(res.orNull!.usage.outputTokens, 34);
    expect(body['model'], 'kimi-k3-free');
    expect(body['response_format'], {'type': 'json_object'});
    final messages = body['messages'] as List;
    expect((messages[0] as Map)['content'], contains('JSON Schema'));
    final parts = (messages[1] as Map)['content'] as List;
    expect((parts[0] as Map)['type'], 'image_url');
    expect(((parts[0] as Map)['image_url'] as Map)['url'], startsWith('data:image/jpeg;base64,'));
    expect(parts[1], {'type': 'text', 'text': 'What is this?'});
  });

  test('asks again without JSON mode when a model does not support it', () async {
    final bodies = <Map<String, dynamic>>[];
    final client = _client(
      MockClient((r) async {
        bodies.add(jsonDecode(r.body) as Map<String, dynamic>);
        return bodies.length == 1
            ? http.Response('{"error": {"message": "response_format is not supported"}}', 400)
            : _chat('{"ok": true}');
      }),
    );
    final res = await client.createStructured(system: 's', content: const [ClaudeText('t')], schema: const {});
    expect(res.orNull!.json, {'ok': true});
    expect(bodies, hasLength(2));
    expect(bodies.last.containsKey('response_format'), isFalse);
  });

  test('rate limits reach the meter: what is left, and when to come back', () async {
    final meter = AiUsageMeter(clock: () => DateTime(2026, 11, 6, 22));
    var calls = 0;
    final client = _client(
      MockClient((r) async {
        calls++;
        return calls == 1
            ? _chat(
                '{"a": 1}',
                headers: {
                  'x-ratelimit-limit-requests': '20',
                  'x-ratelimit-remaining-requests': '19',
                  'x-ratelimit-reset-requests': '1m30s',
                },
              )
            : http.Response('{"error": {"message": "slow down"}}', 429, headers: {'retry-after': '120'});
      }),
      meter: meter,
    );
    await client.createStructured(system: 's', content: const [ClaudeText('t')], schema: const {});
    expect((meter.usage.limit, meter.usage.remaining), (20, 19));
    expect(meter.usage.resetsAt, DateTime(2026, 11, 6, 22, 1, 30));

    final res = await client.createStructured(system: 's', content: const [ClaudeText('t')], schema: const {});
    expect(res.error, isA<RateLimitedFailure>());
    expect((res.error! as RateLimitedFailure).retryAfterSeconds, 120);
    expect(calls, 2, reason: 'a two-minute wait is not retried');
    expect(meter.usage.limitedUntil, DateTime(2026, 11, 6, 22, 2));
    expect(meter.usage.requests, 2);
  });

  test('reads reset times written as durations', () {
    expect(AiUsageMeter.parseSpan('6m0s'), const Duration(minutes: 6));
    expect(AiUsageMeter.parseSpan('1.5s'), const Duration(milliseconds: 1500));
    expect(AiUsageMeter.parseSpan('120ms'), const Duration(milliseconds: 120));
    expect(AiUsageMeter.parseSpan('soon'), isNull);
  });

  test('dish ideas are read leniently and become a recipe request', () {
    final ideas = DishIdea.listFrom({
      'ideas': [
        {
          'title': ' Spinach frittata ',
          'summary': 'Eggs and greens set in one pan.',
          'minutes': 25,
          'uses': ['eggs', 'spinach', ''],
          'missing': ['feta'],
        },
        {'title': ''},
        'junk',
      ],
    });
    expect(ideas, hasLength(1));
    expect(ideas.single.title, 'Spinach frittata');
    expect(ideas.single.uses, ['eggs', 'spinach']);
    expect(ideas.single.request, contains('Use mainly eggs, spinach.'));
    expect(ideas.single.request, contains('feta'));
  });

  group('Chef’s Kiss AI', () {
    http.Response busy() => http.Response('{"error": {"message": "rate limited"}}', 429);

    test('a busy model hands over to the next; nothing to set up, thinking off', () async {
      final asked = <Map<String, dynamic>>[];
      final meter = AiUsageMeter();
      final ai = ChefKissAi(
        meter: meter,
        httpClient: MockClient((r) async {
          final body = jsonDecode(r.body) as Map<String, dynamic>;
          asked.add(body);
          expect(r.headers['authorization'], isNull, reason: 'no key needed');
          expect(r.url.toString(), 'https://ai-gateway.kilo.ai/api/v1/chat/completions');
          return asked.length == 1 ? busy() : _chat('{"title": "Frittata"}');
        }),
      );
      final res = await ai.createStructured(system: 's', content: const [ClaudeText('eggs')], schema: const {});
      expect(res.orNull!.json, {'title': 'Frittata'});
      expect(asked.map((b) => b['model']), ChefKissAi.textModels.take(2));
      expect(asked.first['reasoning'], {'enabled': false});
      expect(meter.usage.limitedAt(DateTime.now()), isFalse, reason: 'one busy model is not a busy AI');

      // The busy model rests: the next request starts with the one that answered.
      await ai.createStructured(system: 's', content: const [ClaudeText('eggs')], schema: const {});
      expect(asked.last['model'], ChefKissAi.textModels[1]);
    });

    test('photos only go to models that can see them', () async {
      final models = <String>[];
      final ai = ChefKissAi(
        httpClient: MockClient((r) async {
          models.add((jsonDecode(r.body) as Map)['model'] as String);
          return busy();
        }),
      );
      await ai.createStructured(
        system: 's',
        content: [
          ClaudeImage(Uint8List.fromList([1]), 'image/jpeg'),
        ],
        schema: const {},
      );
      expect(models, ChefKissAi.visionModels);
    });

    test('when every model is busy, it says so and when to come back', () async {
      final meter = AiUsageMeter();
      final ai = ChefKissAi(meter: meter, httpClient: MockClient((_) async => busy()));
      final res = await ai.createStructured(system: 's', content: const [ClaudeText('t')], schema: const {});
      expect(res.error, isA<RateLimitedFailure>());
      expect(res.error!.message, contains('busy'));
      expect((res.error! as RateLimitedFailure).retryAfterSeconds, greaterThan(60));
      expect(meter.usage.limitedAt(DateTime.now()), isTrue);
    });

    test('no connection reads as no connection, not as busy', () async {
      var online = false, calls = 0;
      final ai = ChefKissAi(
        httpClient: MockClient((_) async {
          calls++;
          if (!online) throw http.ClientException('offline');
          return _chat('{"ok": true}');
        }),
      );
      final res = await ai.createStructured(system: 's', content: const [ClaudeText('t')], schema: const {});
      expect(res.error, isA<NetworkUnavailableFailure>());
      expect(calls, 1, reason: 'offline is offline for every model');
      online = true;
      final again = await ai.createStructured(system: 's', content: const [ClaudeText('t')], schema: const {});
      expect(again.isSuccess, isTrue, reason: 'back online, the first model is ready again');
    });
  });
}
