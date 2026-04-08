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

TimeOfDay? _resolveIshaTime({
  required PrayerTimeModel? prayerTimes,
  required String cachedPrayerTimesKey,
}) {
  final source = prayerTimes ?? _cachedPrayerTimesModel(cachedPrayerTimesKey);
  if (source == null) return null;

  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(source.isha);
  if (match == null) return null;

  final hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

PrayerTimeModel? _cachedPrayerTimesModel(String cachedPrayerTimesKey) {
  final dynamic data = StorageService.getData(cachedPrayerTimesKey);
  if (data is! Map<String, dynamic>) return null;
  try {
    return PrayerTimeModel.fromJson(data);
  } catch (_) {
    return null;
  }
}

Future<void> _syncWhiteDaysReminders({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required TimeOfDay ishaTime,
  required List<int> whiteDaysIds,
}) async {
  final now = DateTime.now();
  final existingToken = StorageService.lastWhiteDaysScheduleToken;

  final whiteDays = <DateTime>[];
  for (int i = 0; i < 60 && whiteDays.length < 3; i++) {
    final date = now.add(Duration(days: i));
    final hijri = HijriUtils.fromGregorian(date);
    if (hijri.day >= 13 && hijri.day <= 15) {
      whiteDays.add(date);
    }
  }

  if (whiteDays.isEmpty) {
    await StorageService.setLastWhiteDaysScheduleToken(null);
    return;
  }

  final token = whiteDays.map((d) => '${d.year}-${d.month}-${d.day}').join('|');
  if (token == existingToken) {
    return;
  }

  for (int i = 0; i < whiteDays.length && i < whiteDaysIds.length; i++) {
    final day = whiteDays[i];
    final triggerDate = DateTime(
      day.year,
      day.month,
      day.day,
      ishaTime.hour,
      ishaTime.minute,
    ).subtract(const Duration(days: 1));

    await _scheduleOneOffFastingNotification(
      notificationsPlugin: notificationsPlugin,
      id: whiteDaysIds[i],
      title: 'تذكير صيام الأيام البيض',
      body: 'غدًا من الأيام البيض، لا تنسَ نية الصيام.',
      scheduledDate: tz.TZDateTime.from(triggerDate, tz.local),
    );
  }

  await StorageService.setLastWhiteDaysScheduleToken(token);
}

Future<void> _scheduleOneOffFastingNotification({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required int id,
  required String title,
  required String body,
  required tz.TZDateTime scheduledDate,
}) async {
  final now = tz.TZDateTime.now(tz.local);
  var candidate = scheduledDate;
  if (!candidate.isAfter(now)) {
    candidate = candidate.add(const Duration(days: 1));
  }

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'fasting_reminders_channel_v1',
      'Fasting Reminders',
      channelDescription: 'Reminders for voluntary fasting days',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    ),
    iOS: DarwinNotificationDetails(presentSound: true),
  );

  try {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: candidate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  } on PlatformException {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: candidate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
