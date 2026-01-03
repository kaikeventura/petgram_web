class Post {
  final String id;
  final String photoUrl;
  final String caption;
  final String authorId;
  final String authorName;
  // O authorPhotoUrl não vem no PostResponse, teremos que buscar separadamente no futuro.
  // Por enquanto, vamos usar um placeholder.
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.photoUrl,
    required this.caption,
    required this.authorId,
    required this.authorName,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    // O autor está aninhado
    final authorMap = map['author'] as Map<String, dynamic>? ?? {};

    return Post(
      id: map['id'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      caption: map['caption'] ?? '',
      authorId: authorMap['id'] ?? '',
      authorName: authorMap['name'] ?? 'Usuário Anônimo',
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
