import 'package:app_contracts/app_contracts.dart';

import 'claude_client.dart';

/// An AI service the app can talk to: Claude, or any OpenAI-compatible
/// gateway such as a self-hosted free-model gateway.
abstract interface class AiClient {
  /// Whether the service answers and accepts the credentials, without
  /// spending tokens where it can.
  Future<Result<void, AppFailure>> checkAccess();

  /// Sends one user turn and returns the model's answer as a JSON object
  /// shaped by [schema].
  Future<Result<ClaudeJsonResponse, AppFailure>> createStructured({
    required String system,
    required List<ClaudeContent> content,
    required Map<String, dynamic> schema,
    String effort = 'medium',
    int maxTokens = 16000,
    String feature = 'ai',
  });

  void close();
}
