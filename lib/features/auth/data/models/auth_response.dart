class AuthResponse {
  final String token;

  AuthResponse({required this.token});

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    return AuthResponse(
      token: map['accessToken'] ?? '',
    );
  }
}
