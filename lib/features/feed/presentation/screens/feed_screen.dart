import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/feed/presentation/providers/feed_provider.dart';
import 'package:petgram_web/features/feed/presentation/widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsyncValue = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetGram'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: feedAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Erro ao carregar o feed: $err'),
            ),
            data: (posts) {
              if (posts.isEmpty) {
                return const Center(
                  child: Text('Nenhuma publicação encontrada.'),
                );
              }
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(post: post);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
