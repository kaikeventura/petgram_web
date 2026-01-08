import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/feed/presentation/widgets/post_card.dart';
import 'package:petgram_web/features/post/providers/post_detail_provider.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicação'),
      ),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro ao carregar publicação: $e')),
        data: (post) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PostCard(post: post),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
