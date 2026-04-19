part of '../notification_service.dart';

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
    if (hijri.day >= 13 && hijri.day <= 15) whiteDays.add(date);
  }

  if (whiteDays.isEmpty) {
    await StorageService.setLastWhiteDaysScheduleToken(null);
    return;
  }

  final token = whiteDays.map((d) => '${d.year}-${d.month}-${d.day}').join('|');
  if (token == existingToken) return;

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
