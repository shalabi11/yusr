import 'package:yusr_app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:yusr_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentAuthUserUseCase {
  const GetCurrentAuthUserUseCase(this._repository);

  final AuthRepository _repository;

  AuthUserEntity? call() {
    return _repository.getCurrentUser();
  }
}
