import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/search/models/search_result_model.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SearchRepository(dio);
});

class SearchRepository {
  final Dio _dio;
  SearchRepository(this._dio);

  Future<List<SearchResult>> search(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get('/search', queryParameters: {'query': query});
      final Map<String, dynamic> data = response.data;

      final List<dynamic> petsData = data['pets'] ?? [];

      // Mapeia apenas os pets, ignorando os usuários.
      final List<SearchResult> results = petsData.map((pet) => SearchResult(
            id: pet['id'],
            name: pet['name'],
            subtitle: pet['breed'],
            avatarUrl: pet['avatarUrl'],
          )).toList();

      return results;
    } catch (e) {
      rethrow;
    }
  }
}
