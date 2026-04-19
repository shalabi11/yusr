part of '../notification_service.dart';

Future<void> _syncFastingReminders({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required int fastingMondayId,
  required int fastingThursdayId,
  required List<int> whiteDaysIds,
  required String cachedPrayerTimesKey,
  PrayerTimeModel? prayerTimes,
}) async {
  await _cancelFastingReminders(
    notificationsPlugin: notificationsPlugin,
    fastingMondayId: fastingMondayId,
    fastingThursdayId: fastingThursdayId,
    whiteDaysIds: whiteDaysIds,
  );

  if (!StorageService.fastingRemindersEnabled) {
    await StorageService.setLastWhiteDaysScheduleToken(null);
    return;
  }

  final TimeOfDay? ishaTime = _resolveIshaTime(
    prayerTimes: prayerTimes,
    cachedPrayerTimesKey: cachedPrayerTimesKey,
  );
  if (ishaTime == null) {
    debugPrint('Skipping fasting reminders sync: no available Isha time.');
    return;
  }

  if (StorageService.mondayThursdayReminderEnabled) {
    await _scheduleWeeklyNotification(
      notificationsPlugin: notificationsPlugin,
      id: fastingMondayId,
      title: 'تذكير صيام الاثنين',
      body: 'غدًا الاثنين، لا تنسَ نية الصيام.',
      day: DateTime.sunday,
      time: ishaTime,
    );

    await _scheduleWeeklyNotification(
      notificationsPlugin: notificationsPlugin,
      id: fastingThursdayId,
      title: 'تذكير صيام الخميس',
      body: 'غدًا الخميس، لا تنسَ نية الصيام.',
      day: DateTime.wednesday,
      time: ishaTime,
    );
  }

  if (StorageService.whiteDaysReminderEnabled) {
    await _syncWhiteDaysReminders(
      notificationsPlugin: notificationsPlugin,
      ishaTime: ishaTime,
      whiteDaysIds: whiteDaysIds,
    );
  } else {
    await StorageService.setLastWhiteDaysScheduleToken(null);
  }
}

Future<void> _cancelFastingReminders({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required int fastingMondayId,
  required int fastingThursdayId,
  required List<int> whiteDaysIds,
}) async {
  await _cancelNotification(notificationsPlugin, fastingMondayId);
  await _cancelNotification(notificationsPlugin, fastingThursdayId);
  for (final id in whiteDaysIds) {
    await _cancelNotification(notificationsPlugin, id);
  }
}
