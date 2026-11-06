import 'package:app_contracts/app_contracts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ai_client.dart';
import 'ai_usage.dart';
import 'chef_kiss_ai.dart';

/// Where secrets live. Platform keychain/keystore in the app; in-memory in
/// tests or when the platform keychain is unavailable.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureSecretStore implements SecretStore {
  final FlutterSecureStorage _storage;
  const SecureSecretStore([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read(String key) => _storage.read(key: key);
  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class InMemorySecretStore implements SecretStore {
  final Map<String, String> _values = {};
  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> write(String key, String value) async => _values[key] = value;
  @override
  Future<void> delete(String key) async => _values.remove(key);
}

enum AiConnectionMode {
  /// Chef's Kiss AI: free shared models, nothing to set up.
  free,

  /// AI features are unavailable.
  none,
}

@immutable
class AiConnectionState {
  final AiConnectionMode mode;
  const AiConnectionState({required this.mode});

  bool get isAvailable => mode == AiConnectionMode.free;

  /// There is no key or account for anyone to set up.
  bool get canEditKey => false;

  static const free = AiConnectionState(mode: AiConnectionMode.free);
  static const unavailable = AiConnectionState(mode: AiConnectionMode.none);
}

final secretStoreProvider = Provider<SecretStore>((ref) => const SecureSecretStore());

final aiConnectionProvider =
    AsyncNotifierProvider<AiConnectionController, AiConnectionState>(AiConnectionController.new);

/// Chef's Kiss AI, ready to use.
final aiClientProvider = Provider<AiClient?>((ref) {
  final state = ref.watch(aiConnectionProvider).valueOrNull;
  if (state == null || !state.isAvailable) return null;
  final client = ChefKissAi(meter: ref.read(aiUsageProvider), logger: const StandardAppLogger());
  ref.onDispose(client.close);
  return client;
});

/// AI is always on: Chef's Kiss AI runs on free shared models.
class AiConnectionController extends AsyncNotifier<AiConnectionState> {
  @override
  Future<AiConnectionState> build() async => AiConnectionState.free;

  /// Whether Chef's Kiss AI can be reached from here.
  Future<Result<void, AppFailure>> testConnection() async {
    final probe = ChefKissAi();
    final res = await probe.checkAccess();
    probe.close();
    return res;
  }
}
