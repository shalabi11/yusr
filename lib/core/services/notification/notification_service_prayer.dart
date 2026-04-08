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

Future<void> _previewAdhanSound({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required String channelVersion,
  required String adhanSound,
  required bool playAdhan,
}) async {
  try {
    await notificationsPlugin.show(
      id: 9090,
      title: 'معاينة صوت الأذان',
      body: playAdhan ? 'هذا هو الصوت المحدد حاليًا' : 'صوت الأذان معطل',
      notificationDetails: _previewNotificationDetails(
        playAdhan: playAdhan,
        adhanSound: adhanSound,
        allowCustomSound: true,
        channelVersion: channelVersion,
      ),
    );
  } on PlatformException catch (e) {
    if (e.code != 'invalid_sound') rethrow;
    await notificationsPlugin.show(
      id: 9090,
      title: 'معاينة صوت الأذان',
      body: 'الصوت المحدد غير مضاف بعد، تم تشغيل الصوت الافتراضي',
      notificationDetails: _previewNotificationDetails(
        playAdhan: playAdhan,
        adhanSound: adhanSound,
        allowCustomSound: false,
        channelVersion: channelVersion,
      ),
    );
  }
}

NotificationDetails _prayerNotificationDetails({
  required bool playAdhan,
  required String adhanSound,
  required bool allowCustomSound,
  required String channelVersion,
}) {
  final safeSound = adhanSound.toLowerCase().replaceAll('-', '_');
  final channelId = playAdhan
      ? (allowCustomSound
            ? 'prayer_adhan_channel_${safeSound}_$channelVersion'
            : 'prayer_adhan_channel_default_$channelVersion')
      : 'prayer_normal_channel_$channelVersion';

  return NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      playAdhan ? 'Prayer Adhan' : 'Prayer Notifications',
      channelDescription: 'Channel for prayer notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: playAdhan && allowCustomSound
          ? RawResourceAndroidNotificationSound(adhanSound)
          : null,
    ),
    iOS: DarwinNotificationDetails(
      presentSound: true,
      sound: playAdhan && allowCustomSound ? '$adhanSound.wav' : null,
    ),
  );
}

NotificationDetails _previewNotificationDetails({
  required bool playAdhan,
  required String adhanSound,
  required bool allowCustomSound,
  required String channelVersion,
}) {
  final safeSound = adhanSound.toLowerCase().replaceAll('-', '_');
  final previewChannelId = allowCustomSound
      ? 'prayer_preview_channel_${safeSound}_$channelVersion'
      : 'prayer_preview_channel_default_$channelVersion';

  return NotificationDetails(
    android: AndroidNotificationDetails(
      previewChannelId,
      'Prayer Preview',
      channelDescription: 'Preview selected adhan sound',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: playAdhan && allowCustomSound
          ? RawResourceAndroidNotificationSound(adhanSound)
          : null,
    ),
    iOS: DarwinNotificationDetails(
      presentSound: true,
      sound: playAdhan && allowCustomSound ? '$adhanSound.wav' : null,
    ),
  );
}
