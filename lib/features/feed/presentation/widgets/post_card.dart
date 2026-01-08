import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/comments/presentation/comments_sheet.dart';
import 'package:petgram_web/features/feed/data/models/post_model.dart';
import 'package:petgram_web/features/likes/presentation/likes_sheet.dart';
import 'package:petgram_web/features/post/repositories/post_repository.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  bool _isLikeActionInProgress = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onLikePressed() async {
    if (_isLikeActionInProgress) return;

    final originalIsLiked = _isLiked;
    final originalLikeCount = _likeCount;

    setState(() {
      _isLikeActionInProgress = true;
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    if (_isLiked) {
      _animationController.forward().then((_) => _animationController.reverse());
    }

    try {
      final postRepository = ref.read(postRepositoryProvider);
      if (_isLiked) {
        await postRepository.likePost(widget.post.id);
      } else {
        await postRepository.unlikePost(widget.post.id);
      }
    } catch (e) {
      // Rollback em caso de erro
      setState(() {
        _isLiked = originalIsLiked;
        _likeCount = originalLikeCount;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ${originalIsLiked ? "retirar patada" : "dar patada"} na publicação')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLikeActionInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      context.push('/pets/${widget.post.authorId}');
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.post.authorAvatarUrl != null
                          ? NetworkImage(widget.post.authorAvatarUrl!)
                          : null,
                      child: widget.post.authorAvatarUrl == null
                          ? const Icon(Icons.pets, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.post.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Image.network(
            widget.post.photoUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 400,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 400,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: IconButton(
                    icon: Icon(
                      Icons.pets,
                      color: _isLiked ? Colors.orange : Colors.grey,
                    ),
                    onPressed: _onLikePressed,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 0.7,
                        child: CommentsSheet(postId: widget.post.id),
                      ),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_likeCount > 0) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => LikesSheet(postId: widget.post.id),
                      );
                    }
                  },
                  child: Text(
                    '$_likeCount patadas',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${widget.post.authorName} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.post.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.post.commentCount > 0)
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => FractionallySizedBox(
                          heightFactor: 0.7,
                          child: CommentsSheet(postId: widget.post.id),
                        ),
                      );
                    },
                    child: Text(
                      'Ver todos os ${widget.post.commentCount} comentários',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
