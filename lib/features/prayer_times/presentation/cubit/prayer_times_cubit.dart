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

  PrayerTimesCubit(this.repository) : super(PrayerTimesInitial()) {
    _startStickyRefreshTimer();
  }

  Future<void> fetchPrayerTimes() async {
    emit(PrayerTimesLoading());
    try {
      final result = await repository.getPrayerTimes();

      if (result != null) {
        emit(
          PrayerTimesLoaded(
            result.prayerTimes,
            result.locationName,
            DateTime.now(),
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
      await fetchPrayerTimes();
    }
    return saved;
  }

  Future<void> useCurrentLocation() async {
    await repository.disableManualLocation();
    await fetchPrayerTimes();
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
