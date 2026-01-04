import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/pet/models/pet_model.dart';
import 'package:petgram_web/features/pet/repositories/pet_repository.dart';

final myPetsProvider = FutureProvider<List<PetModel>>((ref) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.getMyPets();
});
