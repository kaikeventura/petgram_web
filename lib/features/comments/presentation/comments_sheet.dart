import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/comments/providers/comments_provider.dart';
import 'package:petgram_web/features/comments/repositories/comment_repository.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const CommentsSheet({super.key, required this.postId});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final _textController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_textController.text.isEmpty || _isPosting) return;

    setState(() => _isPosting = true);

    try {
      await ref
          .read(commentRepositoryProvider)
          .createComment(postId: widget.postId, text: _textController.text);
      _textController.clear();
      ref.invalidate(commentsProvider(widget.postId)); // Invalida para recarregar
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao enviar comentário: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
     try {
      await ref.read(commentRepositoryProvider).deleteComment(commentId);
      ref.invalidate(commentsProvider(widget.postId));
       if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Comentário removido.')));
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao remover comentário: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));
    final currentPetId = ref.watch(petContextProvider.select((pet) => pet?.id));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Expanded(
            child: commentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(child: Text('Nenhum comentário ainda.'));
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isOwner = comment.author.id == currentPetId;

                    return ListTile(
                      leading: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/pets/${comment.author.id}');
                          },
                          child: CircleAvatar(
                            backgroundImage: comment.author.avatarUrl != null
                                ? NetworkImage(comment.author.avatarUrl!)
                                : null,
                            child: comment.author.avatarUrl == null
                                ? Text(comment.author.name[0].toUpperCase())
                                : null,
                          ),
                        ),
                      ),
                      title: Text(comment.author.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(comment.text),
                      trailing: isOwner
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteComment(comment.id),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Adicione um comentário...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                _isPosting
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _postComment,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
