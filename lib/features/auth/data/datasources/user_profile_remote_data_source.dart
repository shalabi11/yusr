import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class UserProfileRemoteDataSource {
  Future<void> updateUsername({required String username});

  Future<String> updateAvatar({
    required Uint8List bytes,
    required String fileExtension,
  });
}

class SupabaseUserProfileRemoteDataSource
    implements UserProfileRemoteDataSource {
  SupabaseUserProfileRemoteDataSource(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  SupabaseClient get _client => _supabaseClient ?? Supabase.instance.client;

  @override
  Future<void> updateUsername({required String username}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً.');
      }

      await _client.from('user_profiles').upsert({
        'id': user.id,
        'username': username,
      });
    } catch (_) {
      throw Exception('فشل تحديث اسم المستخدم.');
    }
  }

  @override
  Future<String> updateAvatar({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً.');
      }

      final normalizedExtension = fileExtension.startsWith('.')
          ? fileExtension.substring(1)
          : fileExtension;
      final fileName = '${_fallbackUsername(user)}.$normalizedExtension';
      final storagePath = '${user.id}/$fileName';

      await _client.storage
          .from('avatars')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage
          .from('avatars')
          .getPublicUrl(storagePath);

      await _client.from('user_profiles').upsert({
        'id': user.id,
        'avatar_url': publicUrl,
      });

      return publicUrl;
    } catch (_) {
      throw Exception('فشل تحديث صورة الحساب.');
    }
  }

  String _fallbackUsername(User user) {
    final emailPrefix = user.email?.split('@').first.trim();
    if (emailPrefix != null && emailPrefix.isNotEmpty) {
      return emailPrefix;
    }

    final sanitizedUserId = user.id.replaceAll('-', '');
    if (sanitizedUserId.length <= 8) {
      return sanitizedUserId;
    }

    return sanitizedUserId.substring(0, 8);
  }
}
