import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/search/models/search_result_model.dart';
import 'package:petgram_web/features/search/repositories/search_repository.dart';

// Provider para o texto da busca
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider para os resultados com debounce
final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  // Se a query estiver vazia, retorna uma lista vazia imediatamente.
  if (query.isEmpty) {
    return [];
  }

  // Debounce: espera 500ms antes de fazer a chamada.
  // O Riverpod cancela a requisição anterior se uma nova for feita nesse meio tempo.
  await Future.delayed(const Duration(milliseconds: 500));

  // Busca os resultados
  final repository = ref.watch(searchRepositoryProvider);
  return repository.search(query);
});
