import 'package:dartz/dartz.dart';
import 'package:yusr_app/core/error/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/storage_service.dart';
import '../datasources/prayer_times_remote_datasource.dart';
import '../models/prayer_time_model.dart';

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

  Future<Either<Failure, PrayerTimesFetchResult>> getPrayerTimes() async {
    double? lat;
    double? lng;
    String locationName = getCachedLocationName();

    try {
      if (isManualLocationEnabled && _storageService.hasManualLocation) {
        lat = _storageService.manualLat;
        lng = _storageService.manualLng;
        locationName = _storageService.manualCity ?? locationName;
      } else {
        final position = await LocationService.getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;

          final placemark = await LocationService.getCityName(position);
          if (placemark != null) {
            locationName =
                placemark.locality ??
                placemark.subAdministrativeArea ??
                'Unknown Location';
          }
        }
      }

      if (lat != null && lng != null) {
        final remoteData = await _remoteDataSource.getPrayerTimesByCoordinates(
          lat,
          lng,
        );

        if (remoteData != null) {
          await _storageService.saveData(_prayerTimesKey, remoteData.toJson());
          await _storageService.saveData(_locationNameKey, locationName);
          return Right(
            PrayerTimesFetchResult(
              prayerTimes: remoteData,
              locationName: locationName,
              isFromCache: false,
            ),
          );
        }
      }

      final cachedData = _storageService.getData(_prayerTimesKey);
      if (cachedData != null) {
        return Right(
          PrayerTimesFetchResult(
            prayerTimes: PrayerTimeModel.fromJson(
              cachedData as Map<String, dynamic>,
            ),
            locationName: locationName,
            isFromCache: true,
          ),
        );
      }

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
}
