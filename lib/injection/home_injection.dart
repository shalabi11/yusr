import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/features/home/data/daily_ayah_remote_data_source.dart';
import 'package:yusr_app/features/home/data/daily_ayah_repository.dart';
import 'package:yusr_app/features/home/domain/usecases/daily_ayah_use_cases.dart';

void registerHomeDependencies(GetIt sl) {
  if (!sl.isRegistered<DailyAyahRepository>()) {
    sl.registerLazySingleton<DailyAyahRepository>(
      () => DailyAyahRepository(
        remoteDataSource: sl.isRegistered<SupabaseClient>()
            ? DailyAyahRemoteDataSource(sl<SupabaseClient>())
            : null,
      ),
    );
  }

  if (!sl.isRegistered<DailyAyahUseCases>()) {
    sl.registerLazySingleton<DailyAyahUseCases>(
      () => DailyAyahUseCases(sl<DailyAyahRepository>()),
    );
  }
}
