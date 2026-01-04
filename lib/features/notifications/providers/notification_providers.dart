import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/notifications/models/notification_model.dart';
import 'package:petgram_web/features/notifications/repositories/notification_repository.dart';

// Provider que busca as notificações
final notificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications();
});

// Provider que calcula a contagem de não lidas
final unreadCountProvider = Provider.autoDispose<int>((ref) {
  // Assiste ao provider principal e filtra o resultado
  return ref.watch(notificationsProvider).when(
        data: (notifications) => notifications.where((n) => !n.isRead).length,
        loading: () => 0,
        error: (e, s) => 0,
      );
});
