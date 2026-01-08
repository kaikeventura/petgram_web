import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/presentation/widgets/skeleton_widgets.dart';
import 'package:petgram_web/features/friendships/presentation/friendship_action_button.dart';
import 'package:petgram_web/features/pet/presentation/widgets/profile_widgets.dart';
import 'package:petgram_web/features/pet/providers/profile_providers.dart';

class PublicPetProfileScreen extends ConsumerWidget {
  final String petId;
  const PublicPetProfileScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petDetails = ref.watch(petProfileProvider(petId));
    final petPosts = ref.watch(petPostsProvider(petId));

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
          ref.invalidate(petProfileProvider(petId));
          ref.invalidate(petPostsProvider(petId));
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
            petPosts.when(
              data: (posts) => PostsGrid(posts: posts),
              loading: () => const SliverToBoxAdapter(child: GridSkeleton()),
              error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Erro ao carregar posts: $e'))),
            ),
          ],
        ),
      ),
    );
  }
}
