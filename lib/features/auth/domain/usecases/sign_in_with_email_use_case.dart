import 'package:yusr_app/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
