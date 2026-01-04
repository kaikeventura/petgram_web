// O enum não é mais necessário, pois só buscamos um tipo de resultado.

class SearchResult {
  final String id;
  final String name;
  final String? subtitle; // Raça do pet
  final String? avatarUrl;

  SearchResult({
    required this.id,
    required this.name,
    this.subtitle,
    this.avatarUrl,
  });
}
