import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/pet/models/pet_model.dart';
import 'package:petgram_web/features/pet/repositories/pet_repository.dart';

final petFollowersProvider = FutureProvider.autoDispose.family<List<PetModel>, String>((ref, petId) {
  final repository = ref.watch(petRepositoryProvider);
  return repository.getFollowers(petId);
});

final petFollowingProvider = FutureProvider.autoDispose.family<List<PetModel>, String>((ref, petId) {
  final repository = ref.watch(petRepositoryProvider);
  return repository.getFollowing(petId);
});
