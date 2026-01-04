import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/network/dio_provider.dart';
import 'package:petgram_web/features/notifications/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});

class NotificationRepository {
  final Dio _dio;
  NotificationRepository(this._dio);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final List<dynamic> data = response.data;
      return data.map((json) => NotificationModel.fromMap(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/notifications/mark-as-read');
    } catch (e) {
      rethrow;
    }
  }
}
