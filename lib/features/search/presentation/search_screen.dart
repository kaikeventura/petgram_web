import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/search/providers/search_providers.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Buscar por pets...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
      body: searchQuery.isEmpty
          ? const Center(child: Text('Busque por nome ou raça.'))
          : searchResults.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Erro ao buscar.'),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(searchResultsProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (results) {
                if (results.isEmpty) {
                  return const Center(child: Text('Nenhum pet encontrado.'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: result.avatarUrl != null
                            ? NetworkImage(result.avatarUrl!)
                            : null,
                        child: result.avatarUrl == null
                            ? const Icon(Icons.pets)
                            : null,
                      ),
                      title: Text(result.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(result.subtitle ?? ''),
                      onTap: () {
                        // Ação de clique para o perfil do pet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Navegando para o pet ${result.name}')),
                        );
                        // context.push('/profile/${result.id}');
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
