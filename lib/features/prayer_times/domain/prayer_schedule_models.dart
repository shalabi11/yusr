import 'package:flutter/material.dart';

class PrayerSlot {
  final int id;
  final String key;
  final DateTime time;
  final IconData icon;

  const PrayerSlot({
    required this.id,
    required this.key,
    required this.time,
    required this.icon,
  });
}

class NextPrayerInfo {
  final PrayerSlot slot;
  final Duration remaining;

  const NextPrayerInfo({required this.slot, required this.remaining});
}
