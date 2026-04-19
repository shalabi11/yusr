import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/features/auth/data/datasources/auth_remote_data_source.dart';

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const SupabaseAuthRemoteDataSource();

  static const String _avatarsBucket = 'avatars';

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUpWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    final userId = response.user?.id;
    if (userId != null) {
      await _upsertUserProfile(
        userId: userId,
        username: username,
        avatarUrl: null,
        allowMissingTable: true,
      );
    }

    return response;
  }

  @override
  Future<void> signOut() {
    return Supabase.instance.client.auth.signOut();
  }

  @override
  Future<void> updateUsername({required String username}) async {
    final auth = Supabase.instance.client.auth;
    final userId = auth.currentUser?.id;
    if (userId == null) {
      throw AuthException('المستخدم غير مسجل الدخول');
    }

    await auth.updateUser(UserAttributes(data: {'username': username}));

    await _upsertUserProfile(
      userId: userId,
      username: username,
      avatarUrl: auth.currentUser?.userMetadata?['avatar_url']?.toString(),
      allowMissingTable: false,
    );
  }

  @override
  Future<String> updateAvatar({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final auth = Supabase.instance.client.auth;
    final user = auth.currentUser;
    if (user == null) {
      throw AuthException('المستخدم غير مسجل الدخول');
    }
    final userId = user.id;

    final ext = fileExtension.toLowerCase();
    final objectPath = '$userId/avatar.$ext';

    await Supabase.instance.client.storage
        .from(_avatarsBucket)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentTypeForExtension(ext),
          ),
        );

    final avatarUrl = Supabase.instance.client.storage
        .from(_avatarsBucket)
        .getPublicUrl(objectPath);

    await auth.updateUser(UserAttributes(data: {'avatar_url': avatarUrl}));

    final username = user.userMetadata?['username']?.toString();
    await _upsertUserProfile(
      userId: userId,
      username: _fallbackUsername(username, userId),
      avatarUrl: avatarUrl,
      allowMissingTable: false,
    );

    return avatarUrl;
  }

  @override
  User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }

  Future<void> _upsertUserProfile({
    required String userId,
    required String? username,
    required String? avatarUrl,
    required bool allowMissingTable,
  }) async {
    final resolvedUsername = _fallbackUsername(username, userId);

    try {
      await Supabase.instance.client.from('user_profiles').upsert({
        'user_id': userId,
        'username': resolvedUsername,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      }, onConflict: 'user_id');
    } catch (error) {
      if (allowMissingTable &&
          error is PostgrestException &&
          error.code == '42P01') {
        debugPrint(
          '[Auth] user_profiles table missing; skipping profile persistence.',
        );
        return;
      }

      debugPrint('[Auth] user_profiles upsert failed: $error');
      rethrow;
    }
  }

  String _fallbackUsername(String? username, String userId) {
    final normalized = username?.trim() ?? '';
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return 'user_${userId.substring(0, 8)}';
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
