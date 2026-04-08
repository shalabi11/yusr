import 'package:get_it/get_it.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_repository.dart';
import 'package:yusr_app/features/home/data/daily_ayah_repository.dart';
import 'package:yusr_app/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
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
  StorageService.bind(sl<IStorageService>());

  // Repositories
  if (!sl.isRegistered<PrayerTimesRepository>()) {
    sl.registerLazySingleton<PrayerTimesRepository>(
      () => PrayerTimesRepository(storageService: sl<IStorageService>()),
    );
  }
  if (!sl.isRegistered<RemindersRepository>()) {
    sl.registerLazySingleton<RemindersRepository>(() => RemindersRepository());
  }
  if (!sl.isRegistered<AdhkarRepository>()) {
    sl.registerLazySingleton<AdhkarRepository>(() => AdhkarRepository());
  }
  if (!sl.isRegistered<QuranRepository>()) {
    sl.registerLazySingleton<QuranRepository>(() => QuranRepository());
  }
  if (!sl.isRegistered<DailyAyahRepository>()) {
    sl.registerLazySingleton<DailyAyahRepository>(() => DailyAyahRepository());
  }

  // Cubits
  if (!sl.isRegistered<SettingsCubit>()) {
    sl.registerFactory<SettingsCubit>(
      () => SettingsCubit(sl<IStorageService>(), sl<INotificationService>()),
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
