import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/features/auth/domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.avatarUrl,
    required super.isAnonymous,
  });

  factory AuthUserModel.fromSupabaseUser(User user) {
    final provider = user.appMetadata['provider']?.toString().toLowerCase();
    final identities = user.identities;
    final hasEmailIdentity =
        identities?.any(
          (identity) => identity.provider.toLowerCase() == 'email',
        ) ??
        false;

    final isAnonymous = provider == 'anonymous' || !hasEmailIdentity;
    final username = user.userMetadata?['username']?.toString();
    final avatarUrl = user.userMetadata?['avatar_url']?.toString();

    return AuthUserModel(
      id: user.id,
      email: user.email,
      username: username,
      avatarUrl: avatarUrl,
      isAnonymous: isAnonymous,
    );
  }
}
