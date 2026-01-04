import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/features/account/models/user_profile_model.dart';
import 'package:petgram_web/features/account/repositories/account_repository.dart';
import 'package:petgram_web/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';

final accountProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.getAccountProfile();
});

final accountControllerProvider =
    StateNotifierProvider<AccountController, AsyncValue<void>>((ref) {
  return AccountController(ref);
});

class AccountController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  AccountController(this._ref) : super(const AsyncData(null));

  Future<bool> deleteAccount() async {
    state = const AsyncLoading();
    try {
      await _ref.read(accountRepositoryProvider).deleteAccount();
      // Limpa a sessão local
      await _ref.read(authNotifierProvider.notifier).logout();
      _ref.read(petContextProvider.notifier).clearPet();
      state = const AsyncData(null);
      return true;
    } catch (e, s) {
      state = AsyncError(e, s);
      return false;
    }
  }
}
