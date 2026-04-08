import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/core/services/storage/storage_core_module.dart';
import 'package:yusr_app/core/services/storage/storage_fasting_module.dart';
import 'package:yusr_app/core/services/storage/storage_language_module.dart';
import 'package:yusr_app/core/services/storage/storage_location_module.dart';
import 'package:yusr_app/core/services/storage/storage_prayer_module.dart';
import 'package:yusr_app/core/services/storage/storage_quran_module.dart';
import 'package:yusr_app/core/services/storage/storage_ui_module.dart';

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
