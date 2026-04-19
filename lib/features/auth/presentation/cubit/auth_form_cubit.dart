import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yusr_app/features/auth/presentation/models/auth_submit_status.dart';

import 'auth_form_state.dart';

class AuthFormCubit extends Cubit<AuthFormState> {
  AuthFormCubit(this._authController, {required bool startInSignUpMode})
    : super(AuthFormState.initial(isSignUpMode: startInSignUpMode));

  final AuthController _authController;

  void toggleMode() {
    emit(
      state.copyWith(
        isSignUpMode: !state.isSignUpMode,
        clearErrorMessage: true,
        clearInfoMessage: true,
      ),
    );
  }

  Future<void> submit({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required bool markAccountOnboardingSeenOnSuccess,
  }) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
        clearInfoMessage: true,
        navigateOnSuccess: false,
      ),
    );

    final result = await _authController.submit(
      isSignUpMode: state.isSignUpMode,
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      markAccountOnboardingSeenOnSuccess: markAccountOnboardingSeenOnSuccess,
    );

    if (result.status == AuthSubmitStatus.emailConfirmationRequired) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSignUpMode: false,
          infoMessage: result.message,
          navigateOnSuccess: false,
        ),
      );
      return;
    }

    if (result.status == AuthSubmitStatus.failure) {
      final error = result.message;
      emit(
        state.copyWith(
          isSubmitting: false,
          isSignUpMode: _shouldSwitchToSignIn(error)
              ? false
              : state.isSignUpMode,
          errorMessage: error,
          navigateOnSuccess: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: false, navigateOnSuccess: true));
  }

  void consumeFeedback() {
    emit(
      state.copyWith(
        clearErrorMessage: true,
        clearInfoMessage: true,
        navigateOnSuccess: false,
      ),
    );
  }

  bool _shouldSwitchToSignIn(String? message) {
    if (message == null) {
      return false;
    }

    return message.contains('موجود بالفعل');
  }
}
