import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/utils/hijri_utils.dart';
import 'package:yusr_app/features/prayer_times/data/models/prayer_time_model.dart';

import '../../features/reminders/data/models/reminder_model.dart';
import '../localization/app_localizations.dart';
import '../localization/app_translations.dart';

part 'notification/notification_service_init.dart';
part 'notification/notification_service_reminders.dart';
part 'notification/notification_service_prayer.dart';
part 'notification/notification_service_persistent.dart';
part 'notification/notification_service_fasting.dart';

abstract class INotificationService {
  Future<void> cancelNotification(int id);

  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool playAdhan,
    required String adhanSound,
  });

  Future<void> syncFastingReminders({PrayerTimeModel? prayerTimes});

  Future<void> schedulePersistentNotificationUpdate({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  });

  Future<void> removePersistentNotification();
  Future<void> showPersistentNotification(String title, String body);
}

class NotificationServiceAdapter implements INotificationService {
  @override
  Future<void> cancelNotification(int id) {
    return NotificationService.cancelNotification(id);
  }

  @override
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool playAdhan,
    required String adhanSound,
  }) {
    return NotificationService.schedulePrayerNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      playAdhan: playAdhan,
      adhanSound: adhanSound,
    );
  }

  @override
  Future<void> syncFastingReminders({PrayerTimeModel? prayerTimes}) {
    return NotificationService.syncFastingReminders(prayerTimes: prayerTimes);
  }

  @override
  Future<void> schedulePersistentNotificationUpdate({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) {
    return NotificationService.schedulePersistentNotificationUpdate(
      id: id,
      title: title,
      body: body,
      time: time,
    );
  }

  @override
  Future<void> removePersistentNotification() {
    return NotificationService.removePersistentNotification();
  }

  @override
  Future<void> showPersistentNotification(String title, String body) {
    return NotificationService.showPersistentNotification(title, body);
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelVersion = 'v2';
  static const int _fastingMondayId = 8101;
  static const int _fastingThursdayId = 8102;
  static const List<int> _whiteDaysIds = [8113, 8114, 8115];
  static const String _cachedPrayerTimesKey = 'cached_prayer_times';

  static const List<String> adhanSoundOptions = [
    'adhan',
    'adhan_makkah',
    'adhan_madina',
  ];

  static Future<void> init() {
    return _notificationInit(_notificationsPlugin);
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) {
    return _scheduleDailyNotification(
      notificationsPlugin: _notificationsPlugin,
      id: id,
      title: title,
      body: body,
      time: time,
    );
  }

  static Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int day,
    required TimeOfDay time,
  }) {
    return _scheduleWeeklyNotification(
      notificationsPlugin: _notificationsPlugin,
      id: id,
      title: title,
      body: body,
      day: day,
      time: time,
    );
  }

  static Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool playAdhan,
    required String adhanSound,
  }) {
    return _schedulePrayerNotification(
      notificationsPlugin: _notificationsPlugin,
      channelVersion: _channelVersion,
      id: id,
      title: title,
      body: body,
      time: time,
      playAdhan: playAdhan,
      adhanSound: adhanSound,
    );
  }

  static Future<void> previewAdhanSound({
    required String adhanSound,
    required bool playAdhan,
  }) {
    return _previewAdhanSound(
      notificationsPlugin: _notificationsPlugin,
      channelVersion: _channelVersion,
      adhanSound: adhanSound,
      playAdhan: playAdhan,
    );
  }

  static Future<void> showPersistentNotification(String title, String body) {
    return _showPersistentNotification(
      notificationsPlugin: _notificationsPlugin,
      title: title,
      body: body,
    );
  }

  static Future<void> schedulePersistentNotificationUpdate({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) {
    return _schedulePersistentNotificationUpdate(
      notificationsPlugin: _notificationsPlugin,
      details: _persistentNotificationDetails,
      id: id,
      title: title,
      body: body,
      time: time,
    );
  }

  static Future<void> removePersistentNotification() {
    return _removePersistentNotification(_notificationsPlugin);
  }

  static Future<void> cancelNotification(int id) {
    return _cancelNotification(_notificationsPlugin, id);
  }

  static Future<void> syncFastingReminders({PrayerTimeModel? prayerTimes}) {
    return _syncFastingReminders(
      notificationsPlugin: _notificationsPlugin,
      prayerTimes: prayerTimes,
      fastingMondayId: _fastingMondayId,
      fastingThursdayId: _fastingThursdayId,
      whiteDaysIds: _whiteDaysIds,
      cachedPrayerTimesKey: _cachedPrayerTimesKey,
    );
  }

  static Future<void> syncReminders(List<ReminderModel> reminders) {
    return _syncReminders(
      notificationsPlugin: _notificationsPlugin,
      reminders: reminders,
    );
  }
}
