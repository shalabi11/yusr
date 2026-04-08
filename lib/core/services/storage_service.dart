import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/core/services/storage/storage_sevice_impl.dart';

class StorageService {
  static late IStorageService _instance;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageServiceImpl(prefs);
  }

  static void bind(IStorageService storageService) {
    _instance = storageService;
  }

  static IStorageService get instance => _instance;

  static String get language => _instance.language;
  static Future<void> setLanguage(String langCode) =>
      _instance.setLanguage(langCode);
  static Future<void> saveData(String key, dynamic value) =>
      _instance.saveData(key, value);
  static dynamic getData(String key) => _instance.getData(key);
  static int get prayerOffset => _instance.prayerOffset;
  static Future<void> setPrayerOffset(int offset) =>
      _instance.setPrayerOffset(offset);
  static bool get playAdhan => _instance.playAdhan;
  static Future<void> setPlayAdhan(bool play) => _instance.setPlayAdhan(play);
  static bool get stickyNotification => _instance.stickyNotification;
  static Future<void> setStickyNotification(bool sticky) =>
      _instance.setStickyNotification(sticky);
  static String get adhanSound => _instance.adhanSound;
  static Future<void> setAdhanSound(String soundKey) =>
      _instance.setAdhanSound(soundKey);
  static double? get manualLat => _instance.manualLat;
  static double? get manualLng => _instance.manualLng;
  static String? get manualCity => _instance.manualCity;
  static bool get hasManualLocation => _instance.hasManualLocation;
  static Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String city,
  }) => _instance.setManualLocation(lat: lat, lng: lng, city: city);
  static Future<void> clearManualLocation() => _instance.clearManualLocation();
  static bool get quranReadAsText => _instance.quranReadAsText;
  static Future<void> setQuranReadAsText(bool readAsText) =>
      _instance.setQuranReadAsText(readAsText);
  static bool get remindersSwipeHintSeen => _instance.remindersSwipeHintSeen;
  static Future<void> setRemindersSwipeHintSeen(bool seen) =>
      _instance.setRemindersSwipeHintSeen(seen);
  static bool get introSeen => _instance.introSeen;
  static Future<void> setIntroSeen(bool seen) => _instance.setIntroSeen(seen);
  static bool get fastingRemindersEnabled => _instance.fastingRemindersEnabled;
  static Future<void> setFastingRemindersEnabled(bool enabled) =>
      _instance.setFastingRemindersEnabled(enabled);
  static bool get whiteDaysReminderEnabled =>
      _instance.whiteDaysReminderEnabled;
  static Future<void> setWhiteDaysReminderEnabled(bool enabled) =>
      _instance.setWhiteDaysReminderEnabled(enabled);
  static bool get mondayThursdayReminderEnabled =>
      _instance.mondayThursdayReminderEnabled;
  static Future<void> setMondayThursdayReminderEnabled(bool enabled) =>
      _instance.setMondayThursdayReminderEnabled(enabled);
  static String? get lastWhiteDaysScheduleToken =>
      _instance.lastWhiteDaysScheduleToken;
  static Future<void> setLastWhiteDaysScheduleToken(String? token) =>
      _instance.setLastWhiteDaysScheduleToken(token);
}
