import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/comments/models/comment_model.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CommentRepository(dio);
});

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId/comments');
      final List<dynamic> data = response.data['content'];
      return data.map((json) => Comment.fromMap(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createComment({
    required String postId,
    required String text,
  }) async {
    try {
      await _dio.post(
        '/posts/$postId/comments',
        data: {'text': text},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _dio.delete('/comments/$commentId');
    } catch (e) {
      rethrow;
    }
  }
}
