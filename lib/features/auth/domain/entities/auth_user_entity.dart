class AuthUserEntity {
  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.avatarUrl,
    required this.isAnonymous,
  });

  final String id;
  final String? email;
  final String? username;
  final String? avatarUrl;
  final bool isAnonymous;
}
