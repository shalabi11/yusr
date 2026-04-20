import 'package:get_it/get_it.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_countdown_service.dart';

void registerPrayerTimesDependencies(GetIt sl) {
  if (!sl.isRegistered<PrayerCountdownService>()) {
    sl.registerLazySingleton<PrayerCountdownService>(
      PrayerCountdownService.new,
    );
  }

  if (!sl.isRegistered<PrayerTimesRepository>()) {
    sl.registerLazySingleton<PrayerTimesRepository>(
      () => PrayerTimesRepository(storageService: sl<IStorageService>()),
    );
  }
}
