part of 'prayer_times_cubit.dart';

mixin PrayerTimesFetchMixin on Cubit<PrayerTimesState> {
  PrayerTimesRepository get repository;
  PrayerCountdownService get _countdownService;
  DateTime? get _lastFetchAt;
  set _lastFetchAt(DateTime? value);
  Future<void>? get _activeFetch;
  set _activeFetch(Future<void>? value);

  Future<void> _syncPrayerNotifications(
    PrayerTimeModel times,
    String locationName,
  ) => syncPrayerNotificationsInternal(times, locationName);

  Future<void> syncPrayerNotificationsInternal(
    PrayerTimeModel times,
    String locationName,
  );

  Future<void> fetchPrayerTimes({bool force = false}) {
    if (_activeFetch != null) {
      return _activeFetch!;
    }

    final now = DateTime.now();
    final recentFetch =
        _lastFetchAt != null &&
        now.difference(_lastFetchAt!) < PrayerTimesCubit._minFetchInterval;
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
      await result.fold(
        (failure) async {
          _countdownService.clear();
          emit(PrayerTimesError(failure.message));
        },
        (data) async {
          _lastFetchAt = DateTime.now();
          final nextInfo = PrayerScheduleHelper.computeNextPrayer(
            data.prayerTimes,
          );
          emit(
            PrayerTimesLoaded(
              data.prayerTimes,
              data.locationName,
              _lastFetchAt!,
              data.isFromCache,
              nextInfo.slot.key,
              nextInfo.slot.icon,
              PrayerScheduleHelper.formatCountdown(nextInfo.remaining),
            ),
          );
          _countdownService.bindPrayerTimes(data.prayerTimes);
          await _syncPrayerNotifications(data.prayerTimes, data.locationName);
        },
      );
    } catch (e) {
      _countdownService.clear();
      emit(PrayerTimesError('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  Future<bool> setManualLocation(String city) async {
    final savedResult = await repository.setManualLocationByCity(city);
    final saved = savedResult.fold((_) => false, (value) => value);
    if (saved) {
      await fetchPrayerTimes(force: true);
    }
    return saved;
  }

  Future<void> useCurrentLocation() async {
    await repository.disableManualLocation();
    await fetchPrayerTimes(force: true);
  }

  void _updateStickyNotification(PrayerTimeModel times, String locationName);
}
