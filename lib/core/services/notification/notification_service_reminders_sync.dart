part of '../notification_service.dart';

Future<void> _syncReminders({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required List<ReminderModel> reminders,
}) async {
  for (final r in reminders) {
    try {
      final id = int.tryParse(r.id);
      if (id == null) {
        debugPrint('Skipping reminder with invalid id: ${r.id}');
        continue;
      }

      await _cancelNotification(notificationsPlugin, id);
      if (!r.enabled) continue;

      final localizedTitle = r.titleKey.tr;
      final isWeeklyFriday = r.subtitleKey == AppStrings.weeklyFriday;
      final localizedBody = isWeeklyFriday
          ? 'لا تنسَ قراءة سورة الكهف'
          : 'حان وقت $localizedTitle';

      if (isWeeklyFriday) {
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
    } catch (e) {
      debugPrint('Failed to sync reminder ${r.id}: $e');
    }
  }
}
