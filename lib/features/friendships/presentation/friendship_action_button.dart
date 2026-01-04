import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/friendships/models/friendship_status.dart';
import 'package:petgram_web/features/friendships/providers/friendship_provider.dart';
import 'package:petgram_web/features/friendships/repositories/friendship_repository.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';

class FriendshipActionButton extends ConsumerWidget {
  final String targetPetId;
  const FriendshipActionButton({super.key, required this.targetPetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(friendshipStatusProvider(targetPetId));
    final myPetId = ref.watch(petContextProvider.select((p) => p?.id));

    return statusAsync.when(
      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
      error: (e, st) => TextButton(onPressed: () => ref.invalidate(friendshipStatusProvider(targetPetId)), child: const Text('Tentar Novamente')),
      data: (state) {
        switch (state.status) {
          case FriendshipStatusValue.isMe:
            return OutlinedButton(onPressed: () {}, child: const Text('Editar Perfil'));

          case FriendshipStatusValue.none:
            return ElevatedButton(
              onPressed: () async {
                await ref.read(friendshipRepositoryProvider).sendFriendRequest(myPetId: myPetId!, targetPetId: targetPetId);
                ref.invalidate(friendshipStatusProvider(targetPetId));
              },
              child: const Text('Seguir'),
            );

          case FriendshipStatusValue.pendingSent:
            return OutlinedButton(onPressed: null, child: const Text('Solicitado'));

          case FriendshipStatusValue.pendingReceived:
            return ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                // CORREÇÃO: O requisitante é o pet do perfil que estamos vendo (targetPetId)
                await ref.read(friendshipRepositoryProvider).acceptFriendRequest(myPetId: myPetId!, requesterPetId: targetPetId);
                ref.invalidate(friendshipStatusProvider(targetPetId));
              },
              child: const Text('Aceitar'),
            );

          case FriendshipStatusValue.following:
          case FriendshipStatusValue.mutual:
            return OutlinedButton(
              onPressed: () {
                // Lógica para modal de "Deixar de Seguir"
              },
              child: const Text('A Seguir'),
            );

          case FriendshipStatusValue.followedBy:
            return ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                // A ação é a mesma de seguir: enviar uma solicitação
                await ref.read(friendshipRepositoryProvider).sendFriendRequest(myPetId: myPetId!, targetPetId: targetPetId);
                ref.invalidate(friendshipStatusProvider(targetPetId));
              },
              child: const Text('Seguir de Volta'),
            );

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
