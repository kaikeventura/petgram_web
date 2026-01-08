import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/feed/data/models/post_model.dart';
import 'package:petgram_web/features/pet/models/pet_model.dart';
import 'package:petgram_web/features/pet/repositories/pet_repository.dart';
import 'package:petgram_web/features/post/repositories/post_repository.dart';

final petProfileProvider = FutureProvider.family<PetModel, String>((ref, petId) {
  final petRepository = ref.watch(petRepositoryProvider);
  return petRepository.getPetDetails(petId);
});

final petPostsProvider = FutureProvider.family<List<Post>, String>((ref, petId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getPostsByPet(petId);
});
