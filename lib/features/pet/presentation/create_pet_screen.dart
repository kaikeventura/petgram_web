import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';
import 'package:petgram_web/features/pet/repositories/pet_repository.dart';
import 'package:petgram_web/features/pet/providers/pet_list_provider.dart';

class CreatePetScreen extends ConsumerStatefulWidget {
  const CreatePetScreen({super.key});

  @override
  ConsumerState<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends ConsumerState<CreatePetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _birthDateController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _createPet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(petRepositoryProvider);
      final newPet = await repository.createPet(
        name: _nameController.text,
        breed: _breedController.text,
        birthDate: _birthDateController.text,
      );

      ref.invalidate(myPetsProvider);
      ref.read(petContextProvider.notifier).selectPet(newPet);

      if (mounted) {
        context.go('/feed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar pet: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Pet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Raça'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento (YYYY-MM-DD)',
                  hintText: '2023-01-01',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createPet,
                      child: const Text('Salvar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
