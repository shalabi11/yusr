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
  final PrayerTimesRemoteDataSource _remoteDataSource =
      PrayerTimesRemoteDataSource();
  static const String _prayerTimesKey = 'cached_prayer_times';
  static const String _locationNameKey = 'cached_location_name';
  static const String _manualLocationEnabledKey = 'manual_location_enabled';

  Future<bool> setManualLocationByCity(String city) async {
    final coords = await LocationService.geocodeCityName(city);
    if (coords == null) return false;

    await StorageService.setManualLocation(
      lat: coords.latitude,
      lng: coords.longitude,
      city: city,
    );
    await StorageService.saveData(_manualLocationEnabledKey, true);
    return true;
  }

  Future<void> disableManualLocation() async {
    await StorageService.saveData(_manualLocationEnabledKey, false);
  }

  bool get isManualLocationEnabled {
    final enabled = StorageService.getData(_manualLocationEnabledKey);
    return enabled == true;
  }

  Future<PrayerTimesFetchResult?> getPrayerTimes() async {
    double? lat;
    double? lng;
    String locationName = getCachedLocationName();

    if (isManualLocationEnabled && StorageService.hasManualLocation) {
      lat = StorageService.manualLat;
      lng = StorageService.manualLng;
      locationName = StorageService.manualCity ?? locationName;
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
        await StorageService.saveData(_prayerTimesKey, remoteData.toJson());
        await StorageService.saveData(_locationNameKey, locationName);
        return PrayerTimesFetchResult(
          prayerTimes: remoteData,
          locationName: locationName,
          isFromCache: false,
        );
      }
    }

    final cachedData = StorageService.getData(_prayerTimesKey);
    if (cachedData != null) {
      return PrayerTimesFetchResult(
        prayerTimes: PrayerTimeModel.fromJson(
          cachedData as Map<String, dynamic>,
        ),
        locationName: locationName,
        isFromCache: true,
      );
    }

    return null;
  }

  String getCachedLocationName() {
    final name = StorageService.getData(_locationNameKey);
    return name?.toString() ?? 'موقع غير معروف';
  }
}
