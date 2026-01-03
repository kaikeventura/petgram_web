import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petgram_web/features/feed/data/repositories/post_repository.dart';
import 'package:petgram_web/features/feed/presentation/providers/feed_provider.dart';

enum CreatePostStatus { initial, loading, success, error }

class CreatePostState {
  final CreatePostStatus status;
  final String? errorMessage;

  CreatePostState({this.status = CreatePostStatus.initial, this.errorMessage});

  CreatePostState copyWith({
    CreatePostStatus? status,
    String? errorMessage,
  }) {
    return CreatePostState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final createPostProvider =
    StateNotifierProvider<CreatePostNotifier, CreatePostState>((ref) {
  return CreatePostNotifier(ref);
});

class CreatePostNotifier extends StateNotifier<CreatePostState> {
  final Ref _ref;

  CreatePostNotifier(this._ref) : super(CreatePostState());

  Future<void> createPost({
    required XFile image,
    required String caption,
  }) async {
    try {
      state = state.copyWith(status: CreatePostStatus.loading);
      final postRepository = _ref.read(postRepositoryProvider);
      await postRepository.createPost(image: image, caption: caption);
      
      // Invalida o feed para forçar a recarga na próxima vez que for lido
      _ref.invalidate(feedProvider);

      state = state.copyWith(status: CreatePostStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: CreatePostStatus.error,
        errorMessage: 'Falha ao criar a publicação.',
      );
    }
  }

  // Método para resetar o estado, útil ao reentrar na tela
  void resetState() {
    state = CreatePostState();
  }
}
