import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/feed/data/models/post_model.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(dioProvider));
});

class PostRepository {
  final Dio _dio;

  PostRepository(this._dio);

  Future<List<Post>> getFeed() async {
    try {
      // Por enquanto, vamos buscar apenas a primeira página
      final response = await _dio.get('/posts/feed', queryParameters: {'page': 0, 'size': 20});
      
      // A resposta é um mapa, não uma lista
      final Map<String, dynamic> responseData = response.data;
      
      // Os posts estão dentro da chave 'content'
      final List<dynamic> content = responseData['content'];
      
      return content.map((json) => Post.fromMap(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar o feed: $e');
      rethrow;
    }
  }
}
