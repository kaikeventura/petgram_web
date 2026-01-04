import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/pet/models/pet_model.dart';
import 'package:petgram_web/features/pet/models/post_profile_model.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';
import 'package:petgram_web/features/pet/providers/profile_providers.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPet = ref.watch(petContextProvider);

    if (currentPet == null) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhum pet selecionado.'),
        ),
      );
    }

    final petDetails = ref.watch(petProfileProvider(currentPet.id));
    final petPosts = ref.watch(petPostsProvider(currentPet.id));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(petProfileProvider(currentPet.id));
          ref.invalidate(petPostsProvider(currentPet.id));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: petDetails.when(
                data: (pet) => _ProfileHeader(pet: pet, postsCount: petPosts.asData?.value.length),
                loading: () => const Center(heightFactor: 5, child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erro ao carregar perfil: $e')),
              ),
            ),
            petPosts.when(
              data: (posts) => _PostsGrid(posts: posts),
              loading: () => const SliverToBoxAdapter(child: Center(heightFactor: 5, child: CircularProgressIndicator())),
              error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Erro ao carregar posts: $e'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final PetModel pet;
  final int? postsCount;
  const _ProfileHeader({required this.pet, this.postsCount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: pet.avatarUrl != null ? NetworkImage(pet.avatarUrl!) : null,
                    child: pet.avatarUrl == null ? const Icon(Icons.pets, size: 40) : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(count: postsCount?.toString() ?? '-', label: 'Posts'),
                            _StatItem(count: '128', label: 'Amigos'),
                            _StatItem(count: '256', label: 'Seguindo'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(pet.breed, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Editar Perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _PostsGrid extends StatelessWidget {
  final List<PostProfileModel> posts;
  const _PostsGrid({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          heightFactor: 5,
          child: Text('Nenhuma publicação ainda.'),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final post = posts[index];
            return GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Clicou no post ${post.id}')),
                );
              },
              child: Image.network(
                post.photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null ? child : const Center(child: CircularProgressIndicator());
                },
              ),
            );
          },
          childCount: posts.length,
        ),
      ),
    );
  }
}
