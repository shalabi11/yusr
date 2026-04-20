import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import '../../data/repositories/prayer_times_repository.dart';
import '../../data/models/prayer_time_model.dart';
import '../../domain/prayer_countdown_service.dart';
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
  @override
  final PrayerCountdownService _countdownService;
  Timer? _stickyRefreshTimer;
  @override
  Future<void>? _activeFetch;
  @override
  DateTime? _lastFetchAt;

  static const Duration _minFetchInterval = Duration(minutes: 2);
  static const List<int> _stickyRefreshIds = [2001, 2002, 2003, 2004, 2005];

  PrayerTimesCubit(
    this.repository,
    this._storageService,
    this._notificationService,
    this._countdownService,
  ) : super(PrayerTimesInitial()) {
    _startStickyRefreshTimer();
  }

  void _startStickyRefreshTimer() {
    _stickyRefreshTimer?.cancel();
    _stickyRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final current = state;
      if (current is PrayerTimesLoaded) {
        _updateStickyNotification(current.prayerTimes, current.locationName);
      }
    });
  }

  @override
  Future<void> close() {
    _stickyRefreshTimer?.cancel();
    _countdownService.clear();
    return super.close();
  }
}
