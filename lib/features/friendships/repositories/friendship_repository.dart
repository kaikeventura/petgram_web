import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/friendships/models/friendship_status.dart';

final friendshipRepositoryProvider = Provider<FriendshipRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FriendshipRepository(dio);
});

class FriendshipRepository {
  final Dio _dio;
  FriendshipRepository(this._dio);

  Future<FriendshipState> getFriendshipStatus({
    required String myPetId,
    required String targetPetId,
  }) async {
    if (myPetId == targetPetId) {
      return FriendshipState(FriendshipStatusValue.isMe);
    }

    final response = await _dio.get(
      '/friendships/status/$targetPetId',
      options: Options(headers: {'X-Pet-Id': myPetId}),
    );

    final status = response.data['status'] as String;

    switch (status) {
      case 'NONE':
        return FriendshipState(FriendshipStatusValue.none);
      case 'PENDING_SENT':
        return FriendshipState(FriendshipStatusValue.pendingSent);
      case 'PENDING_RECEIVED':
        return FriendshipState(FriendshipStatusValue.pendingReceived, pendingRequesterId: targetPetId);
      case 'FOLLOWING':
        return FriendshipState(FriendshipStatusValue.following);
      case 'FOLLOWED_BY':
        return FriendshipState(FriendshipStatusValue.followedBy);
      case 'MUTUAL':
        return FriendshipState(FriendshipStatusValue.mutual);
      case 'PENDING_FOLLOW_BACK':
        return FriendshipState(FriendshipStatusValue.pendingFollowBack);
      case 'ACCEPT_FOLLOW_BACK': // <-- NOVO MAPEAMENTO
        return FriendshipState(FriendshipStatusValue.acceptFollowBack, pendingRequesterId: targetPetId);
      default:
        return FriendshipState(FriendshipStatusValue.none);
    }
  }

  Future<List<dynamic>> getPendingRequests({required String myPetId}) async {
    final response = await _dio.get(
      '/friendships/requests/pending',
      options: Options(headers: {'X-Pet-Id': myPetId}),
    );
    return response.data as List<dynamic>;
  }

  Future<void> sendFriendRequest({required String myPetId, required String targetPetId}) async {
    await _dio.post(
      '/friendships/request',
      data: {'targetPetId': targetPetId},
      options: Options(headers: {'X-Pet-Id': myPetId}),
    );
  }

  Future<void> acceptFriendRequest({required String myPetId, required String requesterPetId}) async {
    await _dio.post(
      '/friendships/accept',
      data: {'requesterPetId': requesterPetId},
      options: Options(headers: {'X-Pet-Id': myPetId}),
    );
  }

  Future<void> unfollowPet({required String myPetId, required String targetPetId}) async {
    await _dio.delete(
      '/friendships/unfollow/$targetPetId',
      options: Options(headers: {'X-Pet-Id': myPetId}),
    );
  }
}
