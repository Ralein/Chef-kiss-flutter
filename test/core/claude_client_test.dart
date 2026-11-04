import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/core/ai/claude_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

http.Response okMessage(Map<String, dynamic> json, {String stop = 'end_turn'}) => http.Response(
      jsonEncode({
        'id': 'msg_1',
        'type': 'message',
        'model': 'claude-opus-5-5',
        'stop_reason': stop,
        'content': [
          {'type': 'thinking', 'thinking': '', 'signature': 'sig'},
          {'type': 'text', 'text': jsonEncode(json)},
        ],
        'usage': {'input_tokens': 1200, 'output_tokens': 300},
      }),
      200,
      headers: {'request-id': 'req_123', 'content-type': 'application/json'},
    );

http.Response apiError(int status, String type, {Map<String, String> headers = const {}}) => http.Response(
      jsonEncode({
        'type': 'error',
        'error': {'type': type, 'message': 'details for $type'},
      }),
      status,
      headers: {'content-type': 'application/json', ...headers},
    );

void main() {
  late List<http.Request> requests;
  late List<Duration> sleeps;

  ClaudeClient client(List<http.Response Function(http.Request)> responders, {ClaudeConfig? config}) {
    var i = 0;
    return ClaudeClient(
      config ?? ClaudeConfig(baseUri: ClaudeConfig.anthropicApi, apiKey: 'sk-test'),
      httpClient: MockClient((req) async {
        requests.add(req);
        final responder = responders[i < responders.length ? i : responders.length - 1];
        i++;
        return responder(req);
      }),
      random: Random(7),
      sleep: (d) async => sleeps.add(d),
    );
  }

  Future<Result<ClaudeJsonResponse, AppFailure>> call(ClaudeClient c) => c.createStructured(
        system: 'sys',
        content: [ClaudeImage(Uint8List.fromList([1, 2, 3]), 'image/jpeg'), const ClaudeText('Analyze')],
        schema: const {'type': 'object', 'properties': {}, 'required': [], 'additionalProperties': false},
      );

  setUp(() {
    requests = [];
    sleeps = [];
  });

  test('sends a correct Messages API request and parses the JSON text block', () async {
    final res = await call(client([(_) => okMessage({'title': 'Ramen'})]));

    expect(res.isSuccess, isTrue, reason: res.error?.message);
    expect(res.orNull!.json['title'], 'Ramen');
    expect(res.orNull!.requestId, 'req_123');
    expect(res.orNull!.usage.inputTokens, 1200);

    final req = requests.single;
    expect(req.url.toString(), 'https://api.anthropic.com/v1/messages');
    expect(req.headers['anthropic-version'], '2026-10-21');
    expect(req.headers['x-api-key'], 'sk-test');
    expect(req.headers['anthropic-beta'], 'server-side-fallback-2026-07-01');
    expect(req.headers.containsKey('anthropic-dangerous-direct-browser-access'), isFalse);

    final body = jsonDecode(req.body) as Map<String, dynamic>;
    expect(body['model'], 'claude-opus-5-5');
    expect(body['fallbacks'], 'default');
    expect(body['output_config']['format']['type'], 'json_schema');
    expect(body['output_config']['effort'], 'medium');
    expect(body.keys, isNot(contains('temperature')), reason: '400 on API version 2026-10-21');
    expect(body.keys, isNot(contains('thinking')), reason: 'Opus 5.5 is adaptive by default');
    final content = body['messages'][0]['content'] as List;
    expect(content.first['type'], 'image', reason: 'images should precede text');
    expect(content.first['source']['data'], base64Encode([1, 2, 3]));
  });

  test('maps a refusal stop reason to ContentRefusedFailure', () async {
    final res = await call(client([
      (_) => http.Response(
            jsonEncode({
              'stop_reason': 'refusal',
              'stop_details': {'type': 'refusal', 'category': 'bio'},
              'content': [],
            }),
            200,
          ),
    ]));
    expect(res.error, isA<ContentRefusedFailure>());
    expect((res.error as ContentRefusedFailure).category, 'bio');
  });

  test('treats a truncated (max_tokens) response as a failure, not partial JSON', () async {
    final res = await call(client([(_) => okMessage({'title': 'x'}, stop: 'max_tokens')]));
    expect(res.error, isA<RemoteFailure>());
  });

  test('retries 429 honoring retry-after, then succeeds', () async {
    final res = await call(client([
      (_) => apiError(429, 'rate_limit_error', headers: {'retry-after': '2'}),
      (_) => okMessage({'ok': true}),
    ]));
    expect(res.isSuccess, isTrue);
    expect(requests, hasLength(2));
    expect(sleeps.single, const Duration(seconds: 2));
  });

  test('prefers retry-after-ms over retry-after', () async {
    await call(client([
      (_) => apiError(529, 'overloaded_error', headers: {'retry-after-ms': '250', 'retry-after': '9'}),
      (_) => okMessage({'ok': true}),
    ]));
    expect(sleeps.single, const Duration(milliseconds: 250));
  });

  test('uses capped exponential backoff with jitter for overloaded errors', () async {
    final res = await call(client([
      (_) => apiError(529, 'overloaded_error'),
      (_) => apiError(500, 'api_error'),
      (_) => okMessage({'ok': true}),
    ]));
    expect(res.isSuccess, isTrue);
    expect(sleeps, hasLength(2));
    expect(sleeps[0].inMilliseconds, inInclusiveRange(375, 500));
    expect(sleeps[1].inMilliseconds, inInclusiveRange(750, 1000));
  });

  test('gives up after maxRetries and reports a friendly failure', () async {
    final res = await call(client([(_) => apiError(529, 'overloaded_error')]));
    expect(requests, hasLength(3));
    expect(res.error, isA<RemoteFailure>());
    expect(res.error!.message, contains('temporarily unavailable'));
  });

  test('does not retry authentication or validation errors', () async {
    final auth = await call(client([(_) => apiError(401, 'authentication_error')]));
    expect(auth.error, isA<AuthenticationFailure>());
    expect(requests, hasLength(1));

    requests.clear();
    final big = await call(client([(_) => apiError(413, 'request_too_large')]));
    expect(big.error, isA<ValidationFailure>());
    expect(requests, hasLength(1));
  });

  test('honors x-should-retry: false even for 5xx', () async {
    final res = await call(client([(_) => apiError(500, 'api_error', headers: {'x-should-retry': 'false'})]));
    expect(requests, hasLength(1));
    expect(res.error, isA<RemoteFailure>());
  });

  test('fails fast with RateLimitedFailure when the server asks for a long wait', () async {
    final res = await call(client([(_) => apiError(429, 'rate_limit_error', headers: {'retry-after': '120'})]));
    expect(requests, hasLength(1));
    expect(res.error, isA<RateLimitedFailure>());
    expect((res.error as RateLimitedFailure).retryAfterSeconds, 120);
  });

  test('retries network errors and then reports offline', () async {
    final res = await call(client([(_) => throw const SocketException('no route')]));
    expect(requests, hasLength(3));
    expect(res.error, isA<NetworkUnavailableFailure>());
  });

  test('rejects non-JSON model output instead of crashing', () async {
    final res = await call(client([
      (_) => http.Response(
            jsonEncode({
              'stop_reason': 'end_turn',
              'content': [
                {'type': 'text', 'text': 'Sorry, here is prose'},
              ],
            }),
            200,
          ),
    ]));
    expect(res.error, isA<RemoteFailure>());
  });

  test('proxy mode sends no API key; browser mode opts in to CORS', () async {
    await call(client(
      [(_) => okMessage({'ok': true})],
      config: ClaudeConfig(
        baseUri: Uri.parse('https://ai.example.com'),
        extraHeaders: const {'authorization': 'Bearer app-token'},
        directBrowserAccess: true,
      ),
    ));
    final req = requests.single;
    expect(req.url.toString(), 'https://ai.example.com/v1/messages');
    expect(req.headers.containsKey('x-api-key'), isFalse);
    expect(req.headers['authorization'], 'Bearer app-token');
    expect(req.headers['anthropic-dangerous-direct-browser-access'], 'true');
  });
}
