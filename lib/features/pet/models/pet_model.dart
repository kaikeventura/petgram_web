class PetModel {
  final String id;
  final String name;
  final String breed;
  final String birthDate;
  final String? avatarUrl;
  final String ownerId;
  final int followerCount;
  final int followingCount;

  PetModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    this.avatarUrl,
    required this.ownerId,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      birthDate: json['birthDate'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      ownerId: json['ownerId'] as String,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
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
      'followerCount': followerCount,
      'followingCount': followingCount,
    };
  }
}
