import 'package:yusr_app/features/auth/domain/entities/sign_up_result.dart';
import 'package:yusr_app/features/auth/domain/repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  const SignUpWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<SignUpResult> call({
    required String username,
    required String email,
    required String password,
  }) {
    return _repository.signUpWithEmail(
      username: username,
      email: email,
      password: password,
    );
  }
}
