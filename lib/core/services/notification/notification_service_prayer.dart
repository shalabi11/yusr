part of '../notification_service.dart';

Future<void> _schedulePrayerNotification({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required String channelVersion,
  required int id,
  required String title,
  required String body,
  required DateTime time,
  required bool playAdhan,
  required String adhanSound,
}) async {
  final scheduledDate = tz.TZDateTime.from(time, tz.local);
  if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

  NotificationDetails details = _prayerNotificationDetails(
    playAdhan: playAdhan,
    adhanSound: adhanSound,
    allowCustomSound: true,
    channelVersion: channelVersion,
  );

  try {
    await _zonedScheduleWithFallback(
      notificationsPlugin: notificationsPlugin,
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      details: details,
    );
  } on PlatformException catch (e) {
    if (e.code != 'invalid_sound') {
      debugPrint('Prayer exact scheduling failed for $id: ${e.code}');
      rethrow;
    }

    details = _prayerNotificationDetails(
      playAdhan: playAdhan,
      adhanSound: adhanSound,
      allowCustomSound: false,
      channelVersion: channelVersion,
    );
    await _zonedScheduleWithFallback(
      notificationsPlugin: notificationsPlugin,
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      details: details,
    );
  }
}

Future<void> _zonedScheduleWithFallback({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required int id,
  required String title,
  required String body,
  required tz.TZDateTime scheduledDate,
  required NotificationDetails details,
}) async {
  try {
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  } on PlatformException catch (e) {
    debugPrint('Falling back to inexact alarm for notification $id: ${e.code}');
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
