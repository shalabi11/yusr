import 'dart:typed_data';

import 'package:yusr_app/features/auth/data/models/auth_user_model.dart';
import 'package:yusr_app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:yusr_app/features/auth/domain/entities/sign_up_result.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_profile_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._authRemoteDataSource,
    this._userProfileRemoteDataSource,
  );

  final AuthRemoteDataSource _authRemoteDataSource;
  final UserProfileRemoteDataSource _userProfileRemoteDataSource;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _authRemoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _authRemoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      username: username,
    );

    return response.session == null
        ? SignUpResult.emailConfirmationRequired
        : SignUpResult.signedIn;
  }

  @override
  Future<void> signOut() {
    return _authRemoteDataSource.signOut();
  }

  @override
  AuthUserEntity? getCurrentUser() {
    final currentUser = _authRemoteDataSource.getCurrentUser();
    if (currentUser == null) return null;

    return AuthUserModel.fromSupabaseUser(currentUser);
  }

  @override
  Future<void> updateUsername({required String username}) {
    return _userProfileRemoteDataSource.updateUsername(username: username);
  }

  @override
  Future<String> updateAvatar({
    required Uint8List bytes,
    required String fileExtension,
  }) {
    return _userProfileRemoteDataSource.updateAvatar(
      bytes: bytes,
      fileExtension: fileExtension,
    );
  }
}
