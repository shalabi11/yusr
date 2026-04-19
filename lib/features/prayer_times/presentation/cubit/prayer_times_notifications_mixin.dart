part of 'prayer_times_cubit.dart';

mixin PrayerTimesNotificationsMixin on Cubit<PrayerTimesState> {
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

    _updateStickyNotification(times, locationName);
    await _notificationService.syncFastingReminders(prayerTimes: times);
    await _rescheduleStickyRefreshNotifications(times, locationName, now);
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
