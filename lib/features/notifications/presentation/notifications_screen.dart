import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/notifications/models/notification_model.dart';
import 'package:petgram_web/features/notifications/providers/notification_providers.dart';
import 'package:petgram_web/features/notifications/repositories/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllAsRead();
              ref.invalidate(notificationsProvider);
            },
            child: const Text('Marcar tudo como lido'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('Nenhuma notificação por aqui.'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return NotificationTile(notification: notifications[index]);
            },
          );
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      leading: CircleAvatar(
        child: _getIconForType(notification.type),
      ),
      title: Text(
        notification.message,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(
        'há 2h', // Lógica de tempo relativo a ser implementada
      ),
      onTap: () {
        if (notification.link.isNotEmpty) {
          context.push(notification.link);
        }
      },
    );
  }

  Icon _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.postLike:
        return const Icon(Icons.pets, color: Colors.red);
      case NotificationType.postComment:
        return const Icon(Icons.comment, color: Colors.blue);
      case NotificationType.friendshipRequest:
      case NotificationType.friendshipAccepted:
        return const Icon(Icons.person_add, color: Colors.green);
      default:
        return const Icon(Icons.notifications);
    }
  }
}
