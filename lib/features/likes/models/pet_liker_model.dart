class PetLikerModel {
  final String id;
  final String name;
  final String? avatarUrl;

  PetLikerModel({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory PetLikerModel.fromMap(Map<String, dynamic> map) {
    return PetLikerModel(
      id: map['petId'] ?? '',
      name: map['petName'] ?? 'Pet Anônimo',
      // O avatarUrl não vem neste endpoint, então será nulo.
      // A UI já tem um fallback para isso (mostrar a inicial do nome).
      avatarUrl: map['avatarUrl'],
    );
  }
}
