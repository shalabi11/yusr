import 'package:yusr_app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:yusr_app/features/auth/domain/entities/sign_up_result.dart';
import 'dart:typed_data';

abstract class AuthRepository {
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<SignUpResult> signUpWithEmail({
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

  AuthUserEntity? getCurrentUser();
}
