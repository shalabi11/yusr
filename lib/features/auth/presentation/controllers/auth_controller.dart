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
import 'package:yusr_app/core/utils/app_logger.dart';

part 'auth_controller_submit.dart';
part 'auth_controller_profile.dart';

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
}
