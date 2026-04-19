part of '../notification_service.dart';

Future<void> _notificationInit(
  FlutterLocalNotificationsPlugin notificationsPlugin,
) async {
  tz.initializeTimeZones();
  try {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
  const InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await notificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {},
  );

  final androidPlugin = notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  bool? notificationsGranted;
  bool? exactAlarmsGranted;

  try {
    notificationsGranted = await androidPlugin
        ?.requestNotificationsPermission();
  } catch (e) {
    debugPrint('Failed to request notification permission: $e');
  }

  try {
    exactAlarmsGranted = await androidPlugin?.requestExactAlarmsPermission();
  } catch (e) {
    debugPrint('Failed to request exact alarm permission: $e');
  }

  if (notificationsGranted == false) {
    debugPrint('Notification permission denied by user.');
  }
  if (exactAlarmsGranted == false) {
    debugPrint('Exact alarm permission denied; falling back when needed.');
  }
}
