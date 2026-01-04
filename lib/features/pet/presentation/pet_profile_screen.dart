import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petgram_web/features/pet/models/pet_model.dart';
import 'package:petgram_web/features/pet/models/post_profile_model.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';
import 'package:petgram_web/features/pet/providers/pet_list_provider.dart';
import 'package:petgram_web/features/pet/providers/profile_providers.dart';
import 'package:petgram_web/features/pet/repositories/pet_repository.dart';

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

class _ProfileHeader extends ConsumerStatefulWidget {
  final PetModel pet;
  final int? postsCount;
  const _ProfileHeader({required this.pet, this.postsCount});

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  bool _isLoading = false;

  Future<void> _onAvatarTapped() async {
    final imageSource = await _showImageSourceDialog();
    if (imageSource == null) return;

    final image = await ImagePicker().pickImage(source: imageSource);
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(petRepositoryProvider);
      await repo.updatePetAvatar(petId: widget.pet.id, image: image);

      ref.invalidate(petProfileProvider(widget.pet.id));
      ref.invalidate(petContextProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar a foto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

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
                  GestureDetector(
                    onTap: _onAvatarTapped,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: widget.pet.avatarUrl != null
                              ? NetworkImage(widget.pet.avatarUrl!)
                              : null,
                          child: widget.pet.avatarUrl == null
                              ? const Icon(Icons.pets, size: 40)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                        if (_isLoading)
                          const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(count: widget.postsCount?.toString() ?? '-', label: 'Posts'),
                        _StatItem(count: widget.pet.followerCount.toString(), label: 'Amigos'),
                        _StatItem(count: widget.pet.followingCount.toString(), label: 'Seguindo'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(widget.pet.breed, style: const TextStyle(color: Colors.grey)),
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
