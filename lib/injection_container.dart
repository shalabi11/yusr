import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/core/services/storage/storage_sevice_impl.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_repository.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_remote_data_source.dart';
import 'package:yusr_app/features/home/data/daily_ayah_repository.dart';
import 'package:yusr_app/features/home/data/daily_ayah_remote_data_source.dart';
import 'package:yusr_app/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_catalog_remote_service.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_remote_sync_service.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_remote_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  if (!sl.isRegistered<IStorageService>()) {
    sl.registerLazySingleton<IStorageService>(() => StorageServiceImpl(prefs));
  }
  if (!sl.isRegistered<INotificationService>()) {
    sl.registerLazySingleton<INotificationService>(
      () => NotificationServiceAdapter(),
    );
  }
  if (SupabaseBootstrap.isEnabled && !sl.isRegistered<SupabaseClient>()) {
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }
  StorageService.bind(sl<IStorageService>());

  // Repositories
  if (!sl.isRegistered<PrayerTimesRepository>()) {
    sl.registerLazySingleton<PrayerTimesRepository>(
      () => PrayerTimesRepository(storageService: sl<IStorageService>()),
    );
  }
  if (!sl.isRegistered<RemindersRepository>()) {
    sl.registerLazySingleton<RemindersRepository>(
      () => RemindersRepository(
        remoteSync: sl.isRegistered<SupabaseClient>()
            ? RemindersRemoteSyncService(sl<SupabaseClient>())
            : null,
      ),
    );
  }
  if (!sl.isRegistered<AdhkarRepository>()) {
    sl.registerLazySingleton<AdhkarRepository>(
      () => AdhkarRepository(
        remoteDataSource: sl.isRegistered<SupabaseClient>()
            ? AdhkarRemoteDataSource(sl<SupabaseClient>())
            : null,
      ),
    );
  }
  if (!sl.isRegistered<QuranRepository>()) {
    sl.registerLazySingleton<QuranRepository>(
      () => QuranRepository(
        remoteSync: sl.isRegistered<SupabaseClient>()
            ? QuranRemoteSyncService(sl<SupabaseClient>())
            : null,
        catalogRemote: sl.isRegistered<SupabaseClient>()
            ? QuranCatalogRemoteService(sl<SupabaseClient>())
            : null,
      ),
    );
  }
  if (!sl.isRegistered<DailyAyahRepository>()) {
    sl.registerLazySingleton<DailyAyahRepository>(
      () => DailyAyahRepository(
        remoteDataSource: sl.isRegistered<SupabaseClient>()
            ? DailyAyahRemoteDataSource(sl<SupabaseClient>())
            : null,
      ),
    );
  }

  // Cubits
  if (!sl.isRegistered<SettingsCubit>()) {
    sl.registerFactory<SettingsCubit>(
      () => SettingsCubit(
        sl<IStorageService>(),
        sl<INotificationService>(),
        supabaseClient: sl.isRegistered<SupabaseClient>()
            ? sl<SupabaseClient>()
            : null,
      ),
    );
  }
  if (!sl.isRegistered<PrayerTimesCubit>()) {
    sl.registerFactory<PrayerTimesCubit>(
      () => PrayerTimesCubit(
        sl<PrayerTimesRepository>(),
        sl<IStorageService>(),
        sl<INotificationService>(),
      ),
    );
  }
}
