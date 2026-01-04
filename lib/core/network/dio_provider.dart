import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/storage/storage_provider.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080',
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Rotas que não precisam de token ou petId
        final publicRoutes = ['/auth/login', '/auth/register'];
        if (publicRoutes.contains(options.path)) {
          return handler.next(options);
        }

        // Adicionar Token de Autenticação
        final token = await ref.read(secureStorageProvider).read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Adicionar ID do Pet ao Header quando disponível
        final currentPet = ref.read(petContextProvider);
        if (currentPet != null) {
          options.headers['X-Pet-Id'] = currentPet.id;
        }

        return handler.next(options);
      },
    ),
  );

  return dio;
});
