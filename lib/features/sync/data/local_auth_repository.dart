import 'dart:async';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'in_memory_cloud_sync_server.dart';

class LocalAuthRepository implements AuthRepository {
  final InMemoryCloudSyncServer _server;
  final StreamController<AuthSession> _sessionController =
      StreamController<AuthSession>.broadcast();
  AuthSession _currentSession;

  LocalAuthRepository({
    required InMemoryCloudSyncServer server,
    AuthSession initialSession = AuthSession.unauthenticated,
  })  : _server = server,
        _currentSession = initialSession {
    _sessionController.add(_currentSession);
  }

  @override
  AuthSession getCurrentSession() => _currentSession;

  @override
  Stream<AuthSession> watchSession() async* {
    yield _currentSession;
    yield* _sessionController.stream;
  }

  @override
  Future<Result<AuthSession, AppFailure>> signIn({
    required String email,
    required String password,
  }) async {
    _sessionController.add(_currentSession.copyWith(status: AuthSessionStatus.authenticating));

    final res = await _server.mockAuthenticate(email, password);
    if (res.isSuccess) {
      _currentSession = res.orNull!;
      _sessionController.add(_currentSession);
      return Result.ok(_currentSession);
    } else {
      _sessionController.add(_currentSession);
      return Result.err(res.error!);
    }
  }

  @override
  Future<Result<AuthSession, AppFailure>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _sessionController.add(_currentSession.copyWith(status: AuthSessionStatus.authenticating));

    final res = await _server.mockRegister(email, password, displayName);
    if (res.isSuccess) {
      _currentSession = res.orNull!;
      _sessionController.add(_currentSession);
      return Result.ok(_currentSession);
    } else {
      _sessionController.add(_currentSession);
      return Result.err(res.error!);
    }
  }

  @override
  Future<Result<void, AppFailure>> signOut() async {
    _currentSession = AuthSession.unauthenticated;
    _sessionController.add(_currentSession);
    return Result.ok(null);
  }

  @override
  Future<Result<bool, AppFailure>> deleteAccount() async {
    if (!_currentSession.isAuthenticated) {
      return Result.err(const PermissionDeniedFailure(
        capability: 'cloud_account',
        message: 'Must be logged in to delete account',
      ));
    }

    final purgeRes = await _server.purgeUserData(_currentSession);
    if (purgeRes.isSuccess) {
      _currentSession = AuthSession.unauthenticated;
      _sessionController.add(_currentSession);
      return Result.ok(true);
    } else {
      return Result.err(purgeRes.error!);
    }
  }

  void dispose() {
    _sessionController.close();
  }
}
