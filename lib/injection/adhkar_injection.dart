import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_remote_data_source.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_repository.dart';
import 'package:yusr_app/features/adhkar/domain/usecases/adhkar_use_cases.dart';

void registerAdhkarDependencies(GetIt sl) {
  if (!sl.isRegistered<AdhkarRepository>()) {
    sl.registerLazySingleton<AdhkarRepository>(
      () => AdhkarRepository(
        remoteDataSource: sl.isRegistered<SupabaseClient>()
            ? AdhkarRemoteDataSource(sl<SupabaseClient>())
            : null,
      ),
    );
  }

  if (!sl.isRegistered<AdhkarUseCases>()) {
    sl.registerLazySingleton<AdhkarUseCases>(
      () => AdhkarUseCases(sl<AdhkarRepository>()),
    );
  }
}
