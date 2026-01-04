import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petgram_web/features/account/providers/account_providers.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(accountControllerProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${state.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações da Conta')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Divider(height: 40),
          Text(
            'Zona de Perigo',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Excluir minha conta',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _showDeleteConfirmationDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    final isDeleting = ref.watch(accountControllerProvider).isLoading;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Excluir Conta Permanentemente?'),
          content: const Text(
            'Esta ação é irreversível. Todos os seus dados, pets e publicações serão apagados para sempre. Você tem certeza?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            if (isDeleting)
              const CircularProgressIndicator()
            else
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
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
      },
    );
  }
}
