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

    final response = await _dio.get('/friendships/status', queryParameters: {
      'pet1': myPetId,
      'pet2': targetPetId,
    });

    final status = response.data['status'];

    switch (status) {
      case 'ACCEPTED':
        return FriendshipState(FriendshipStatusValue.accepted);
      case 'BLOCKED':
        return FriendshipState(FriendshipStatusValue.blocked);
      case 'PENDING':
        final pendingRequests = await getPendingRequests(myPetId: myPetId);
        final didIReceive = pendingRequests.any((req) => req['requesterId'] == targetPetId);
        if (didIReceive) {
          return FriendshipState(FriendshipStatusValue.receivedRequest, pendingRequesterId: targetPetId);
        } else {
          return FriendshipState(FriendshipStatusValue.sentRequest);
        }
      default:
        return FriendshipState(FriendshipStatusValue.none);
    }
  }

  Future<List<dynamic>> getPendingRequests({required String myPetId}) async {
    final response = await _dio.get('/friendships/requests/pending/$myPetId');
    return response.data as List<dynamic>;
  }

  Future<void> sendFriendRequest({required String myPetId, required String targetPetId}) async {
    await _dio.post('/friendships/request', data: {
      'requesterPetId': myPetId,
      'addresseePetId': targetPetId,
    });
  }

  Future<void> acceptFriendRequest({required String myPetId, required String requesterPetId}) async {
    await _dio.post('/friendships/accept', data: {
      'requesterPetId': requesterPetId,
      'addresseePetId': myPetId,
    });
  }

  Future<void> removeFriendship({required String myPetId, required String targetPetId}) async {
    await _dio.post('/friendships/remove', data: {
      'requesterPetId': myPetId,
      'addresseePetId': targetPetId,
    });
  }
}
