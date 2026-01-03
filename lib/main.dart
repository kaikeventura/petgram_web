import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/auth/presentation/screens/login_screen.dart';
import 'package:petgram_web/features/feed/presentation/screens/feed_screen.dart';

// Provider para o GoRouter para que ele possa ler outros providers
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'feed',
            builder: (context, state) => const FeedScreen(),
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
        scaffoldBackgroundColor: Colors.grey[100], // Um fundo mais suave
        cardTheme: const CardThemeData( // Correção: CardTheme -> CardThemeData
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: 8.0),
        ),
      ),
      routerConfig: router,
    );
  }
}
