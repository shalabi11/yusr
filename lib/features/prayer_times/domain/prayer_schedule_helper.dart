import 'package:flutter/material.dart';
import '../data/models/prayer_time_model.dart';
import 'prayer_schedule_format.dart';
import 'prayer_schedule_models.dart';

class PrayerScheduleHelper {
  static final RegExp _timePattern = RegExp(r'(\d{1,2}):(\d{2})');

  static DateTime parseApiTime(String timeStr, DateTime now) {
    final match = _timePattern.firstMatch(timeStr);
    if (match == null) return now;

    final hour = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static List<PrayerSlot> prayerSlots(PrayerTimeModel times, DateTime now) {
    return <PrayerSlot>[
      PrayerSlot(
        id: 101,
        key: 'fajr',
        time: parseApiTime(times.fajr, now),
        icon: Icons.nightlight_round,
      ),
      PrayerSlot(
        id: 102,
        key: 'dhuhr',
        time: parseApiTime(times.dhuhr, now),
        icon: Icons.wb_sunny,
      ),
      PrayerSlot(
        id: 103,
        key: 'asr',
        time: parseApiTime(times.asr, now),
        icon: Icons.brightness_high,
      ),
      PrayerSlot(
        id: 104,
        key: 'maghrib',
        time: parseApiTime(times.maghrib, now),
        icon: Icons.brightness_6,
      ),
      PrayerSlot(
        id: 105,
        key: 'isha',
        time: parseApiTime(times.isha, now),
        icon: Icons.brightness_4,
      ),
    ];
  }

  static NextPrayerInfo computeNextPrayer(
    PrayerTimeModel times, {
    DateTime? reference,
  }) {
    final now = reference ?? DateTime.now();
    final slots = prayerSlots(times, now);
    PrayerSlot? nextSlot;
    DateTime? nextTime;

    for (final slot in slots) {
      if (slot.time.isAfter(now)) {
        nextSlot = slot;
        nextTime = slot.time;
        break;
      }
    }

    if (nextSlot == null || nextTime == null) {
      final fajr = slots.first;
      nextSlot = PrayerSlot(
        id: fajr.id,
        key: fajr.key,
        time: fajr.time.add(const Duration(days: 1)),
        icon: fajr.icon,
      );
      nextTime = nextSlot.time;
    }

    return NextPrayerInfo(slot: nextSlot, remaining: nextTime.difference(now));
  }

  static DateTime notificationTimeForPrayer({
    required DateTime prayerTime,
    required int offsetMinutes,
    required DateTime now,
  }) {
    DateTime candidate = prayerTime.subtract(Duration(minutes: offsetMinutes));
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  static String formatCountdown(Duration remaining) =>
      formatPrayerCountdown(remaining);
  static String formatHoursMinutes(Duration remaining) =>
      formatPrayerHoursMinutes(remaining);
}
