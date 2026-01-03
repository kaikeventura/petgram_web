import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/storage/storage_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080',
    ),
  );

  final secureStorage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Não adiciona o token em rotas de autenticação
        if (options.path == '/auth/login' || options.path == '/auth/register') {
          return handler.next(options);
        }

        final token = await secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  return dio;
});
