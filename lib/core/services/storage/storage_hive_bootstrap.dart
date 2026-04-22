import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/services/storage/models/prayer_times_cache_record.dart';
import 'package:yusr_app/core/services/storage/storage_hive_constants.dart';

final PrayerTimesCacheRecordAdapter _prayerTimesAdapter =
    PrayerTimesCacheRecordAdapter();

Future<void> initializeStorageHive(SharedPreferences prefs) async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(_prayerTimesAdapter.typeId)) {
    Hive.registerAdapter<PrayerTimesCacheRecord>(_prayerTimesAdapter);
  }

  final coreBox = await _openBox(storageCoreHiveBox);
  final prayerBox = await _openBox(storagePrayerHiveBox);
  await _migrateLegacyStorageIfNeeded(
    prefs: prefs,
    coreBox: coreBox,
    prayerBox: prayerBox,
  );
}

Future<Box<dynamic>> _openBox(String name) async {
  if (Hive.isBoxOpen(name)) {
    return Hive.box<dynamic>(name);
  }
  return Hive.openBox<dynamic>(name);
}

Future<void> _migrateLegacyStorageIfNeeded({
  required SharedPreferences prefs,
  required Box<dynamic> coreBox,
  required Box<dynamic> prayerBox,
}) async {
  if (prayerBox.get(storagePrayerMigrationFlagKey) == true) {
    return;
  }

  await _migrateCorePrayerData(prefs: prefs, coreBox: coreBox);
  await _migratePrayerSettings(prefs: prefs, prayerBox: prayerBox);

  await prayerBox.put(storagePrayerMigrationFlagKey, true);
}

Future<void> _migrateCorePrayerData({
  required SharedPreferences prefs,
  required Box<dynamic> coreBox,
}) async {
  final rawPrayerTimes = _decodeLegacyJsonString(
    prefs.getString(cachedPrayerTimesKey),
  );
  final prayerRecord = PrayerTimesCacheRecord.fromDynamic(rawPrayerTimes);
  if (prayerRecord != null) {
    await coreBox.put(cachedPrayerTimesKey, prayerRecord);
  }

  final rawLocationName = _decodeLegacyJsonString(
    prefs.getString(cachedLocationNameKey),
  );
  if (rawLocationName is String) {
    await coreBox.put(cachedLocationNameKey, rawLocationName);
  }

  final rawManualEnabled = _decodeLegacyJsonString(
    prefs.getString(manualLocationEnabledKey),
  );
  if (rawManualEnabled is bool) {
    await coreBox.put(manualLocationEnabledKey, rawManualEnabled);
  }

  final rawLastFetchAt = _decodeLegacyJsonString(
    prefs.getString(prayerTimesLastRemoteFetchAtKey),
  );
  if (rawLastFetchAt is int) {
    await coreBox.put(prayerTimesLastRemoteFetchAtKey, rawLastFetchAt);
  } else if (rawLastFetchAt is String) {
    final parsed = int.tryParse(rawLastFetchAt);
    if (parsed != null) {
      await coreBox.put(prayerTimesLastRemoteFetchAtKey, parsed);
    }
  }
}

Future<void> _migratePrayerSettings({
  required SharedPreferences prefs,
  required Box<dynamic> prayerBox,
}) async {
  if (prefs.containsKey(prayerOffsetKey)) {
    await prayerBox.put(prayerOffsetKey, prefs.getInt(prayerOffsetKey) ?? 0);
  }
  if (prefs.containsKey(playAdhanKey)) {
    await prayerBox.put(playAdhanKey, prefs.getBool(playAdhanKey) ?? true);
  }
  if (prefs.containsKey(stickyNotificationKey)) {
    await prayerBox.put(
      stickyNotificationKey,
      prefs.getBool(stickyNotificationKey) ?? false,
    );
  }
  if (prefs.containsKey(adhanSoundKey)) {
    await prayerBox.put(
      adhanSoundKey,
      prefs.getString(adhanSoundKey) ?? 'adhan',
    );
  }
  if (prefs.containsKey(lastThirdNightReminderEnabledKey)) {
    await prayerBox.put(
      lastThirdNightReminderEnabledKey,
      prefs.getBool(lastThirdNightReminderEnabledKey) ?? false,
    );
  }
  if (prefs.containsKey(sunnahPrayerRemindersEnabledKey)) {
    await prayerBox.put(
      sunnahPrayerRemindersEnabledKey,
      prefs.getBool(sunnahPrayerRemindersEnabledKey) ?? false,
    );
  }
}

dynamic _decodeLegacyJsonString(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }

  try {
    return jsonDecode(raw);
  } catch (_) {
    return null;
  }
}
