import 'package:shared_preferences/shared_preferences.dart';

class StorageFastingModule {
  StorageFastingModule(this._prefs);

  final SharedPreferences _prefs;

  bool get fastingRemindersEnabled =>
      _prefs.getBool('fasting_reminders_enabled') ?? false;

  Future<void> setFastingRemindersEnabled(bool enabled) async {
    await _prefs.setBool('fasting_reminders_enabled', enabled);
  }

  bool get whiteDaysReminderEnabled =>
      _prefs.getBool('white_days_reminder_enabled') ?? false;

  Future<void> setWhiteDaysReminderEnabled(bool enabled) async {
    await _prefs.setBool('white_days_reminder_enabled', enabled);
  }

  bool get mondayThursdayReminderEnabled =>
      _prefs.getBool('monday_thursday_reminder_enabled') ?? false;

  Future<void> setMondayThursdayReminderEnabled(bool enabled) async {
    await _prefs.setBool('monday_thursday_reminder_enabled', enabled);
  }

  String? get lastWhiteDaysScheduleToken =>
      _prefs.getString('last_white_days_schedule_token');

  Future<void> setLastWhiteDaysScheduleToken(String? token) async {
    if (token == null) {
      await _prefs.remove('last_white_days_schedule_token');
      return;
    }
    await _prefs.setString('last_white_days_schedule_token', token);
  }
}
