import 'package:yusr_app/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:yusr_app/features/auth/presentation/functions/create_auth_controller.dart';

AuthFormCubit createAuthFormCubit({required bool startInSignUpMode}) {
  final controller = createAuthController();
  return AuthFormCubit(controller, startInSignUpMode: startInSignUpMode);
}
