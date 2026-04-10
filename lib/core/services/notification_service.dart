import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yusr_app/core/services/notification_service_constants.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/utils/hijri_utils.dart';
import 'package:yusr_app/features/prayer_times/data/models/prayer_time_model.dart';

import '../../features/reminders/data/models/reminder_model.dart';
import '../localization/app_localizations.dart';
import '../localization/app_translations.dart';

export 'notification_service_contract.dart';

part 'notification/notification_service_init.dart';
part 'notification/notification_service_reminders.dart';
part 'notification/notification_service_reminders_sync.dart';
part 'notification/notification_service_reminders_time.dart';
part 'notification/notification_service_prayer.dart';
part 'notification/notification_service_prayer_preview.dart';
part 'notification/notification_service_prayer_details.dart';
part 'notification/notification_service_persistent.dart';
part 'notification/notification_service_fasting.dart';
part 'notification/notification_service_fasting_time.dart';
part 'notification/notification_service_fasting_white_days.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const List<String> adhanSoundOptions = notificationAdhanSoundOptions;

  static Future<void> init() => _notificationInit(_notificationsPlugin);

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) => _scheduleDailyNotification(
    notificationsPlugin: _notificationsPlugin,
    id: id,
    title: title,
    body: body,
    time: time,
  );

  static Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int day,
    required TimeOfDay time,
  }) => _scheduleWeeklyNotification(
    notificationsPlugin: _notificationsPlugin,
    id: id,
    title: title,
    body: body,
    day: day,
    time: time,
  );

  static Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool playAdhan,
    required String adhanSound,
  }) => _schedulePrayerNotification(
    notificationsPlugin: _notificationsPlugin,
    channelVersion: notificationChannelVersion,
    id: id,
    title: title,
    body: body,
    time: time,
    playAdhan: playAdhan,
    adhanSound: adhanSound,
  );

  static Future<void> previewAdhanSound({
    required String adhanSound,
    required bool playAdhan,
  }) => _previewAdhanSound(
    notificationsPlugin: _notificationsPlugin,
    channelVersion: notificationChannelVersion,
    adhanSound: adhanSound,
    playAdhan: playAdhan,
  );

  static Future<void> showPersistentNotification(String title, String body) =>
      _showPersistentNotification(
        notificationsPlugin: _notificationsPlugin,
        title: title,
        body: body,
      );

  static Future<void> schedulePersistentNotificationUpdate({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) => _schedulePersistentNotificationUpdate(
    notificationsPlugin: _notificationsPlugin,
    details: _persistentNotificationDetails,
    id: id,
    title: title,
    body: body,
    time: time,
  );

  static Future<void> removePersistentNotification() =>
      _removePersistentNotification(_notificationsPlugin);

  static Future<void> cancelNotification(int id) =>
      _cancelNotification(_notificationsPlugin, id);

  static Future<void> syncFastingReminders({PrayerTimeModel? prayerTimes}) =>
      _syncFastingReminders(
        notificationsPlugin: _notificationsPlugin,
        prayerTimes: prayerTimes,
        fastingMondayId: notificationFastingMondayId,
        fastingThursdayId: notificationFastingThursdayId,
        whiteDaysIds: notificationWhiteDaysIds,
        cachedPrayerTimesKey: notificationCachedPrayerTimesKey,
      );

  static Future<void> syncReminders(List<ReminderModel> reminders) =>
      _syncReminders(
        notificationsPlugin: _notificationsPlugin,
        reminders: reminders,
      );
}
