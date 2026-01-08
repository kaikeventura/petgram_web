import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/likes/providers/likes_provider.dart';

class LikesSheet extends ConsumerWidget {
  final String postId;
  const LikesSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likersAsync = ref.watch(postLikersProvider(postId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Patadas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: likersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Erro ao carregar: $err')),
            data: (likers) {
              if (likers.isEmpty) {
                return const Center(child: Text('Ninguém curtiu isso ainda.'));
              }
              return ListView.builder(
                itemCount: likers.length,
                itemBuilder: (context, index) {
                  final pet = likers[index];
                  return ListTile(
                    leading: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/pets/${pet.id}');
                        },
                        child: CircleAvatar(
                          backgroundImage: pet.avatarUrl != null
                              ? NetworkImage(pet.avatarUrl!)
                              : null,
                          child: pet.avatarUrl == null
                              ? Text(pet.name[0].toUpperCase())
                              : null,
                        ),
                      ),
                    ),
                    title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
