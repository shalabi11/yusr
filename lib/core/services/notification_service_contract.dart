import 'package:yusr_app/features/prayer_times/data/models/prayer_time_model.dart';

import 'notification_service.dart';

abstract class INotificationService {
  Future<void> cancelNotification(int id);

  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool playAdhan,
    required String adhanSound,
  });

  Future<void> syncFastingReminders({PrayerTimeModel? prayerTimes});

  Future<void> schedulePersistentNotificationUpdate({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  });

  Future<void> removePersistentNotification();
  Future<void> showPersistentNotification(String title, String body);
}

class NotificationServiceAdapter implements INotificationService {
  @override
  Future<void> cancelNotification(int id) {
    return NotificationService.cancelNotification(id);
  }

  @override
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool playAdhan,
    required String adhanSound,
  }) {
    return NotificationService.schedulePrayerNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      playAdhan: playAdhan,
      adhanSound: adhanSound,
    );
  }

  @override
  Future<void> syncFastingReminders({PrayerTimeModel? prayerTimes}) {
    return NotificationService.syncFastingReminders(prayerTimes: prayerTimes);
  }

  @override
  Future<void> schedulePersistentNotificationUpdate({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) {
    return NotificationService.schedulePersistentNotificationUpdate(
      id: id,
      title: title,
      body: body,
      time: time,
    );
  }

  @override
  Future<void> removePersistentNotification() {
    return NotificationService.removePersistentNotification();
  }

  @override
  Future<void> showPersistentNotification(String title, String body) {
    return NotificationService.showPersistentNotification(title, body);
  }
}
