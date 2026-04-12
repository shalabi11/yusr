import 'package:yusr_app/features/auth/domain/repositories/auth_repository.dart';

class UpdateUsernameUseCase {
  const UpdateUsernameUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String username}) {
    return _repository.updateUsername(username: username);
  }
}
