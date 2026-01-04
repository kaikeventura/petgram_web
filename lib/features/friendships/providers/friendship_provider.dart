import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/friendships/models/friendship_status.dart';
import 'package:petgram_web/features/friendships/repositories/friendship_repository.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';

// Usamos um record para passar múltiplos argumentos para o family
final friendshipStatusProvider =
    FutureProvider.autoDispose.family<FriendshipState, String>((ref, targetPetId) {
  final myPetId = ref.watch(petContextProvider.select((p) => p?.id));
  if (myPetId == null) {
    throw Exception('Usuário não tem um pet selecionado.');
  }

  final repository = ref.watch(friendshipRepositoryProvider);
  return repository.getFriendshipStatus(myPetId: myPetId, targetPetId: targetPetId);
});
