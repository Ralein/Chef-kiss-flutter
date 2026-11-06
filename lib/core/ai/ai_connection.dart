import 'package:app_contracts/app_contracts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ai_client.dart';
import 'ai_usage.dart';
import 'claude_client.dart';
import 'gateway_client.dart';

/// Build-time AI configuration, injected with `--dart-define`.
///
/// Production builds should set [proxyUrl] to a backend that holds the
/// Anthropic API key server-side; see docs/AI_SETUP.md. Without a proxy the
/// app falls back to a key the user enters themselves ("bring your own key").
class AiEnvironment {
  AiEnvironment._();

  static const proxyUrl = String.fromEnvironment('CHEFS_KISS_AI_PROXY_URL');

  /// Sent as `Authorization: Bearer …` to the proxy. This identifies the app
  /// build; it is *not* a secret (it ships inside the binary).
  static const proxyToken = String.fromEnvironment('CHEFS_KISS_AI_PROXY_TOKEN');
  static const model = String.fromEnvironment('CHEFS_KISS_AI_MODEL', defaultValue: ClaudeConfig.defaultModel);
  static const allowUserKeys = bool.fromEnvironment('CHEFS_KISS_ALLOW_USER_API_KEY', defaultValue: true);

  static bool get hasProxy => proxyUrl.isNotEmpty;
}

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
  /// Requests go through the operator's backend proxy.
  proxy,

  /// Requests go straight to the Anthropic API with the user's own key.
  userKey,

  /// Requests go to an OpenAI-compatible gateway the user runs, such as a
  /// free-model gateway on their computer.
  gateway,

  /// AI features are unavailable until a key is added.
  none,
}

@immutable
class AiConnectionState {
  final AiConnectionMode mode;
  final ClaudeConfig? config;
  final GatewayConfig? gateway;
  final String? maskedKey;

  /// False when the OS keychain could not be used; a key entered now is kept
  /// for this session only.
  final bool persistentStorage;

  const AiConnectionState({
    required this.mode,
    this.config,
    this.gateway,
    this.maskedKey,
    this.persistentStorage = true,
  });

  bool get isAvailable => mode == AiConnectionMode.gateway ? gateway != null : mode != AiConnectionMode.none && config != null;

  /// The model answering requests.
  String? get model => gateway?.model ?? config?.model;
  bool get canEditKey => mode != AiConnectionMode.proxy && AiEnvironment.allowUserKeys;

  static const unavailable = AiConnectionState(mode: AiConnectionMode.none);
}

final secretStoreProvider = Provider<SecretStore>((ref) => const SecureSecretStore());

final aiConnectionProvider =
    AsyncNotifierProvider<AiConnectionController, AiConnectionState>(AiConnectionController.new);

/// Ready-to-use client — Claude or the user's gateway — or null when AI is
/// not configured.
final aiClientProvider = Provider<AiClient?>((ref) {
  final state = ref.watch(aiConnectionProvider).valueOrNull;
  if (state == null || !state.isAvailable) return null;
  final meter = ref.read(aiUsageProvider);
  const logger = StandardAppLogger();
  final AiClient client = state.mode == AiConnectionMode.gateway
      ? GatewayClient(state.gateway!, meter: meter, logger: logger)
      : ClaudeClient(state.config!, meter: meter, logger: logger);
  ref.onDispose(client.close);
  return client;
});

class AiConnectionController extends AsyncNotifier<AiConnectionState> {
  static const _apiKeyKey = 'ai.anthropic_api_key';
  static const _workspaceKey = 'ai.anthropic_workspace_id';
  static const _providerKey = 'ai.provider';
  static const _gatewayAddressKey = 'ai.gateway_address';
  static const _gatewayKeyKey = 'ai.gateway_key';
  static const _gatewayModelKey = 'ai.gateway_model';

  @override
  Future<AiConnectionState> build() async {
    if (AiEnvironment.hasProxy) {
      return AiConnectionState(
        mode: AiConnectionMode.proxy,
        config: ClaudeConfig(
          baseUri: Uri.parse(AiEnvironment.proxyUrl),
          model: AiEnvironment.model,
          extraHeaders: {
            if (AiEnvironment.proxyToken.isNotEmpty) 'authorization': 'Bearer ${AiEnvironment.proxyToken}',
          },
        ),
      );
    }
    final store = ref.read(secretStoreProvider);
    try {
      if (await store.read(_providerKey) == 'gateway') {
        final base = GatewayConfig.parseAddress(await store.read(_gatewayAddressKey) ?? '');
        final model = await store.read(_gatewayModelKey);
        if (base == null || model == null || model.isEmpty) return AiConnectionState.unavailable;
        return _viaGateway(base, await store.read(_gatewayKeyKey), model, persistent: true);
      }
    } catch (_) {
      return const AiConnectionState(mode: AiConnectionMode.none, persistentStorage: false);
    }
    if (!AiEnvironment.allowUserKeys) return AiConnectionState.unavailable;

    try {
      final key = await store.read(_apiKeyKey);
      final workspace = await store.read(_workspaceKey);
      if (key == null || key.isEmpty) return AiConnectionState.unavailable;
      return _direct(key, workspace, persistent: true);
    } catch (_) {
      return const AiConnectionState(mode: AiConnectionMode.none, persistentStorage: false);
    }
  }

  /// Validates and stores a user-supplied key. The key is only persisted if
  /// the API accepts it.
  Future<Result<void, AppFailure>> saveApiKey(String rawKey, {String? workspaceId}) async {
    final key = rawKey.trim();
    if (key.isEmpty || key.contains(RegExp(r'\s'))) {
      return const Result.err(ValidationFailure(message: 'That does not look like an API key.'));
    }
    final workspace = workspaceId?.trim();
    final candidate = _direct(key, workspace, persistent: true);
    final probe = ClaudeClient(candidate.config!);
    final check = await probe.checkAccess();
    probe.close();
    if (check.isFailure) return check;

    var persistent = true;
    final store = ref.read(secretStoreProvider);
    try {
      await store.write(_providerKey, 'claude');
      await store.write(_apiKeyKey, key);
      if (workspace != null && workspace.isNotEmpty) {
        await store.write(_workspaceKey, workspace);
      } else {
        await store.delete(_workspaceKey);
      }
    } catch (_) {
      persistent = false;
    }
    state = AsyncData(_direct(key, workspace, persistent: persistent));
    return const Result.ok(null);
  }

  Future<void> removeApiKey() async {
    final store = ref.read(secretStoreProvider);
    try {
      await store.delete(_providerKey);
      await store.delete(_apiKeyKey);
      await store.delete(_workspaceKey);
    } catch (_) {
      // Nothing persisted; clearing in-memory state is enough.
    }
    state = const AsyncData(AiConnectionState.unavailable);
  }

  Future<Result<void, AppFailure>> testConnection() async {
    final current = state.valueOrNull;
    final meter = ref.read(aiUsageProvider);
    final AiClient? probe = switch (current) {
      AiConnectionState(gateway: final g?) => GatewayClient(g, meter: meter),
      AiConnectionState(config: final c?) => ClaudeClient(c, meter: meter),
      _ => null,
    };
    if (probe == null) {
      return const Result.err(CapabilityUnavailableFailure(capability: 'ai', reason: 'not_configured'));
    }
    final res = await probe.checkAccess();
    probe.close();
    return res;
  }

  /// The models a gateway offers, to choose from before connecting to it.
  Future<Result<List<String>, AppFailure>> gatewayModels(String address, String? key) async {
    final base = GatewayConfig.parseAddress(address);
    if (base == null) {
      return const Result.err(
        ValidationFailure(
          message: 'That doesn’t look like a gateway address.',
          recoveryAction: 'For example: http://127.0.0.1:18899',
        ),
      );
    }
    final probe = GatewayClient(GatewayConfig(baseUri: base, apiKey: key?.trim(), model: ''));
    final res = await probe.listModels();
    probe.close();
    return res;
  }

  /// Connects to a gateway and uses [model] from now on. The address, key
  /// and model are kept in the device keychain.
  Future<Result<void, AppFailure>> saveGateway({required String address, String? key, required String model}) async {
    final base = GatewayConfig.parseAddress(address);
    if (base == null || model.isEmpty) {
      return const Result.err(ValidationFailure(message: 'Pick a gateway and one of its models.'));
    }
    final secret = key?.trim();
    var persistent = true;
    final store = ref.read(secretStoreProvider);
    try {
      await store.write(_providerKey, 'gateway');
      await store.write(_gatewayAddressKey, base.toString());
      await store.write(_gatewayModelKey, model);
      if (secret != null && secret.isNotEmpty) {
        await store.write(_gatewayKeyKey, secret);
      } else {
        await store.delete(_gatewayKeyKey);
      }
    } catch (_) {
      persistent = false;
    }
    state = AsyncData(_viaGateway(base, secret, model, persistent: persistent));
    return const Result.ok(null);
  }

  Future<void> removeGateway() async {
    final store = ref.read(secretStoreProvider);
    try {
      for (final key in [_providerKey, _gatewayAddressKey, _gatewayKeyKey, _gatewayModelKey]) {
        await store.delete(key);
      }
    } catch (_) {
      // Nothing persisted; clearing in-memory state is enough.
    }
    state = const AsyncData(AiConnectionState.unavailable);
  }

  AiConnectionState _viaGateway(Uri base, String? key, String model, {required bool persistent}) => AiConnectionState(
    mode: AiConnectionMode.gateway,
    maskedKey: key == null || key.isEmpty ? null : _mask(key),
    persistentStorage: persistent,
    gateway: GatewayConfig(baseUri: base, apiKey: key, model: model),
  );

  AiConnectionState _direct(String key, String? workspace, {required bool persistent}) => AiConnectionState(
        mode: AiConnectionMode.userKey,
        maskedKey: _mask(key),
        persistentStorage: persistent,
        config: ClaudeConfig(
          baseUri: ClaudeConfig.anthropicApi,
          apiKey: key,
          workspaceId: workspace,
          model: AiEnvironment.model,
          directBrowserAccess: kIsWeb,
        ),
      );

  static String _mask(String key) {
    if (key.length <= 10) return '••••';
    return '${key.substring(0, 7)}…${key.substring(key.length - 4)}';
  }
}
