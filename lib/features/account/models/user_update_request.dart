class UserUpdateRequest {
  final String name;

  UserUpdateRequest({required this.name});

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
