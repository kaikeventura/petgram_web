import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/pet/models/pet_model.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PetRepository(dio);
});

class PetRepository {
  final Dio _dio;

  PetRepository(this._dio);

  Future<List<PetModel>> getMyPets() async {
    try {
      final response = await _dio.get('/pets/my-pets');
      final List<dynamic> data = response.data;
      return data.map((json) => PetModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PetModel> createPet({
    required String name,
    required String breed,
    required String birthDate,
  }) async {
    try {
      final response = await _dio.post(
        '/pets',
        data: {
          'name': name,
          'breed': breed,
          'birthDate': birthDate,
        },
      );
      return PetModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
