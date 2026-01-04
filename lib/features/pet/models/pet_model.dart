class PetModel {
  final String id;
  final String name;
  final String breed;
  final String birthDate;
  final String? avatarUrl;
  final String ownerId;

  PetModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    this.avatarUrl,
    required this.ownerId,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      birthDate: json['birthDate'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      ownerId: json['ownerId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'birthDate': birthDate,
      'avatarUrl': avatarUrl,
      'ownerId': ownerId,
    };
  }
}
