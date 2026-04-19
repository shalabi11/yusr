import 'dart:typed_data';

import 'package:yusr_app/features/auth/domain/repositories/auth_repository.dart';

class UpdateAvatarUseCase {
  const UpdateAvatarUseCase(this._repository);

  final AuthRepository _repository;

  Future<String> call({
    required Uint8List bytes,
    required String fileExtension,
  }) {
    return _repository.updateAvatar(bytes: bytes, fileExtension: fileExtension);
  }
}
