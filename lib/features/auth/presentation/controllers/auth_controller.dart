import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/features/auth/domain/entities/sign_up_result.dart';
import 'package:yusr_app/features/auth/domain/usecases/get_current_auth_user_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/sign_in_with_email_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/sign_up_with_email_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/update_avatar_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/update_username_use_case.dart';
import 'package:yusr_app/features/auth/presentation/models/profile_avatar_update_result.dart';
import 'package:yusr_app/features/auth/presentation/models/auth_submit_result.dart';
import 'package:yusr_app/features/auth/presentation/models/auth_submit_status.dart';

class AuthController {
  const AuthController({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignOutUseCase signOutUseCase,
    required UpdateUsernameUseCase updateUsernameUseCase,
    required UpdateAvatarUseCase updateAvatarUseCase,
    required GetCurrentAuthUserUseCase getCurrentAuthUserUseCase,
  }) : _signInWithEmailUseCase = signInWithEmailUseCase,
       _signUpWithEmailUseCase = signUpWithEmailUseCase,
       _signOutUseCase = signOutUseCase,
       _updateUsernameUseCase = updateUsernameUseCase,
       _updateAvatarUseCase = updateAvatarUseCase,
       _getCurrentAuthUserUseCase = getCurrentAuthUserUseCase;

  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignOutUseCase _signOutUseCase;
  final UpdateUsernameUseCase _updateUsernameUseCase;
  final UpdateAvatarUseCase _updateAvatarUseCase;
  final GetCurrentAuthUserUseCase _getCurrentAuthUserUseCase;

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
    } catch (_) {
      return const AuthSubmitResult(
        status: AuthSubmitStatus.failure,
        message: 'حاول مرة أخرى لاحقاً',
      );
    }
  }

  Future<void> signOut() {
    return _signOutUseCase();
  }

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
    } catch (_) {
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
    } on StorageException catch (_) {
      return const ProfileAvatarUpdateResult(
        errorMessage: 'تعذّر رفع الصورة، تحقق من إعدادات التخزين',
      );
    } on PostgrestException catch (_) {
      return const ProfileAvatarUpdateResult(
        errorMessage: 'تعذّر تحديث الملف الشخصي',
      );
    } on AuthException catch (error) {
      return ProfileAvatarUpdateResult(errorMessage: error.message);
    } catch (_) {
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
