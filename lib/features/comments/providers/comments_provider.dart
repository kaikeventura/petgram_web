import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/comments/models/comment_model.dart';
import 'package:petgram_web/features/comments/repositories/comment_repository.dart';

final commentsProvider =
    FutureProvider.autoDispose.family<List<Comment>, String>((ref, postId) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.getComments(postId);
});
