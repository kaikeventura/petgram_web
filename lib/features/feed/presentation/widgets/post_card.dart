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

class _PostCardState extends ConsumerState<PostCard> with TickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  bool _isLikeActionInProgress = false;

  late AnimationController _likeButtonController;
  late Animation<double> _likeButtonAnimation;

  late AnimationController _bigPawController;
  late Animation<double> _bigPawAnimation;
  bool _showBigPaw = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;

    // Animação do botão pequeno (Pop Elástico)
    _likeButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duração total do ciclo
    );

    _likeButtonAnimation = TweenSequence<double>([
      // Fase 1: Cresce rápido (Anticipation/Pop)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 30, // 30% do tempo
      ),
      // Fase 2: Volta ao normal com efeito elástico
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70, // 70% do tempo
      ),
    ]).animate(_likeButtonController);

    // Animação da Pata Gigante (Double Tap)
    _bigPawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bigPawAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _bigPawController, curve: Curves.elasticOut),
    );

    _bigPawController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _bigPawController.reverse().then((_) {
              setState(() => _showBigPaw = false);
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _likeButtonController.dispose();
    _bigPawController.dispose();
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

    // Se curtiu, dispara a animação de "Pop"
    if (_isLiked) {
      _likeButtonController.forward(from: 0.0);
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

  void _onDoubleTapLike() {
    setState(() => _showBigPaw = true);
    _bigPawController.forward(from: 0.0);

    if (!_isLiked) {
      _onLikePressed();
    } else {
      // Se já estava curtido, anima o botão pequeno também para feedback visual
      _likeButtonController.forward(from: 0.0);
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
          GestureDetector(
            onDoubleTap: _onDoubleTapLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
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
                if (_showBigPaw)
                  ScaleTransition(
                    scale: _bigPawAnimation,
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 120,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _likeButtonAnimation,
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
