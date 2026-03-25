import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/reminders/data/models/reminder_model.dart';
import '../localization/app_localizations.dart';
import '../localization/app_translations.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const List<String> adhanSoundOptions = [
    'adhan',
    'adhan_makkah',
    'adhan_madina',
  ];

  static Future<void> init() async {
    // 1. Initialize Timezones
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      // Fallback to UTC to avoid wrong local offsets when timezone lookup fails.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Init settings for Android and iOS
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

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Here we can navigate if user clicks the notification
      },
    );

    // Request permissions for Android 13+
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final notificationsGranted = await androidPlugin
        ?.requestNotificationsPermission();
    final exactAlarmsGranted = await androidPlugin
        ?.requestExactAlarmsPermission();

    if (notificationsGranted == false) {
      debugPrint('Notification permission denied by user.');
    }
    if (exactAlarmsGranted == false) {
      debugPrint('Exact alarm permission denied; falling back when needed.');
    }
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await _scheduleReminderNotification(
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

  static Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int day,
    required TimeOfDay time,
  }) async {
    await _scheduleReminderNotification(
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

  static Future<void> _scheduleReminderNotification({
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
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: nextSchedule,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } on PlatformException {
      await _notificationsPlugin.zonedSchedule(
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

  static Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool playAdhan,
    required String adhanSound,
  }) async {
    final scheduledDate = tz.TZDateTime.from(time, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _prayerNotificationDetails(
          playAdhan: playAdhan,
          adhanSound: adhanSound,
          allowCustomSound: true,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (e) {
      if (e.code != 'invalid_sound') rethrow;
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _prayerNotificationDetails(
          playAdhan: playAdhan,
          adhanSound: adhanSound,
          allowCustomSound: false,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> previewAdhanSound({
    required String adhanSound,
    required bool playAdhan,
  }) async {
    try {
      await _notificationsPlugin.show(
        id: 9090,
        title: 'معاينة صوت الأذان',
        body: playAdhan ? 'هذا هو الصوت المحدد حاليًا' : 'صوت الأذان معطل',
        notificationDetails: _previewNotificationDetails(
          playAdhan: playAdhan,
          adhanSound: adhanSound,
          allowCustomSound: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code != 'invalid_sound') rethrow;
      await _notificationsPlugin.show(
        id: 9090,
        title: 'معاينة صوت الأذان',
        body: 'الصوت المحدد غير مضاف بعد، تم تشغيل الصوت الافتراضي',
        notificationDetails: _previewNotificationDetails(
          playAdhan: playAdhan,
          adhanSound: adhanSound,
          allowCustomSound: false,
        ),
      );
    }
  }

  static NotificationDetails _prayerNotificationDetails({
    required bool playAdhan,
    required String adhanSound,
    required bool allowCustomSound,
  }) {
    final safeSound = adhanSound.toLowerCase().replaceAll('-', '_');
    final channelId = playAdhan
        ? (allowCustomSound
              ? 'prayer_adhan_channel_$safeSound'
              : 'prayer_adhan_channel_default')
        : 'prayer_normal_channel';

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

  static NotificationDetails _previewNotificationDetails({
    required bool playAdhan,
    required String adhanSound,
    required bool allowCustomSound,
  }) {
    final safeSound = adhanSound.toLowerCase().replaceAll('-', '_');
    final previewChannelId = allowCustomSound
        ? 'prayer_preview_channel_$safeSound'
        : 'prayer_preview_channel_default';

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

  static Future<void> showPersistentNotification(
    String title,
    String body,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_sticky_channel',
      'Prayer Sticky Notification',
      channelDescription: 'Ongoing notification for next prayer',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
    );

    const iosDetails = DarwinNotificationDetails(presentSound: false);

    await _notificationsPlugin.show(
      id: 0, // Sticky ID is always 0
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  static Future<void> removePersistentNotification() async {
    await _notificationsPlugin.cancel(id: 0);
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  static Future<void> syncReminders(List<ReminderModel> reminders) async {
    for (var r in reminders) {
      try {
        final int? id = int.tryParse(r.id);
        if (id == null) {
          debugPrint('Skipping reminder with invalid id: ${r.id}');
          continue;
        }
        await cancelNotification(id); // Clear existing

        if (r.enabled) {
          // Prepare localized messages!
          String localizedTitle = r.titleKey.tr;
          String localizedBody = (r.subtitleKey == AppStrings.weeklyFriday)
              ? 'لا تنسَ قراءة سورة الكهف'
              : 'حان وقت $localizedTitle';

          if (r.subtitleKey == AppStrings.weeklyFriday) {
            await scheduleWeeklyNotification(
              id: id,
              title: localizedTitle,
              body: localizedBody,
              day: DateTime.friday,
              time: r.timeOfDay,
            );
          } else {
            await scheduleDailyNotification(
              id: id,
              title: localizedTitle,
              body: localizedBody,
              time: r.timeOfDay,
            );
          }
        }
      } catch (e) {
        // Keep scheduling remaining reminders even if one fails.
        debugPrint('Failed to sync reminder ${r.id}: $e');
      }
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
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

  static tz.TZDateTime _nextInstanceOfDayAndTime(int day, TimeOfDay time) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
