part of '../notification_service.dart';

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
