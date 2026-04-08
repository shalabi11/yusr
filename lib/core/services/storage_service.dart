import 'package:shared_preferences/shared_preferences.dart';

import 'storage/storage_core_module.dart';
import 'storage/storage_fasting_module.dart';
import 'storage/storage_language_module.dart';
import 'storage/storage_location_module.dart';
import 'storage/storage_prayer_module.dart';
import 'storage/storage_quran_module.dart';
import 'storage/storage_ui_module.dart';

abstract class IStorageService {
  String get language;
  Future<void> setLanguage(String langCode);

  Future<void> saveData(String key, dynamic value);
  dynamic getData(String key);

  int get prayerOffset;
  Future<void> setPrayerOffset(int offset);

  bool get playAdhan;
  Future<void> setPlayAdhan(bool play);

  bool get stickyNotification;
  Future<void> setStickyNotification(bool sticky);

  String get adhanSound;
  Future<void> setAdhanSound(String soundKey);

  double? get manualLat;
  double? get manualLng;
  String? get manualCity;
  bool get hasManualLocation;

  Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String city,
  });
  Future<void> clearManualLocation();

  bool get quranReadAsText;
  Future<void> setQuranReadAsText(bool readAsText);

  bool get remindersSwipeHintSeen;
  Future<void> setRemindersSwipeHintSeen(bool seen);

  bool get introSeen;
  Future<void> setIntroSeen(bool seen);

  bool get fastingRemindersEnabled;
  Future<void> setFastingRemindersEnabled(bool enabled);

  bool get whiteDaysReminderEnabled;
  Future<void> setWhiteDaysReminderEnabled(bool enabled);

  bool get mondayThursdayReminderEnabled;
  Future<void> setMondayThursdayReminderEnabled(bool enabled);

  String? get lastWhiteDaysScheduleToken;
  Future<void> setLastWhiteDaysScheduleToken(String? token);
}

class StorageServiceImpl implements IStorageService {
  StorageServiceImpl(SharedPreferences prefs)
    : _core = StorageCoreModule(prefs),
      _language = StorageLanguageModule(prefs),
      _prayer = StoragePrayerModule(prefs),
      _location = StorageLocationModule(prefs),
      _quran = StorageQuranModule(prefs),
      _ui = StorageUiModule(prefs),
      _fasting = StorageFastingModule(prefs);

  final StorageCoreModule _core;
  final StorageLanguageModule _language;
  final StoragePrayerModule _prayer;
  final StorageLocationModule _location;
  final StorageQuranModule _quran;
  final StorageUiModule _ui;
  final StorageFastingModule _fasting;

  @override
  String get language => _language.language;

  @override
  Future<void> setLanguage(String langCode) => _language.setLanguage(langCode);

  @override
  Future<void> saveData(String key, dynamic value) =>
      _core.saveData(key, value);

  @override
  dynamic getData(String key) => _core.getData(key);

  @override
  int get prayerOffset => _prayer.prayerOffset;

  @override
  Future<void> setPrayerOffset(int offset) => _prayer.setPrayerOffset(offset);

  @override
  bool get playAdhan => _prayer.playAdhan;

  @override
  Future<void> setPlayAdhan(bool play) => _prayer.setPlayAdhan(play);

  @override
  bool get stickyNotification => _prayer.stickyNotification;

  @override
  Future<void> setStickyNotification(bool sticky) =>
      _prayer.setStickyNotification(sticky);

  @override
  String get adhanSound => _prayer.adhanSound;

  @override
  Future<void> setAdhanSound(String soundKey) =>
      _prayer.setAdhanSound(soundKey);

  @override
  double? get manualLat => _location.manualLat;

  @override
  double? get manualLng => _location.manualLng;

  @override
  String? get manualCity => _location.manualCity;

  @override
  bool get hasManualLocation => _location.hasManualLocation;

  @override
  Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String city,
  }) => _location.setManualLocation(lat: lat, lng: lng, city: city);

  @override
  Future<void> clearManualLocation() => _location.clearManualLocation();

  @override
  bool get quranReadAsText => _quran.quranReadAsText;

  @override
  Future<void> setQuranReadAsText(bool readAsText) =>
      _quran.setQuranReadAsText(readAsText);

  @override
  bool get remindersSwipeHintSeen => _ui.remindersSwipeHintSeen;

  @override
  Future<void> setRemindersSwipeHintSeen(bool seen) =>
      _ui.setRemindersSwipeHintSeen(seen);

  @override
  bool get introSeen => _ui.introSeen;

  @override
  Future<void> setIntroSeen(bool seen) => _ui.setIntroSeen(seen);

  @override
  bool get fastingRemindersEnabled => _fasting.fastingRemindersEnabled;

  @override
  Future<void> setFastingRemindersEnabled(bool enabled) =>
      _fasting.setFastingRemindersEnabled(enabled);

  @override
  bool get whiteDaysReminderEnabled => _fasting.whiteDaysReminderEnabled;

  @override
  Future<void> setWhiteDaysReminderEnabled(bool enabled) =>
      _fasting.setWhiteDaysReminderEnabled(enabled);

  @override
  bool get mondayThursdayReminderEnabled =>
      _fasting.mondayThursdayReminderEnabled;

  @override
  Future<void> setMondayThursdayReminderEnabled(bool enabled) =>
      _fasting.setMondayThursdayReminderEnabled(enabled);

  @override
  String? get lastWhiteDaysScheduleToken => _fasting.lastWhiteDaysScheduleToken;

  @override
  Future<void> setLastWhiteDaysScheduleToken(String? token) =>
      _fasting.setLastWhiteDaysScheduleToken(token);
}

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
