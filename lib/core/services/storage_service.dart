import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Language Setup
  static String get language => _prefs.getString('language') ?? 'ar';
  static Future<void> setLanguage(String langCode) async {
    await _prefs.setString('language', langCode);
  }

  // Generic JSON Storage for Features (like Reminders)
  static Future<void> saveData(String key, dynamic value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  static dynamic getData(String key) {
    final String? data = _prefs.getString(key);
    if (data == null) return null;
    return jsonDecode(data);
  }

  // Prayer Notifications Settings
  static int get prayerOffset => _prefs.getInt('prayer_offset') ?? 0;
  static Future<void> setPrayerOffset(int offset) async {
    await _prefs.setInt('prayer_offset', offset);
  }

  static bool get playAdhan => _prefs.getBool('play_adhan') ?? true;
  static Future<void> setPlayAdhan(bool play) async {
    await _prefs.setBool('play_adhan', play);
  }

  static bool get stickyNotification =>
      _prefs.getBool('sticky_notification') ?? false;
  static Future<void> setStickyNotification(bool sticky) async {
    await _prefs.setBool('sticky_notification', sticky);
  }

  static String get adhanSound => _prefs.getString('adhan_sound') ?? 'adhan';
  static Future<void> setAdhanSound(String soundKey) async {
    await _prefs.setString('adhan_sound', soundKey);
  }

  static double? get manualLat => _prefs.getDouble('manual_lat');
  static double? get manualLng => _prefs.getDouble('manual_lng');
  static String? get manualCity => _prefs.getString('manual_city');

  static bool get hasManualLocation => manualLat != null && manualLng != null;

  static Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String city,
  }) async {
    await _prefs.setDouble('manual_lat', lat);
    await _prefs.setDouble('manual_lng', lng);
    await _prefs.setString('manual_city', city);
  }

  static Future<void> clearManualLocation() async {
    await _prefs.remove('manual_lat');
    await _prefs.remove('manual_lng');
    await _prefs.remove('manual_city');
  }

  static bool get quranReadAsText =>
      _prefs.getBool('quran_read_as_text') ?? false;
  static Future<void> setQuranReadAsText(bool readAsText) async {
    await _prefs.setBool('quran_read_as_text', readAsText);
  }

  static bool get remindersSwipeHintSeen =>
      _prefs.getBool('reminders_swipe_hint_seen') ?? false;
  static Future<void> setRemindersSwipeHintSeen(bool seen) async {
    await _prefs.setBool('reminders_swipe_hint_seen', seen);
  }

  static bool get introSeen => _prefs.getBool('intro_seen') ?? false;
  static Future<void> setIntroSeen(bool seen) async {
    await _prefs.setBool('intro_seen', seen);
  }

  static bool get fastingRemindersEnabled =>
      _prefs.getBool('fasting_reminders_enabled') ?? false;
  static Future<void> setFastingRemindersEnabled(bool enabled) async {
    await _prefs.setBool('fasting_reminders_enabled', enabled);
  }

  static bool get whiteDaysReminderEnabled =>
      _prefs.getBool('white_days_reminder_enabled') ?? false;
  static Future<void> setWhiteDaysReminderEnabled(bool enabled) async {
    await _prefs.setBool('white_days_reminder_enabled', enabled);
  }

  static bool get mondayThursdayReminderEnabled =>
      _prefs.getBool('monday_thursday_reminder_enabled') ?? false;
  static Future<void> setMondayThursdayReminderEnabled(bool enabled) async {
    await _prefs.setBool('monday_thursday_reminder_enabled', enabled);
  }

  static String? get lastWhiteDaysScheduleToken =>
      _prefs.getString('last_white_days_schedule_token');
  static Future<void> setLastWhiteDaysScheduleToken(String? token) async {
    if (token == null) {
      await _prefs.remove('last_white_days_schedule_token');
      return;
    }
    await _prefs.setString('last_white_days_schedule_token', token);
  }
}
