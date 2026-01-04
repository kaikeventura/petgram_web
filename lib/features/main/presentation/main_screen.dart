import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/feed/presentation/providers/feed_provider.dart';
import 'package:petgram_web/features/notifications/providers/notification_providers.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';
import 'package:petgram_web/features/pet/providers/profile_providers.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context, ref),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Busca'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(unreadCount.toString()),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications),
            ),
            label: 'Notificações',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/notifications')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, WidgetRef ref) {
    switch (index) {
      case 0:
        ref.invalidate(feedProvider);
        context.go('/feed');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/notifications');
        break;
      case 3:
        final currentPet = ref.read(petContextProvider);
        if (currentPet != null) {
          ref.invalidate(petProfileProvider(currentPet.id));
          ref.invalidate(petPostsProvider(currentPet.id));
        }
        context.go('/profile');
        break;
    }
  }
}
