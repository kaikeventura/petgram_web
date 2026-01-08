import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/pet/providers/pet_list_providers.dart';

enum PetListType { followers, following }

class PetListSheet extends ConsumerWidget {
  final String petId;
  final PetListType type;

  const PetListSheet({
    super.key,
    required this.petId,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = type == PetListType.followers ? 'Seguidores' : 'Seguindo';
    final provider = type == PetListType.followers
        ? petFollowersProvider(petId)
        : petFollowingProvider(petId);
    
    final petsAsync = ref.watch(provider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: petsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Erro ao carregar: $err')),
            data: (pets) {
              if (pets.isEmpty) {
                return Center(child: Text('Nenhum pet encontrado em "$title".'));
              }
              return ListView.builder(
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return ListTile(
                    leading: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Fecha o modal
                          context.push('/pets/${pet.id}'); // Navega para o perfil
                        },
                        child: CircleAvatar(
                          backgroundImage: pet.avatarUrl != null
                              ? NetworkImage(pet.avatarUrl!)
                              : null,
                          child: pet.avatarUrl == null
                              ? Text(pet.name[0].toUpperCase())
                              : null,
                        ),
                      ),
                    ),
                    title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(pet.breed),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
