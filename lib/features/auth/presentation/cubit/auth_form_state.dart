import 'package:equatable/equatable.dart';

class AuthFormState extends Equatable {
  const AuthFormState({
    required this.isSignUpMode,
    required this.isSubmitting,
    this.errorMessage,
    this.infoMessage,
    required this.navigateOnSuccess,
  });

  const AuthFormState.initial({required bool isSignUpMode})
    : this(
        isSignUpMode: isSignUpMode,
        isSubmitting: false,
        errorMessage: null,
        infoMessage: null,
        navigateOnSuccess: false,
      );

  final bool isSignUpMode;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;
  final bool navigateOnSuccess;

  AuthFormState copyWith({
    bool? isSignUpMode,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? infoMessage,
    bool clearInfoMessage = false,
    bool? navigateOnSuccess,
  }) {
    return AuthFormState(
      isSignUpMode: isSignUpMode ?? this.isSignUpMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
      navigateOnSuccess: navigateOnSuccess ?? this.navigateOnSuccess,
    );
  }

  @override
  List<Object?> get props => [
    isSignUpMode,
    isSubmitting,
    errorMessage,
    infoMessage,
    navigateOnSuccess,
  ];
}
