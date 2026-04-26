import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/supabase_auth_remote_data_source.dart';
import '../../data/datasources/user_profile_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/get_current_auth_user_use_case.dart';
import '../../domain/usecases/sign_in_with_email_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/sign_up_with_email_use_case.dart';
import '../../domain/usecases/update_avatar_use_case.dart';
import '../../domain/usecases/update_username_use_case.dart';
import '../controllers/auth_controller.dart';

AuthController createAuthController() {
  final supabaseClient = Supabase.instance.client;
  final authRemoteDataSource = SupabaseAuthRemoteDataSource(supabaseClient);
  final userProfileRemoteDataSource = SupabaseUserProfileRemoteDataSource(
    supabaseClient,
  );
  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource,
    userProfileRemoteDataSource,
  );

  return AuthController(
    signInWithEmailUseCase: SignInWithEmailUseCase(authRepository),
    signUpWithEmailUseCase: SignUpWithEmailUseCase(authRepository),
    signOutUseCase: SignOutUseCase(authRepository),
    updateUsernameUseCase: UpdateUsernameUseCase(authRepository),
    updateAvatarUseCase: UpdateAvatarUseCase(authRepository),
    getCurrentAuthUserUseCase: GetCurrentAuthUserUseCase(authRepository),
  );
}
