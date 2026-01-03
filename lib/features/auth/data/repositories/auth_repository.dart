import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/core/storage/storage_provider.dart';
import 'package:petgram_web/features/auth/data/models/auth_response.dart';
import 'package:petgram_web/features/auth/data/models/user_login_request.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  final Ref _ref;

  AuthRepository(this._ref);

  Future<AuthResponse> login(UserLoginRequest loginRequest) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post(
      '/auth/login',
      data: loginRequest.toMap(),
    );
    return AuthResponse.fromMap(response.data);
  }

  Future<void> saveToken(String token) async {
    final storage = _ref.read(secureStorageProvider);
    await storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    final storage = _ref.read(secureStorageProvider);
    await storage.delete(key: 'auth_token');
  }
}
