import 'package:dartz/dartz.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import '../../../../core/services/location_service.dart';
import '../datasources/prayer_times_remote_datasource.dart';
import '../models/prayer_time_model.dart';

part 'prayer_times_repository_helpers.dart';

class PrayerTimesFetchResult {
  final PrayerTimeModel prayerTimes;
  final String locationName;
  final bool isFromCache;

  const PrayerTimesFetchResult({
    required this.prayerTimes,
    required this.locationName,
    required this.isFromCache,
  });
}

class PrayerTimesRepository {
  final PrayerTimesRemoteDataSource _remoteDataSource;
  final IStorageService _storageService;
  static const String _prayerTimesKey = 'cached_prayer_times';
  static const String _locationNameKey = 'cached_location_name';
  static const String _manualLocationEnabledKey = 'manual_location_enabled';
  static const String _lastRemoteFetchAtKey =
      'prayer_times_last_remote_fetch_at';
  static const Duration _cacheFreshWindow = Duration(minutes: 30);

  PrayerTimesRepository({
    PrayerTimesRemoteDataSource? remoteDataSource,
    required IStorageService storageService,
  }) : _remoteDataSource = remoteDataSource ?? PrayerTimesRemoteDataSource(),
       _storageService = storageService;

  Future<Either<Failure, bool>> setManualLocationByCity(String city) async {
    try {
      final coords = await LocationService.geocodeCityName(city);
      if (coords == null) {
        return const Left(LocationFailure('تعذر العثور على المدينة المطلوبة'));
      }

      await _storageService.setManualLocation(
        lat: coords.latitude,
        lng: coords.longitude,
        city: city,
      );
      await _storageService.saveData(_manualLocationEnabledKey, true);
      return const Right(true);
    } catch (_) {
      return const Left(LocationFailure());
    }
  }

  Future<Either<Failure, Unit>> disableManualLocation() async {
    try {
      await _storageService.saveData(_manualLocationEnabledKey, false);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  bool get isManualLocationEnabled {
    final enabled = _storageService.getData(_manualLocationEnabledKey);
    return enabled == true;
  }

  Future<Either<Failure, PrayerTimesFetchResult>> getPrayerTimes({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cachedLocationName = getCachedLocationName();
        final shouldUseCache = _hasFreshRemoteFetch();
        if (shouldUseCache) {
          final cached = buildCachedResult(cachedLocationName);
          if (cached != null) {
            return cached;
          }
        }
      }

      final resolved = await resolveLocationCoordinates();
      final remote = await tryFetchRemote(
        lat: resolved.$1,
        lng: resolved.$2,
        locationName: resolved.$3,
      );
      if (remote != null) return remote;

      final cached = buildCachedResult(resolved.$3);
      if (cached != null) return cached;

      return const Left(
        ServerFailure(
          'فشل في جلب أوقات الصلاة. يرجى التحقق من الاتصال وصلاحيات الموقع',
        ),
      );
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  String getCachedLocationName() {
    final name = _storageService.getData(_locationNameKey);
    return name?.toString() ?? 'موقع غير معروف';
  }

  bool _hasFreshRemoteFetch() {
    final rawLastFetchAt = _storageService.getData(_lastRemoteFetchAtKey);
    final lastFetchAt = _parseLastFetchAt(rawLastFetchAt);
    if (lastFetchAt == null) {
      return false;
    }

    final hasCachedPrayerTimes = _storageService.getData(_prayerTimesKey);
    if (hasCachedPrayerTimes == null) {
      return false;
    }

    return DateTime.now().difference(lastFetchAt) < _cacheFreshWindow;
  }

  DateTime? _parseLastFetchAt(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    if (value is String) {
      final millis = int.tryParse(value);
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
    }

    return null;
  }
}
