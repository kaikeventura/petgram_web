import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';
import 'package:petgram_web/features/pet/providers/pet_list_provider.dart';

class PetSelectionScreen extends ConsumerWidget {
  const PetSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsyncValue = ref.watch(myPetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Selecione um Pet')),
      body: petsAsyncValue.when(
        data: (pets) {
          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Você ainda não tem pets cadastrados.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/create-pet'),
                    child: const Text('Cadastrar meu primeiro Pet'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: pet.avatarUrl != null
                            ? NetworkImage(pet.avatarUrl!)
                            : null,
                        child: pet.avatarUrl == null
                            ? Text(pet.name[0].toUpperCase())
                            : null,
                      ),
                      title: Text(pet.name),
                      subtitle: Text(pet.breed),
                      onTap: () {
                        ref.read(petContextProvider.notifier).selectPet(pet);
                        context.go('/feed');
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/create-pet'),
                  icon: const Icon(Icons.add),
                  label: const Text('Novo Pet'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}
