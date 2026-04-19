class ProfileAvatarUpdateResult {
  const ProfileAvatarUpdateResult({this.avatarUrl, this.errorMessage});

  final String? avatarUrl;
  final String? errorMessage;

  bool get isSuccess => avatarUrl != null && errorMessage == null;
}
