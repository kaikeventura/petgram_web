import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/account/models/user_profile_model.dart';
import 'package:petgram_web/features/account/models/user_update_request.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AccountRepository(dio);
});

class AccountRepository {
  final Dio _dio;
  AccountRepository(this._dio);

  Future<UserProfile> getAccountProfile() async {
    try {
      final response = await _dio.get('/account');
      return UserProfile.fromMap(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile> updateAccountProfile(UserUpdateRequest data) async {
    try {
      final response = await _dio.put('/account', data: data.toMap());
      return UserProfile.fromMap(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/account/password', data: {
        'oldPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/account');
    } catch (e) {
      rethrow;
    }
  }
}
