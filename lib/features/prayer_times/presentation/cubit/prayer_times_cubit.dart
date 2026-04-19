import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import '../../data/repositories/prayer_times_repository.dart';
import '../../data/models/prayer_time_model.dart';
import '../../domain/prayer_schedule_helper.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/localization/app_localizations.dart';

part 'prayer_times_state.dart';
part 'prayer_times_fetch_mixin.dart';
part 'prayer_times_notifications_mixin.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState>
    with PrayerTimesFetchMixin, PrayerTimesNotificationsMixin {
  @override
  final PrayerTimesRepository repository;
  @override
  final IStorageService _storageService;
  @override
  final INotificationService _notificationService;
  Timer? _ticker;
  @override
  Future<void>? _activeFetch;
  @override
  DateTime? _lastFetchAt;
  DateTime? _lastStickyRefreshAt;

  static const Duration _minFetchInterval = Duration(minutes: 2);
  static const List<int> _stickyRefreshIds = [2001, 2002, 2003, 2004, 2005];

  PrayerTimesCubit(
    this.repository,
    this._storageService,
    this._notificationService,
  ) : super(PrayerTimesInitial()) {
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is PrayerTimesLoaded) {
        final nextInfo = PrayerScheduleHelper.computeNextPrayer(
          current.prayerTimes,
        );
        final countdown = PrayerScheduleHelper.formatCountdown(
          nextInfo.remaining,
        );
        if (countdown != current.countdownText ||
            nextInfo.slot.key != current.nextPrayerKey) {
          emit(
            current.copyWith(
              nextPrayerKey: nextInfo.slot.key,
              nextPrayerIcon: nextInfo.slot.icon,
              countdownText: countdown,
            ),
          );
        }

        final now = DateTime.now();
        final shouldRefreshSticky =
            _lastStickyRefreshAt == null ||
            now.difference(_lastStickyRefreshAt!) >= const Duration(minutes: 1);
        if (shouldRefreshSticky) {
          _lastStickyRefreshAt = now;
          _updateStickyNotification(current.prayerTimes, current.locationName);
        }
      }
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
