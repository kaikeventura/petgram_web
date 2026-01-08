import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/presentation/widgets/skeleton_widgets.dart';
import 'package:petgram_web/features/friendships/presentation/friendship_action_button.dart';
import 'package:petgram_web/features/pet/presentation/widgets/profile_widgets.dart';
import 'package:petgram_web/features/pet/providers/profile_providers.dart';

class PublicPetProfileScreen extends ConsumerStatefulWidget {
  final String petId;
  const PublicPetProfileScreen({super.key, required this.petId});

  @override
  ConsumerState<PublicPetProfileScreen> createState() => _PublicPetProfileScreenState();
}

class _PublicPetProfileScreenState extends ConsumerState<PublicPetProfileScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final petDetails = ref.watch(petProfileProvider(widget.petId));
    final petPosts = ref.watch(petPostsProvider(widget.petId));

    return Scaffold(
      appBar: AppBar(
        title: petDetails.when(
          data: (pet) => Text(pet.name),
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const Text('Erro'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(petProfileProvider(widget.petId));
          ref.invalidate(petPostsProvider(widget.petId));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: petDetails.when(
                data: (pet) {
                  return ProfileHeader(
                    pet: pet,
                    postsCount: petPosts.asData?.value.length,
                    actionButton: FriendshipActionButton(targetPetId: pet.id),
                  );
                },
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
}
