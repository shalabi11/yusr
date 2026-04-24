import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/supabase_auth_remote_data_source.dart';
import '../../data/datasources/user_profile_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
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

  return AuthController(authRepository);
}
