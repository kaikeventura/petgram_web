class PostProfileModel {
  final String id;
  final String photoUrl;

  PostProfileModel({
    required this.id,
    required this.photoUrl,
  });

  factory PostProfileModel.fromJson(Map<String, dynamic> json) {
    return PostProfileModel(
      id: json['id'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }
}
