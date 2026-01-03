import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
      final response = await _dio.get('/posts/feed', queryParameters: {'page': 0, 'size': 20});
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> content = responseData['content'];
      return content.map((json) => Post.fromMap(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar o feed: $e');
      rethrow;
    }
  }

  Future<void> createPost({
    required XFile image,
    required String caption,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: image.name,
      );

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      await _dio.post(
        '/posts',
        data: formData,
        queryParameters: {
          'caption': caption,
        },
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      print('Erro ao criar o post: $e');
      rethrow;
    }
  }
}
