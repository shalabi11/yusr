part of '../notification_service.dart';

TimeOfDay? _resolveIshaTime({
  required PrayerTimeModel? prayerTimes,
  required String cachedPrayerTimesKey,
}) {
  final source = prayerTimes ?? _cachedPrayerTimesModel(cachedPrayerTimesKey);
  if (source == null) return null;

  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(source.isha);
  if (match == null) return null;

  final hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

PrayerTimeModel? _cachedPrayerTimesModel(String cachedPrayerTimesKey) {
  final data = StorageService.getData(cachedPrayerTimesKey);
  if (data is! Map<String, dynamic>) return null;
  try {
    return PrayerTimeModel.fromJson(data);
  } catch (_) {
    return null;
  }
}
