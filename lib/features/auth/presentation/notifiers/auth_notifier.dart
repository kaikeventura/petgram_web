import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/storage/storage_provider.dart';
import 'package:petgram_web/features/auth/data/models/user_login_request.dart';
import 'package:petgram_web/features/auth/data/repositories/auth_repository.dart';
import 'package:petgram_web/features/auth/presentation/notifiers/auth_state.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState(status: AuthStatus.initial)) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final token = await _ref.read(secureStorageProvider).read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final loginRequest = UserLoginRequest(email: email, password: password);
      final authRepo = _ref.read(authRepositoryProvider);

      final authResponse = await authRepo.login(loginRequest);
      await authRepo.saveToken(authResponse.token);

      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Falha no login. Verifique suas credenciais.',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final authRepo = _ref.read(authRepositoryProvider);

      // 1. Cria a conta
      await authRepo.register(name: name, email: email, password: password);

      // 2. Faz o login automático
      await login(email, password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Falha ao criar conta. Tente novamente.',
      );
    }
  }

  Future<void> logout() async {
    final authRepo = _ref.read(authRepositoryProvider);
    await authRepo.deleteToken();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}
