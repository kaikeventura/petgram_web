import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petgram_web/core/storage/storage_provider.dart';
import 'package:petgram_web/features/pet/models/pet_model.dart';

final petContextProvider = StateNotifierProvider<PetContextNotifier, PetModel?>((ref) {
  return PetContextNotifier(ref);
});

class PetContextNotifier extends StateNotifier<PetModel?> {
  final Ref _ref;
  static const _storageKey = 'selected_pet_data';

  PetContextNotifier(this._ref) : super(null) {
    _restorePet();
  }

  Future<void> _restorePet() async {
    final jsonString = await _ref.read(secureStorageProvider).read(key: _storageKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        state = PetModel.fromJson(json);
      } catch (_) {
        await _ref.read(secureStorageProvider).delete(key: _storageKey);
      }
    }
  }

  void selectPet(PetModel pet) {
    state = pet;
    _persistPet(pet);
  }

  void clearPet() {
    state = null;
    _ref.read(secureStorageProvider).delete(key: _storageKey);
  }

  Future<void> _persistPet(PetModel pet) async {
    final jsonString = jsonEncode(pet.toJson());
    await _ref.read(secureStorageProvider).write(key: _storageKey, value: jsonString);
  }
}
