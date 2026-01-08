import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/notifications/models/notification_model.dart';
import 'package:petgram_web/features/notifications/repositories/notification_repository.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';

// Transformamos em StreamProvider para permitir atualizações em tempo real (Polling)
final notificationsProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) async* {
  // 1. Assiste ao ID do pet ativo.
  final activePetId = ref.watch(petContextProvider.select((pet) => pet?.id));

  if (activePetId == null) {
    yield [];
    return;
  }

  final repository = ref.watch(notificationRepositoryProvider);

  // 2. Busca inicial imediata (para não esperar 5 segundos na primeira vez)
  try {
    final initialData = await repository.getNotifications(petId: activePetId);
    yield initialData;
  } catch (e) {
    // Se falhar na primeira, repassa o erro para a UI tratar
    throw e;
  }

  // 3. Configura o Polling: busca atualizações a cada 5 segundos
  final timer = Stream.periodic(const Duration(seconds: 5));

  await for (final _ in timer) {
    // Verifica se o provider ainda está ativo antes de buscar
    try {
      final updatedData = await repository.getNotifications(petId: activePetId);
      yield updatedData;
    } catch (e) {
      // Se falhar durante o polling (ex: oscilação de internet), 
      // ignoramos o erro silenciosamente para manter os dados antigos na tela
      // e não assustar o usuário com uma tela de erro repentina.
    }
  }
});

// O unreadCountProvider continua igual, mas agora reage a cada atualização do stream acima
final unreadCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(notificationsProvider).when(
        data: (notifications) => notifications.where((n) => !n.isRead).length,
        loading: () => 0,
        error: (e, s) => 0,
      );
});
