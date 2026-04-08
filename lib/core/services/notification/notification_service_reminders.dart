part of '../notification_service.dart';

Future<void> _scheduleDailyNotification({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required int id,
  required String title,
  required String body,
  required TimeOfDay time,
}) async {
  await _scheduleReminderNotification(
    notificationsPlugin: notificationsPlugin,
    id: id,
    title: title,
    body: body,
    scheduledDate: _nextInstanceOfTime(time),
    details: const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminders_channel_v2',
        'Daily Reminders',
        channelDescription: 'Channel for daily Islamic reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    ),
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<void> _scheduleWeeklyNotification({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required int id,
  required String title,
  required String body,
  required int day,
  required TimeOfDay time,
}) async {
  await _scheduleReminderNotification(
    notificationsPlugin: notificationsPlugin,
    id: id,
    title: title,
    body: body,
    scheduledDate: _nextInstanceOfDayAndTime(day, time),
    details: const NotificationDetails(
      android: AndroidNotificationDetails(
        'weekly_reminders_channel_v2',
        'Weekly Reminders',
        channelDescription: 'Channel for weekly Islamic reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    ),
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
  );
}

Future<void> _scheduleReminderNotification({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required int id,
  required String title,
  required String body,
  required tz.TZDateTime scheduledDate,
  required NotificationDetails details,
  required DateTimeComponents matchDateTimeComponents,
}) async {
  final now = tz.TZDateTime.now(tz.local);
  var nextSchedule = scheduledDate;
  if (!nextSchedule.isAfter(now)) {
    nextSchedule =
        matchDateTimeComponents == DateTimeComponents.dayOfWeekAndTime
        ? nextSchedule.add(const Duration(days: 7))
        : nextSchedule.add(const Duration(days: 1));
  }

  try {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextSchedule,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  } on PlatformException {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextSchedule,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }
}

Future<void> _syncReminders({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required List<ReminderModel> reminders,
}) async {
  for (var r in reminders) {
    try {
      final int? id = int.tryParse(r.id);
      if (id == null) {
        debugPrint('Skipping reminder with invalid id: ${r.id}');
        continue;
      }
      await _cancelNotification(notificationsPlugin, id);

      if (r.enabled) {
        String localizedTitle = r.titleKey.tr;
        String localizedBody = (r.subtitleKey == AppStrings.weeklyFriday)
            ? 'لا تنسَ قراءة سورة الكهف'
            : 'حان وقت $localizedTitle';

        if (r.subtitleKey == AppStrings.weeklyFriday) {
          await _scheduleWeeklyNotification(
            notificationsPlugin: notificationsPlugin,
            id: id,
            title: localizedTitle,
            body: localizedBody,
            day: DateTime.friday,
            time: r.timeOfDay,
          );
        } else {
          await _scheduleDailyNotification(
            notificationsPlugin: notificationsPlugin,
            id: id,
            title: localizedTitle,
            body: localizedBody,
            time: r.timeOfDay,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to sync reminder ${r.id}: $e');
    }
  }
}

tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

tz.TZDateTime _nextInstanceOfDayAndTime(int day, TimeOfDay time) {
  tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
  while (scheduledDate.weekday != day) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}
