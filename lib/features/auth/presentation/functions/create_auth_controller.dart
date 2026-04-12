import 'package:yusr_app/features/auth/data/datasources/supabase_auth_remote_data_source.dart';
import 'package:yusr_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yusr_app/features/auth/domain/usecases/get_current_auth_user_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/update_avatar_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/sign_in_with_email_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/sign_up_with_email_use_case.dart';
import 'package:yusr_app/features/auth/domain/usecases/update_username_use_case.dart';
import 'package:yusr_app/features/auth/presentation/controllers/auth_controller.dart';

AuthController createAuthController() {
  const remoteDataSource = SupabaseAuthRemoteDataSource();
  const repository = AuthRepositoryImpl(remoteDataSource);

  return AuthController(
    signInWithEmailUseCase: SignInWithEmailUseCase(repository),
    signUpWithEmailUseCase: SignUpWithEmailUseCase(repository),
    signOutUseCase: SignOutUseCase(repository),
    updateUsernameUseCase: UpdateUsernameUseCase(repository),
    updateAvatarUseCase: UpdateAvatarUseCase(repository),
    getCurrentAuthUserUseCase: GetCurrentAuthUserUseCase(repository),
  );
}
