import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/services/storage/storage_hive_constants.dart';

class StoragePrayerModule {
  StoragePrayerModule(this._prefs);

  final SharedPreferences _prefs;

  Box<dynamic>? get _prayerBox {
    if (!Hive.isBoxOpen(storagePrayerHiveBox)) {
      return null;
    }
    return Hive.box<dynamic>(storagePrayerHiveBox);
  }

  int get prayerOffset {
    final value = _prayerBox?.get(prayerOffsetKey);
    if (value is int) {
      return value;
    }
    return _prefs.getInt(prayerOffsetKey) ?? 0;
  }

  Future<void> setPrayerOffset(int offset) async {
    final box = _prayerBox;
    if (box != null) {
      await box.put(prayerOffsetKey, offset);
      return;
    }
    await _prefs.setInt(prayerOffsetKey, offset);
  }

  bool get playAdhan {
    final value = _prayerBox?.get(playAdhanKey);
    if (value is bool) {
      return value;
    }
    return _prefs.getBool(playAdhanKey) ?? true;
  }

  Future<void> setPlayAdhan(bool play) async {
    final box = _prayerBox;
    if (box != null) {
      await box.put(playAdhanKey, play);
      return;
    }
    await _prefs.setBool(playAdhanKey, play);
  }

  bool get stickyNotification {
    final value = _prayerBox?.get(stickyNotificationKey);
    if (value is bool) {
      return value;
    }
    return _prefs.getBool(stickyNotificationKey) ?? false;
  }

  Future<void> setStickyNotification(bool sticky) async {
    final box = _prayerBox;
    if (box != null) {
      await box.put(stickyNotificationKey, sticky);
      return;
    }
    await _prefs.setBool(stickyNotificationKey, sticky);
  }

  String get adhanSound {
    final value = _prayerBox?.get(adhanSoundKey);
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return _prefs.getString(adhanSoundKey) ?? 'adhan';
  }

  Future<void> setAdhanSound(String soundKey) async {
    final box = _prayerBox;
    if (box != null) {
      await box.put(adhanSoundKey, soundKey);
      return;
    }
    await _prefs.setString(adhanSoundKey, soundKey);
  }

  bool get lastThirdNightReminderEnabled =>
      (_prayerBox?.get(lastThirdNightReminderEnabledKey) as bool?) ??
      _prefs.getBool(lastThirdNightReminderEnabledKey) ??
      false;

  Future<void> setLastThirdNightReminderEnabled(bool enabled) async {
    final box = _prayerBox;
    if (box != null) {
      await box.put(lastThirdNightReminderEnabledKey, enabled);
      return;
    }
    await _prefs.setBool(lastThirdNightReminderEnabledKey, enabled);
  }

  bool get sunnahPrayerRemindersEnabled =>
      (_prayerBox?.get(sunnahPrayerRemindersEnabledKey) as bool?) ??
      _prefs.getBool(sunnahPrayerRemindersEnabledKey) ??
      false;

  Future<void> setSunnahPrayerRemindersEnabled(bool enabled) async {
    final box = _prayerBox;
    if (box != null) {
      await box.put(sunnahPrayerRemindersEnabledKey, enabled);
      return;
    }
    await _prefs.setBool(sunnahPrayerRemindersEnabledKey, enabled);
  }
}
