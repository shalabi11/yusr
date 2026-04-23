part of 'prayer_times_repository.dart';

extension PrayerTimesRepositoryHelpers on PrayerTimesRepository {
  Future<(double?, double?, String)> resolveLocationCoordinates() async {
    double? lat;
    double? lng;
    String locationName = getCachedLocationName();

    if (isManualLocationEnabled && _storageService.hasManualLocation) {
      lat = _storageService.manualLat;
      lng = _storageService.manualLng;
      locationName = _storageService.manualCity ?? locationName;
      return (lat, lng, locationName);
    }

    final position = await LocationService.getCurrentLocation();
    if (position == null) return (lat, lng, locationName);

    lat = position.latitude;
    lng = position.longitude;

    final placemark = await LocationService.getCityName(position);
    if (placemark != null) {
      locationName =
          placemark.locality ??
          placemark.subAdministrativeArea ??
          'Unknown Location';
    }

    return (lat, lng, locationName);
  }

  Future<Either<Failure, PrayerTimesFetchResult>?> tryFetchRemote({
    required double? lat,
    required double? lng,
    required String locationName,
  }) async {
    if (lat == null || lng == null) return null;

    final remoteData = await _remoteDataSource.getPrayerTimesByCoordinates(
      lat,
      lng,
    );
    if (remoteData == null) return null;

    await _cacheManager.saveWithTimestamp(
      PrayerTimesRepository._prayerTimesKey,
      remoteData.toJson(),
    );
    await _storageService.saveData(
      PrayerTimesRepository._locationNameKey,
      locationName,
    );

    return Right(
      PrayerTimesFetchResult(
        prayerTimes: remoteData,
        locationName: locationName,
        isFromCache: false,
      ),
    );
  }

  Either<Failure, PrayerTimesFetchResult>? buildCachedResult(
    String locationName,
  ) {
    final cachedData = _storageService.getData(
      PrayerTimesRepository._prayerTimesKey,
    );
    if (cachedData == null) return null;

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
}
