import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/services/storage/models/prayer_times_cache_record.dart';
import 'package:yusr_app/core/services/storage/storage_hive_constants.dart';

class StorageCoreModule {
  StorageCoreModule(this._prefs);

  final SharedPreferences _prefs;

  static const Set<String> _hiveBackedCoreKeys = <String>{
    cachedPrayerTimesKey,
    cachedLocationNameKey,
    manualLocationEnabledKey,
    prayerTimesLastRemoteFetchAtKey,
  };

  Box<dynamic>? get _coreBox {
    if (!Hive.isBoxOpen(storageCoreHiveBox)) {
      return null;
    }
    return Hive.box<dynamic>(storageCoreHiveBox);
  }

  Future<void> saveData(String key, dynamic value) async {
    if (_hiveBackedCoreKeys.contains(key)) {
      final box = _coreBox;
      if (box != null) {
        if (key == cachedPrayerTimesKey) {
          final record = PrayerTimesCacheRecord.fromDynamic(value);
          if (record != null) {
            await box.put(key, record);
            return;
          }
        }
        await box.put(key, value);
        return;
      }
    }

    await _prefs.setString(key, jsonEncode(value));
  }

  dynamic getData(String key) {
    if (_hiveBackedCoreKeys.contains(key)) {
      final box = _coreBox;
      if (box != null && box.containsKey(key)) {
        final value = box.get(key);
        if (key == cachedPrayerTimesKey) {
          final record = PrayerTimesCacheRecord.fromDynamic(value);
          if (record != null) {
            return record.toMap();
          }
        }
        return value;
      }
    }

    final String? data = _prefs.getString(key);
    if (data == null) return null;
    final legacy = jsonDecode(data);
    if (key == cachedPrayerTimesKey) {
      final record = PrayerTimesCacheRecord.fromDynamic(legacy);
      if (record != null) {
        _coreBox?.put(key, record);
        return record.toMap();
      }
    }
    if (_hiveBackedCoreKeys.contains(key)) {
      _coreBox?.put(key, legacy);
    }
    return legacy;
  }
}
