part of '../notification_service.dart';

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
