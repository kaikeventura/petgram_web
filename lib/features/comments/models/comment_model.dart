class Author {
  final String id;
  final String name;
  final String? avatarUrl;

  Author({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Anônimo',
      avatarUrl: map['avatarUrl'],
    );
  }
}

class Comment {
  final String id;
  final String text;
  final Author author;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      author: Author.fromMap(map['author'] ?? {}),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
