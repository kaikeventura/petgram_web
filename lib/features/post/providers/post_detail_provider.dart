import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/feed/data/models/post_model.dart';
import 'package:petgram_web/features/post/repositories/post_repository.dart';

final postDetailProvider = FutureProvider.autoDispose.family<Post, String>((ref, postId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPostById(postId);
});
