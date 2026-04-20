import 'package:shared_preferences/shared_preferences.dart';

class StoragePrayerModule {
  StoragePrayerModule(this._prefs);

  final SharedPreferences _prefs;

  int get prayerOffset => _prefs.getInt('prayer_offset') ?? 0;

  Future<void> setPrayerOffset(int offset) async {
    await _prefs.setInt('prayer_offset', offset);
  }

  bool get playAdhan => _prefs.getBool('play_adhan') ?? true;

  Future<void> setPlayAdhan(bool play) async {
    await _prefs.setBool('play_adhan', play);
  }

  bool get stickyNotification => _prefs.getBool('sticky_notification') ?? false;

  Future<void> setStickyNotification(bool sticky) async {
    await _prefs.setBool('sticky_notification', sticky);
  }

  String get adhanSound => _prefs.getString('adhan_sound') ?? 'adhan';

  Future<void> setAdhanSound(String soundKey) async {
    await _prefs.setString('adhan_sound', soundKey);
  }

  bool get lastThirdNightReminderEnabled =>
      _prefs.getBool('last_third_night_reminder_enabled') ?? false;

  Future<void> setLastThirdNightReminderEnabled(bool enabled) async {
    await _prefs.setBool('last_third_night_reminder_enabled', enabled);
  }

  bool get sunnahPrayerRemindersEnabled =>
      _prefs.getBool('sunnah_prayer_reminders_enabled') ?? false;

  Future<void> setSunnahPrayerRemindersEnabled(bool enabled) async {
    await _prefs.setBool('sunnah_prayer_reminders_enabled', enabled);
  }
}
