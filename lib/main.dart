import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:petgram_web/features/auth/presentation/notifiers/auth_state.dart';
import 'package:petgram_web/features/auth/presentation/screens/login_screen.dart';
import 'package:petgram_web/features/feed/presentation/screens/create_post_screen.dart';
import 'package:petgram_web/features/feed/presentation/screens/feed_screen.dart';
import 'package:petgram_web/features/main/presentation/main_screen.dart';
import 'package:petgram_web/features/notifications/presentation/notifications_screen.dart';
import 'package:petgram_web/features/pet/presentation/create_pet_screen.dart';
import 'package:petgram_web/features/pet/presentation/pet_profile_screen.dart';
import 'package:petgram_web/features/pet/presentation/pet_selection_screen.dart';
import 'package:petgram_web/features/pet/presentation/public_pet_profile_screen.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';
import 'package:petgram_web/features/search/presentation/search_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
    _ref.listen(petContextProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/feed',
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final currentPet = ref.read(petContextProvider);
      
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSelectingPet = state.uri.toString() == '/select-pet';
      final isCreatingPet = state.uri.toString() == '/create-pet';

      if (!isLoggedIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return currentPet == null ? '/select-pet' : '/feed';
      }
      
      if (isLoggedIn && currentPet == null) {
          if (isCreatingPet || isSelectingPet) return null;
          return '/select-pet';
      }
      
      if (isLoggedIn && currentPet != null && (isSelectingPet || isLoggingIn)) {
          return '/feed';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/select-pet',
        builder: (context, state) => const PetSelectionScreen(),
      ),
      GoRoute(
        path: '/create-pet',
        builder: (context, state) => const CreatePetScreen(),
      ),
       GoRoute(
        path: '/pets/:petId',
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return PublicPetProfileScreen(petId: petId);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: 'create-post',
                pageBuilder: (context, state) => const MaterialPage(
                  fullscreenDialog: true,
                  child: CreatePostScreen(),
                ),
              ),
            ]
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const PetProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PetGram',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: 8.0),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      routerConfig: router,
    );
  }
}
