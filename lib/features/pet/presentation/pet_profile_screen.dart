import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:petgram_web/features/friendships/presentation/friendship_action_button.dart';
import 'package:petgram_web/features/pet/presentation/widgets/profile_widgets.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';
import 'package:petgram_web/features/pet/providers/pet_list_provider.dart';
import 'package:petgram_web/features/pet/providers/profile_providers.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPet = ref.watch(petContextProvider);

    if (currentPet == null) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhum pet selecionado. Recarregue o app.'),
        ),
      );
    }

    final petDetails = ref.watch(petProfileProvider(currentPet.id));
    final petPosts = ref.watch(petPostsProvider(currentPet.id));

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _showPetSelector(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currentPet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              ref.read(petContextProvider.notifier).clearPet();
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(petProfileProvider(currentPet.id));
          ref.invalidate(petPostsProvider(currentPet.id));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: petDetails.when(
                data: (pet) => ProfileHeader(
                  pet: pet,
                  postsCount: petPosts.asData?.value.length,
                  actionButton: FriendshipActionButton(targetPetId: pet.id),
                ),
                loading: () => const Center(heightFactor: 5, child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erro ao carregar perfil: $e')),
              ),
            ),
            petPosts.when(
              data: (posts) => PostsGrid(posts: posts),
              loading: () => const SliverToBoxAdapter(child: Center(heightFactor: 5, child: CircularProgressIndicator())),
              error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Erro ao carregar posts: $e'))),
            ),
          ],
        ),
      ),
    );
  }

  void _showPetSelector(BuildContext context, WidgetRef ref) {
    final myPets = ref.watch(myPetsProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return myPets.when(
          data: (pets) => ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: pet.avatarUrl != null ? NetworkImage(pet.avatarUrl!) : null,
                  child: pet.avatarUrl == null ? Text(pet.name[0].toUpperCase()) : null,
                ),
                title: Text(pet.name),
                onTap: () {
                  ref.read(petContextProvider.notifier).selectPet(pet);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erro ao carregar lista de pets: $e')),
        );
      },
    );
  }
}
