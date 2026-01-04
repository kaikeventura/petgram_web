import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/likes/models/pet_liker_model.dart';
import 'package:petgram_web/features/likes/repositories/likes_repository.dart';

final postLikersProvider =
    FutureProvider.autoDispose.family<List<PetLikerModel>, String>((ref, postId) {
  final repository = ref.watch(likesRepositoryProvider);
  return repository.getPostLikers(postId);
});
