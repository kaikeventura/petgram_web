import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/account/models/user_update_request.dart';
import 'package:petgram_web/features/account/providers/account_providers.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountProvider);
    final controllerState = ref.watch(accountControllerProvider);

    ref.listen(accountProvider, (_, state) {
      if (state is AsyncData && state.value != null) {
        _nameController.text = state.value!.name;
        _emailController.text = state.value!.email;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações da Conta')),
      body: accountAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro ao carregar dados: $e')),
        data: (user) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Seção de Dados Pessoais
              Text('Dados Pessoais', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (não pode ser alterado)'),
                readOnly: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () async {
                        final request = UserUpdateRequest(name: _nameController.text);
                        final success = await ref.read(accountControllerProvider.notifier).updateAccountProfile(request);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
                          );
                        }
                      },
                child: controllerState.isLoading ? const CircularProgressIndicator() : const Text('Salvar Alterações'),
              ),

              const Divider(height: 40),

              // Seção de Segurança
              Text('Segurança', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Alterar Senha'),
                onTap: () => _showPasswordChangeDialog(context),
              ),

              const Divider(height: 40),

              // Zona de Perigo
              Text(
                'Zona de Perigo',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                title: Text('Excluir minha conta', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => _showDeleteConfirmationDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPasswordChangeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _PasswordChangeSheet(),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(builder: (context, ref, child) {
          final isDeleting = ref.watch(accountControllerProvider).isLoading;
          return AlertDialog(
            title: const Text('Excluir Conta Permanentemente?'),
            content: const Text('Esta ação é irreversível. Todos os seus dados, pets e publicações serão apagados para sempre. Você tem certeza?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              if (isDeleting)
                const CircularProgressIndicator()
              else
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  child: const Text('Sim, Excluir Tudo'),
                  onPressed: () async {
                    final success = await ref.read(accountControllerProvider.notifier).deleteAccount();
                    if (success && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
            ],
          );
        });
      },
    );
  }
}

class _PasswordChangeSheet extends ConsumerStatefulWidget {
  const _PasswordChangeSheet();

  @override
  ConsumerState<_PasswordChangeSheet> createState() => __PasswordChangeSheetState();
}

class __PasswordChangeSheetState extends ConsumerState<_PasswordChangeSheet> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(accountControllerProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Alterar Senha', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: 'Senha Atual'),
              obscureText: true,
              validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'Nova Senha'),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Campo obrigatório';
                if (value!.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirmar Nova Senha'),
              obscureText: true,
              validator: (value) {
                if (value != _newPasswordController.text) return 'As senhas não coincidem';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controllerState.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final success = await ref.read(accountControllerProvider.notifier).updatePassword(
                              currentPassword: _currentPasswordController.text,
                              newPassword: _newPasswordController.text,
                            );
                        if (success && mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Senha alterada com sucesso!')),
                          );
                        }
                      }
                    },
              child: controllerState.isLoading ? const CircularProgressIndicator() : const Text('Alterar Senha'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
