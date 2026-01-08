import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/feed/data/models/post_model.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PostRepository(dio);
});

class PostRepository {
  final Dio _dio;

  PostRepository(this._dio);

  Future<List<Post>> getPostsByPet(String petId) async {
    try {
      final response = await _dio.get('/pets/$petId/posts');
      final List<dynamic> data = response.data['content'];
      // Tenta mapear para o modelo completo de Post
      return data.map((json) => Post.fromMap(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Post> getPostById(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId');
      return Post.fromMap(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _dio.post('/posts/$postId/like');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _dio.delete('/posts/$postId/like');
    } catch (e) {
      rethrow;
    }
  }
}
