part of 'prayer_times_cubit.dart';

mixin PrayerTimesNotificationsMixin on Cubit<PrayerTimesState> {
  static const int _lastThirdNightAlertId = 1601;
  static const int _duhaAlertId = 1602;
  static const int _witrAlertId = 1603;

  IStorageService get _storageService;
  INotificationService get _notificationService;

  Future<void> syncPrayerNotificationsInternal(
    PrayerTimeModel times,
    String locationName,
  ) async {
    final offset = _storageService.prayerOffset;
    final playAdhan = _storageService.playAdhan;
    final adhanSound = _storageService.adhanSound;
    final now = DateTime.now();

    final prayers = PrayerScheduleHelper.prayerSlots(times, now);
    for (final slot in prayers) {
      final name = slot.key.tr;
      final scheduledTime = PrayerScheduleHelper.notificationTimeForPrayer(
        prayerTime: slot.time,
        offsetMinutes: offset,
        now: now,
      );

      final body = offset > 0
          ? 'باقي $offset دقائق على أذان $name'
          : 'حان الآن موعد أذان $name';

      await _notificationService.cancelNotification(slot.id);
      await _notificationService.schedulePrayerNotification(
        id: slot.id,
        title: 'الصلاة القادمة',
        body: body,
        time: scheduledTime,
        playAdhan: playAdhan,
        adhanSound: adhanSound,
      );
    }

    await _syncAdvancedPrayerAlerts(
      times: times,
      now: now,
      adhanSound: adhanSound,
    );

    _updateStickyNotification(times, locationName);
    await _notificationService.syncFastingReminders(prayerTimes: times);
    await _rescheduleStickyRefreshNotifications(times, locationName, now);
  }

  Future<void> _syncAdvancedPrayerAlerts({
    required PrayerTimeModel times,
    required DateTime now,
    required String adhanSound,
  }) async {
    await _notificationService.cancelNotification(_lastThirdNightAlertId);
    await _notificationService.cancelNotification(_duhaAlertId);
    await _notificationService.cancelNotification(_witrAlertId);

    if (_storageService.lastThirdNightReminderEnabled) {
      final isha = PrayerScheduleHelper.parseApiTime(times.isha, now);
      var nextFajr = PrayerScheduleHelper.parseApiTime(times.fajr, now);
      if (!nextFajr.isAfter(isha)) {
        nextFajr = nextFajr.add(const Duration(days: 1));
      }

      final nightDuration = nextFajr.difference(isha);
      final lastThirdStart = isha.add(
        Duration(seconds: ((nightDuration.inSeconds * 2) / 3).round()),
      );
      final trigger = lastThirdStart.isAfter(now)
          ? lastThirdStart
          : lastThirdStart.add(const Duration(days: 1));

      await _notificationService.schedulePrayerNotification(
        id: _lastThirdNightAlertId,
        title: 'تنبيه قيام الليل',
        body: 'بدأ الثلث الأخير من الليل. هذا وقت مبارك للقيام والدعاء.',
        time: trigger,
        playAdhan: false,
        adhanSound: adhanSound,
      );
    }

    if (_storageService.sunnahPrayerRemindersEnabled) {
      final sunrise = PrayerScheduleHelper.parseApiTime(times.sunrise, now);
      final duhaBase = sunrise.add(const Duration(minutes: 30));
      final duhaTrigger = duhaBase.isAfter(now)
          ? duhaBase
          : duhaBase.add(const Duration(days: 1));

      final isha = PrayerScheduleHelper.parseApiTime(times.isha, now);
      final witrBase = isha.add(const Duration(minutes: 90));
      final witrTrigger = witrBase.isAfter(now)
          ? witrBase
          : witrBase.add(const Duration(days: 1));

      await _notificationService.schedulePrayerNotification(
        id: _duhaAlertId,
        title: 'تنبيه صلاة الضحى',
        body: 'تذكير بصلاة الضحى لمن أراد الزيادة من النوافل.',
        time: duhaTrigger,
        playAdhan: false,
        adhanSound: adhanSound,
      );

      await _notificationService.schedulePrayerNotification(
        id: _witrAlertId,
        title: 'تنبيه صلاة الوتر',
        body: 'لا تنسَ الوتر قبل النوم.',
        time: witrTrigger,
        playAdhan: false,
        adhanSound: adhanSound,
      );
    }
  }

  Future<void> _rescheduleStickyRefreshNotifications(
    PrayerTimeModel times,
    String locationName,
    DateTime now,
  ) async {
    for (final id in PrayerTimesCubit._stickyRefreshIds) {
      await _notificationService.cancelNotification(id);
    }

    if (!_storageService.stickyNotification) {
      return;
    }

    final slots = PrayerScheduleHelper.prayerSlots(times, now);
    for (
      var i = 0;
      i < slots.length && i < PrayerTimesCubit._stickyRefreshIds.length;
      i++
    ) {
      final trigger = slots[i].time;
      final nextInfo = PrayerScheduleHelper.computeNextPrayer(
        times,
        reference: trigger.add(const Duration(seconds: 1)),
      );
      final timeStr = DateFormat('hh:mm a').format(nextInfo.slot.time);

      await _notificationService.schedulePersistentNotificationUpdate(
        id: PrayerTimesCubit._stickyRefreshIds[i],
        title: 'الصلاة القادمة: ${nextInfo.slot.key.tr} ($locationName)',
        body: 'الوقت: $timeStr',
        time: trigger,
      );
    }
  }

  void _updateStickyNotification(PrayerTimeModel times, String locationName) {
    if (!_storageService.stickyNotification) {
      _notificationService.removePersistentNotification();
      return;
    }

    final next = PrayerScheduleHelper.computeNextPrayer(times);
    final timeStr = DateFormat('hh:mm a').format(next.slot.time);
    final remaining = PrayerScheduleHelper.formatHoursMinutes(next.remaining);

    _notificationService.showPersistentNotification(
      'الصلاة القادمة: ${next.slot.key.tr} ($locationName)',
      'الوقت: $timeStr | المتبقي: $remaining',
    );
  }
}
