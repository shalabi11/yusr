import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpWithEmail({
    required String username,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> updateUsername({required String username});

  Future<String> updateAvatar({
    required Uint8List bytes,
    required String fileExtension,
  });

  User? getCurrentUser();
}
