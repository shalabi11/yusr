part of '../notification_service.dart';

Future<void> _showPersistentNotification({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required String title,
  required String body,
}) async {
  await notificationsPlugin.show(
    id: 0,
    title: title,
    body: body,
    notificationDetails: _persistentNotificationDetails,
  );
}

Future<void> _schedulePersistentNotificationUpdate({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required NotificationDetails details,
  required int id,
  required String title,
  required String body,
  required DateTime time,
}) async {
  var scheduledDate = tz.TZDateTime.from(time, tz.local);
  final now = tz.TZDateTime.now(tz.local);
  if (!scheduledDate.isAfter(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  try {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  } on PlatformException {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

Future<void> _removePersistentNotification(
  FlutterLocalNotificationsPlugin notificationsPlugin,
) async {
  await notificationsPlugin.cancel(id: 0);
}

Future<void> _cancelNotification(
  FlutterLocalNotificationsPlugin notificationsPlugin,
  int id,
) async {
  await notificationsPlugin.cancel(id: id);
}

const NotificationDetails _persistentNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'prayer_sticky_channel',
    'Prayer Sticky Notification',
    channelDescription: 'Ongoing notification for next prayer',
    importance: Importance.low,
    priority: Priority.low,
    ongoing: true,
    autoCancel: false,
    playSound: false,
    enableVibration: false,
  ),
  iOS: DarwinNotificationDetails(presentSound: false),
);
