import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/notifications/models/notification_model.dart';
import 'package:petgram_web/features/notifications/repositories/notification_repository.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';

// Provider que busca as notificações e se reconstrói quando o pet ativo muda.
final notificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) {
  // 1. Assiste ao ID do pet ativo. Se o ID mudar, este provider será re-executado.
  final activePetId = ref.watch(petContextProvider.select((pet) => pet?.id));

  // 2. Se não houver ID de pet ativo, retorna uma lista vazia e não faz chamada de API.
  if (activePetId == null) {
    return Future.value([]);
  }

  // 3. Busca as notificações para o pet ativo.
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications(petId: activePetId);
});

// Provider que calcula a contagem de não lidas.
// Este provider também será re-executado automaticamente porque depende do `notificationsProvider`.
final unreadCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(notificationsProvider).when(
        data: (notifications) => notifications.where((n) => !n.isRead).length,
        loading: () => 0,
        error: (e, s) => 0,
      );
});
