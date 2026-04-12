import 'package:yusr_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yusr_app/features/auth/data/models/auth_user_model.dart';
import 'dart:typed_data';
import 'package:yusr_app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:yusr_app/features/auth/domain/entities/sign_up_result.dart';
import 'package:yusr_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmail(email: email, password: password);
  }

  @override
  Future<SignUpResult> signUpWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.signUpWithEmail(
      username: username,
      email: email,
      password: password,
    );

    if (response.session == null) {
      return SignUpResult.emailConfirmationRequired;
    }

    return SignUpResult.signedIn;
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<void> updateUsername({required String username}) {
    return _remoteDataSource.updateUsername(username: username);
  }

  @override
  Future<String> updateAvatar({
    required Uint8List bytes,
    required String fileExtension,
  }) {
    return _remoteDataSource.updateAvatar(
      bytes: bytes,
      fileExtension: fileExtension,
    );
  }

  @override
  AuthUserEntity? getCurrentUser() {
    final user = _remoteDataSource.getCurrentUser();
    if (user == null) {
      return null;
    }
    return AuthUserModel.fromSupabaseUser(user);
  }
}
