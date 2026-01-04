import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/pet/models/post_profile_model.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PostRepository(dio);
});

class PostRepository {
  final Dio _dio;

  PostRepository(this._dio);

  Future<List<PostProfileModel>> getPostsByPet(String petId) async {
    try {
      final response = await _dio.get('/pets/$petId/posts');
      final List<dynamic> data = response.data['content'];
      return data.map((json) => PostProfileModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
