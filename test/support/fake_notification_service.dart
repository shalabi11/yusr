import 'package:yusr_app/core/services/notification_service_contract.dart';
import 'package:yusr_app/features/prayer_times/data/models/prayer_time_model.dart';

class FakeNotificationService implements INotificationService {
  final List<int> canceledIds = <int>[];
  int prayerScheduleCalls = 0;
  int persistentShowCalls = 0;
  int persistentRemoveCalls = 0;
  int persistentUpdateCalls = 0;
  int fastingSyncCalls = 0;

  @override
  Future<void> cancelNotification(int id) async {
    canceledIds.add(id);
  }

  @override
  Future<void> removePersistentNotification() async {
    persistentRemoveCalls += 1;
  }

  @override
  Future<void> schedulePersistentNotificationUpdate({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    persistentUpdateCalls += 1;
  }

  @override
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool playAdhan,
    required String adhanSound,
  }) async {
    prayerScheduleCalls += 1;
  }

  @override
  Future<void> showPersistentNotification(String title, String body) async {
    persistentShowCalls += 1;
  }

  @override
  Future<void> syncFastingReminders({PrayerTimeModel? prayerTimes}) async {
    fastingSyncCalls += 1;
  }
}
