import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/feed/data/models/post_model.dart';
import 'package:petgram_web/features/feed/data/repositories/post_repository.dart';

final feedProvider = FutureProvider<List<Post>>((ref) async {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getFeed();
});
