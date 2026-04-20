import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/features/home/data/daily_ayah_repository.dart';
import 'package:yusr_app/features/home/domain/usecases/daily_ayah_use_cases.dart';
import 'package:yusr_app/features/home/presentation/screens/home_screen.dart';
import 'package:yusr_app/features/prayer_times/data/models/prayer_time_model.dart';
import 'package:yusr_app/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_countdown_service.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

import '../../support/fake_notification_service.dart';
import '../../support/fake_storage_service.dart';

class FakeDailyAyahRepository extends DailyAyahRepository {
  FakeDailyAyahRepository();

  @override
  Future<DailyAyah> getDailyAyah() async {
    return const DailyAyah(
      content: '﴿وَاذْكُرُوا اللَّهَ﴾',
      source: 'البقرة: 200',
    );
  }
}

class FakePrayerTimesRepositoryForHome extends PrayerTimesRepository {
  FakePrayerTimesRepositoryForHome()
    : super(storageService: FakeStorageService());

  int fetchCount = 0;

  @override
  Future<Either<Failure, PrayerTimesFetchResult>> getPrayerTimes() async {
    fetchCount += 1;
    return Right(
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
    );
  }
}

void main() {
  testWidgets('pull-to-refresh triggers prayer times fetch', (tester) async {
    final repo = FakePrayerTimesRepositoryForHome();
    final cubit = PrayerTimesCubit(
      repo,
      FakeStorageService(),
      FakeNotificationService(),
      PrayerCountdownService(),
    );

    await tester.pumpWidget(
      BlocProvider<PrayerTimesCubit>.value(
        value: cubit,
        child: MaterialApp(
          home: HomeScreen(
            dailyAyahUseCases: DailyAyahUseCases(FakeDailyAyahRepository()),
          ),
        ),
      ),
    );

    expect(repo.fetchCount, 0);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(repo.fetchCount, 1);
    await cubit.close();
  });
}
