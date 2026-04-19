part of 'auth_controller.dart';

extension AuthControllerSubmit on AuthController {
  Future<AuthSubmitResult> submit({
    required bool isSignUpMode,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required bool markAccountOnboardingSeenOnSuccess,
  }) async {
    if (!SupabaseBootstrap.isEnabled) {
      return const AuthSubmitResult(
        status: AuthSubmitStatus.failure,
        message: 'حاول مرة أخرى لاحقاً',
      );
    }

    if (email.isEmpty || password.isEmpty) {
      return const AuthSubmitResult(
        status: AuthSubmitStatus.failure,
        message: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور',
      );
    }

    if (isSignUpMode && username.trim().isEmpty) {
      return const AuthSubmitResult(
        status: AuthSubmitStatus.failure,
        message: 'الرجاء إدخال اسم المستخدم',
      );
    }

    if (isSignUpMode && password != confirmPassword) {
      return const AuthSubmitResult(
        status: AuthSubmitStatus.failure,
        message: 'الرقم السري غير متطابق',
      );
    }

    try {
      if (!isSignUpMode) {
        await _signInWithEmailUseCase(email: email, password: password);
        final currentUser = _getCurrentAuthUserUseCase();
        if (currentUser == null || currentUser.isAnonymous) {
          return const AuthSubmitResult(
            status: AuthSubmitStatus.failure,
            message: 'حدث خطأ ما',
          );
        }
      } else {
        final signUpResult = await _signUpWithEmailUseCase(
          username: username.trim(),
          email: email,
          password: password,
        );
        if (signUpResult == SignUpResult.emailConfirmationRequired) {
          return const AuthSubmitResult(
            status: AuthSubmitStatus.emailConfirmationRequired,
            message: 'الرجاء تأكيد بريدك الإلكتروني لتسجيل الدخول.',
          );
        }
      }

      if (markAccountOnboardingSeenOnSuccess) {
        await StorageService.setAccountOnboardingSeen(true);
      }

      return const AuthSubmitResult(status: AuthSubmitStatus.success);
    } on AuthException catch (error) {
      if (isSignUpMode && _isExistingAccountError(error.message)) {
        return const AuthSubmitResult(
          status: AuthSubmitStatus.failure,
          message: 'هذا الحساب موجود بالفعل، قم بتسجيل الدخول',
        );
      }

      return AuthSubmitResult(
        status: AuthSubmitStatus.failure,
        message: error.message,
      );
    } on PostgrestException catch (error) {
      if (_isUsernameTakenError(error.message)) {
        return const AuthSubmitResult(
          status: AuthSubmitStatus.failure,
          message: 'اسم المستخدم مستخدم بالفعل، اختر اسمًا آخر',
        );
      }

      return const AuthSubmitResult(
        status: AuthSubmitStatus.failure,
        message: 'حاول مرة أخرى لاحقاً',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'auth',
        'submit',
        'Unexpected authentication failure.',
        error: error,
        stackTrace: stackTrace,
      );
      return const AuthSubmitResult(
        status: AuthSubmitStatus.failure,
        message: 'حاول مرة أخرى لاحقاً',
      );
    }
  }

  Future<void> signOut() {
    return _signOutUseCase();
  }

  bool _isExistingAccountError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('already registered') ||
        normalized.contains('user already exists') ||
        normalized.contains('email address already');
  }

  bool _isUsernameTakenError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('user_profiles') ||
        normalized.contains('username') ||
        normalized.contains('duplicate key');
  }
}
