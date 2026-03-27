import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/prayer_times_repository.dart';
import '../../data/models/prayer_time_model.dart';
import '../../domain/prayer_schedule_helper.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/localization/app_localizations.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final PrayerTimesRepository repository;
  Timer? _stickyTimer;
  Future<void>? _activeFetch;
  DateTime? _lastFetchAt;

  static const Duration _minFetchInterval = Duration(minutes: 2);
  static const List<int> _stickyRefreshIds = [2001, 2002, 2003, 2004, 2005];

  PrayerTimesCubit(this.repository) : super(PrayerTimesInitial()) {
    _startStickyRefreshTimer();
  }

  Future<void> fetchPrayerTimes({bool force = false}) {
    if (_activeFetch != null) {
      return _activeFetch!;
    }

    final now = DateTime.now();
    final recentFetch =
        _lastFetchAt != null &&
        now.difference(_lastFetchAt!) < _minFetchInterval;
    if (!force && recentFetch && state is PrayerTimesLoaded) {
      final current = state as PrayerTimesLoaded;
      _updateStickyNotification(current.prayerTimes, current.locationName);
      return Future.value();
    }

    final future = _performFetch();
    _activeFetch = future;
    future.whenComplete(() => _activeFetch = null);
    return future;
  }

  Future<void> _performFetch() async {
    if (state is! PrayerTimesLoaded) {
      emit(PrayerTimesLoading());
    }
    try {
      final result = await repository.getPrayerTimes();

      if (result != null) {
        _lastFetchAt = DateTime.now();
        emit(
          PrayerTimesLoaded(
            result.prayerTimes,
            result.locationName,
            _lastFetchAt!,
            result.isFromCache,
          ),
        );
        await _syncPrayerNotifications(result.prayerTimes, result.locationName);
      } else {
        emit(
          const PrayerTimesError(
            'فشل في جلب أوقات الصلاة. يرجى التحقق من اتصالك بالإنترنت وصلاحيات الموقع.',
          ),
        );
      }
    } catch (e) {
      emit(PrayerTimesError('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  Future<bool> setManualLocation(String city) async {
    final saved = await repository.setManualLocationByCity(city);
    if (saved) {
      await fetchPrayerTimes(force: true);
    }
    return saved;
  }

  Future<void> useCurrentLocation() async {
    await repository.disableManualLocation();
    await fetchPrayerTimes(force: true);
  }

  Future<void> _syncPrayerNotifications(
    PrayerTimeModel times,
    String locationName,
  ) async {
    final int offset = StorageService.prayerOffset;
    final bool playAdhan = StorageService.playAdhan;
    final String adhanSound = StorageService.adhanSound;
    final now = DateTime.now();

    final prayers = PrayerScheduleHelper.prayerSlots(times, now);

    for (final slot in prayers) {
      final String name = slot.key.tr;
      final DateTime scheduledTime =
          PrayerScheduleHelper.notificationTimeForPrayer(
            prayerTime: slot.time,
            offsetMinutes: offset,
            now: now,
          );

      String body = offset > 0
          ? 'باقي $offset دقائق على أذان $name'
          : 'حان الآن موعد أذان $name';

      await NotificationService.cancelNotification(slot.id);
      await NotificationService.schedulePrayerNotification(
        id: slot.id,
        title: 'الصلاة القادمة',
        body: body,
        time: scheduledTime,
        playAdhan: playAdhan,
        adhanSound: adhanSound,
      );
    }

    _updateStickyNotification(times, locationName);

    await NotificationService.syncFastingReminders(prayerTimes: times);

    // Keep sticky notification fresh in background by scheduling updates at prayer boundaries.
    await _rescheduleStickyRefreshNotifications(times, locationName, now);
  }

  Future<void> _rescheduleStickyRefreshNotifications(
    PrayerTimeModel times,
    String locationName,
    DateTime now,
  ) async {
    for (final id in _stickyRefreshIds) {
      await NotificationService.cancelNotification(id);
    }

    if (!StorageService.stickyNotification) {
      return;
    }

    final slots = PrayerScheduleHelper.prayerSlots(times, now);
    for (var i = 0; i < slots.length && i < _stickyRefreshIds.length; i++) {
      final trigger = slots[i].time;
      final nextInfo = PrayerScheduleHelper.computeNextPrayer(
        times,
        reference: trigger.add(const Duration(seconds: 1)),
      );
      final timeStr = DateFormat('hh:mm a').format(nextInfo.slot.time);

      await NotificationService.schedulePersistentNotificationUpdate(
        id: _stickyRefreshIds[i],
        title: 'الصلاة القادمة: ${nextInfo.slot.key.tr} ($locationName)',
        body: 'الوقت: $timeStr',
        time: trigger,
      );
    }
  }

  void _updateStickyNotification(PrayerTimeModel times, String locationName) {
    if (!StorageService.stickyNotification) {
      NotificationService.removePersistentNotification();
      return;
    }

    final next = PrayerScheduleHelper.computeNextPrayer(times);
    final timeStr = DateFormat('hh:mm a').format(next.slot.time);
    final remaining = PrayerScheduleHelper.formatHoursMinutes(next.remaining);

    NotificationService.showPersistentNotification(
      'الصلاة القادمة: ${next.slot.key.tr} ($locationName)',
      'الوقت: $timeStr | المتبقي: $remaining',
    );
  }

  void _startStickyRefreshTimer() {
    _stickyTimer?.cancel();
    _stickyTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final current = state;
      if (current is PrayerTimesLoaded) {
        _updateStickyNotification(current.prayerTimes, current.locationName);
      }
    });
  }

  @override
  Future<void> close() {
    _stickyTimer?.cancel();
    return super.close();
  }
}
