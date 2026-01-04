import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/likes/models/pet_liker_model.dart';

final likesRepositoryProvider = Provider<LikesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LikesRepository(dio);
});

class LikesRepository {
  final Dio _dio;

  LikesRepository(this._dio);

  Future<List<PetLikerModel>> getPostLikers(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId/likes');
      final List<dynamic> data = response.data['content'];
      // Correção: Passar o item diretamente, sem procurar por 'pet' aninhado.
      return data.map((item) => PetLikerModel.fromMap(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
