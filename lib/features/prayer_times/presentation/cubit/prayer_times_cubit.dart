import 'dart:async';

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
  final PrayerTimesRepository repository;
  final IStorageService _storageService;
  final INotificationService _notificationService;
  Timer? _stickyTimer;
  Future<void>? _activeFetch;
  DateTime? _lastFetchAt;

  static const Duration _minFetchInterval = Duration(minutes: 2);
  static const List<int> _stickyRefreshIds = [2001, 2002, 2003, 2004, 2005];

  PrayerTimesCubit(
    this.repository,
    this._storageService,
    this._notificationService,
  ) : super(PrayerTimesInitial()) {
    _startStickyRefreshTimer();
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
