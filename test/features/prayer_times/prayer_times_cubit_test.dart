import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/features/prayer_times/data/models/prayer_time_model.dart';
import 'package:yusr_app/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_countdown_service.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

import '../../support/fake_notification_service.dart';
import '../../support/fake_storage_service.dart';

class FakePrayerTimesRepository extends PrayerTimesRepository {
  FakePrayerTimesRepository(this._result)
    : super(storageService: FakeStorageService());

  final Either<Failure, PrayerTimesFetchResult> _result;
  int fetchCount = 0;

  @override
  Future<Either<Failure, PrayerTimesFetchResult>> getPrayerTimes() async {
    fetchCount += 1;
    return _result;
  }
}

void main() {
  group('PrayerTimesCubit', () {
    test(
      'emits loaded state with countdown and schedules notifications',
      () async {
        final storage = FakeStorageService()
          ..prayerOffset = 5
          ..playAdhan = true
          ..stickyNotification = true
          ..adhanSound = 'adhan1';
        final notifications = FakeNotificationService();
        final repository = FakePrayerTimesRepository(
          Right(
            PrayerTimesFetchResult(
              prayerTimes: PrayerTimeModel(
                fajr: '05:00',
                sunrise: '06:10',
                dhuhr: '12:15',
                asr: '15:30',
                maghrib: '18:00',
                isha: '19:30',
              ),
              locationName: 'Riyadh',
              isFromCache: false,
            ),
          ),
        );

        final cubit = PrayerTimesCubit(
          repository,
          storage,
          notifications,
          PrayerCountdownService(),
        );
        await cubit.fetchPrayerTimes(force: true);

        expect(cubit.state, isA<PrayerTimesLoaded>());
        final loaded = cubit.state as PrayerTimesLoaded;
        expect(loaded.locationName, 'Riyadh');
        expect(loaded.countdownText, isNotEmpty);
        expect(loaded.nextPrayerKey, isNotEmpty);
        expect(repository.fetchCount, 1);
        expect(notifications.prayerScheduleCalls, greaterThan(0));

        await cubit.close();
      },
    );

    test('returns error state when repository fails', () async {
      final storage = FakeStorageService();
      final notifications = FakeNotificationService();
      final repository = FakePrayerTimesRepository(
        const Left(ServerFailure('fetch failed')),
      );

      final cubit = PrayerTimesCubit(
        repository,
        storage,
        notifications,
        PrayerCountdownService(),
      );
      await cubit.fetchPrayerTimes(force: true);

      expect(cubit.state, isA<PrayerTimesError>());
      expect((cubit.state as PrayerTimesError).message, 'fetch failed');

      await cubit.close();
    });
  });
}
