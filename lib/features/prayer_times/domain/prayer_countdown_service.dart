import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yusr_app/features/prayer_times/data/models/prayer_time_model.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_schedule_helper.dart';

class PrayerCountdownTick {
  const PrayerCountdownTick({
    required this.nextPrayerKey,
    required this.nextPrayerIcon,
    required this.countdownText,
  });

  final String nextPrayerKey;
  final IconData nextPrayerIcon;
  final String countdownText;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PrayerCountdownTick &&
        other.nextPrayerKey == nextPrayerKey &&
        other.nextPrayerIcon == nextPrayerIcon &&
        other.countdownText == countdownText;
  }

  @override
  int get hashCode => Object.hash(nextPrayerKey, nextPrayerIcon, countdownText);
}

class PrayerCountdownService {
  final StreamController<PrayerCountdownTick> _controller =
      StreamController<PrayerCountdownTick>.broadcast();

  Timer? _ticker;
  Timer? _alignToMinuteTimer;
  PrayerTimeModel? _prayerTimes;
  PrayerCountdownTick? _current;

  Stream<PrayerCountdownTick> get stream => _controller.stream;
  PrayerCountdownTick? get current => _current;

  void bindPrayerTimes(PrayerTimeModel prayerTimes) {
    _prayerTimes = prayerTimes;
    _scheduleTicker();
  }

  void clear() {
    _alignToMinuteTimer?.cancel();
    _alignToMinuteTimer = null;
    _ticker?.cancel();
    _ticker = null;
    _prayerTimes = null;
    _current = null;
  }

  void dispose() {
    clear();
    _controller.close();
  }

  void _emitTick() {
    final prayerTimes = _prayerTimes;
    if (prayerTimes == null) {
      return;
    }

    final nextInfo = PrayerScheduleHelper.computeNextPrayer(prayerTimes);
    final tick = PrayerCountdownTick(
      nextPrayerKey: nextInfo.slot.key,
      nextPrayerIcon: nextInfo.slot.icon,
      countdownText: PrayerScheduleHelper.formatCountdown(nextInfo.remaining),
    );

    if (tick == _current) {
      return;
    }
    _current = tick;
    _controller.add(tick);
  }

  void _scheduleTicker() {
    _alignToMinuteTimer?.cancel();
    _alignToMinuteTimer = null;
    _ticker?.cancel();
    _ticker = null;

    _emitTick();

    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    final delay = nextMinute.difference(now);

    _alignToMinuteTimer = Timer(delay, () {
      _emitTick();
      _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
        _emitTick();
      });
    });
  }
}
