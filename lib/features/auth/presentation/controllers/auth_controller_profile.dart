part of 'auth_controller.dart';

extension AuthControllerProfile on AuthController {
  Future<String?> updateUsername(String username) async {
    if (!SupabaseBootstrap.isEnabled) {
      return 'حاول مرة أخرى لاحقاً';
    }

    final normalized = username.trim();
    if (normalized.length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }

    try {
      await _updateUsernameUseCase(username: normalized);
      return null;
    } on PostgrestException catch (error) {
      if (_isUsernameTakenError(error.message)) {
        return 'اسم المستخدم مستخدم بالفعل، اختر اسمًا آخر';
      }
      return 'تعذّر تحديث الملف الشخصي';
    } on AuthException catch (error) {
      return error.message;
    } catch (error, stackTrace) {
      AppLogger.error(
        'auth',
        'updateUsername',
        'Unexpected profile update failure.',
        error: error,
        stackTrace: stackTrace,
      );
      return 'تعذّر تحديث الملف الشخصي';
    }
  }

  String? currentEmail() {
    return _getCurrentAuthUserUseCase()?.email;
  }

  String? currentUsername() {
    return _getCurrentAuthUserUseCase()?.username;
  }

  String? currentAvatarUrl() {
    return _getCurrentAuthUserUseCase()?.avatarUrl;
  }

  Future<ProfileAvatarUpdateResult> updateAvatar({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    if (!SupabaseBootstrap.isEnabled) {
      return const ProfileAvatarUpdateResult(
        errorMessage: 'حاول مرة أخرى لاحقاً',
      );
    }

    if (bytes.isEmpty) {
      return const ProfileAvatarUpdateResult(
        errorMessage: 'تعذّر قراءة الصورة المختارة',
      );
    }

    try {
      final avatarUrl = await _updateAvatarUseCase(
        bytes: bytes,
        fileExtension: fileExtension,
      );

      return ProfileAvatarUpdateResult(avatarUrl: avatarUrl);
    } on StorageException {
      return const ProfileAvatarUpdateResult(
        errorMessage: 'تعذّر رفع الصورة، تحقق من إعدادات التخزين',
      );
    } on PostgrestException {
      return const ProfileAvatarUpdateResult(
        errorMessage: 'تعذّر تحديث الملف الشخصي',
      );
    } on AuthException catch (error) {
      return ProfileAvatarUpdateResult(errorMessage: error.message);
    } catch (error, stackTrace) {
      AppLogger.error(
        'auth',
        'updateAvatar',
        'Unexpected avatar update failure.',
        error: error,
        stackTrace: stackTrace,
      );
      return const ProfileAvatarUpdateResult(
        errorMessage: 'تعذّر تحديث صورة الملف الشخصي',
      );
    }
  }

  bool isCurrentUserAnonymous() {
    final user = _getCurrentAuthUserUseCase();
    if (user == null) {
      return true;
    }
    return user.isAnonymous;
  }
}
