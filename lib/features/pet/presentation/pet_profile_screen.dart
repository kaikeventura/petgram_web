import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/core/presentation/widgets/skeleton_widgets.dart';
import 'package:petgram_web/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:petgram_web/features/friendships/presentation/friendship_action_button.dart';
import 'package:petgram_web/features/pet/presentation/widgets/profile_widgets.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';
import 'package:petgram_web/features/pet/providers/pet_list_provider.dart';
import 'package:petgram_web/features/pet/providers/profile_providers.dart';

class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({super.key});

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
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
                loading: () => const ProfileHeaderSkeleton(),
                error: (e, st) => Center(child: Text('Erro ao carregar perfil: $e')),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.grid_on, color: _isGridView ? Colors.blue : Colors.grey),
                      onPressed: () => setState(() => _isGridView = true),
                    ),
                    IconButton(
                      icon: Icon(Icons.list, color: !_isGridView ? Colors.blue : Colors.grey),
                      onPressed: () => setState(() => _isGridView = false),
                    ),
                  ],
                ),
              ),
            ),
            petPosts.when(
              data: (posts) => _isGridView 
                  ? PostsGrid(posts: posts) 
                  : PostsList(posts: posts),
              loading: () => const SliverToBoxAdapter(child: GridSkeleton()),
              error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Erro ao carregar posts: $e'))),
            ),
          ],
        ),
      ),
    );
  }

  void _showPetSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        return Consumer(
          builder: (context, ref, child) {
            final myPets = ref.watch(myPetsProvider);
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
                      Navigator.of(modalContext).pop();
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erro ao carregar lista de pets: $e')),
            );
          },
        );
      },
    );
  }
}
