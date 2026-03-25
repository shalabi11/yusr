import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LatLngData {
  final double latitude;
  final double longitude;

  const LatLngData(this.latitude, this.longitude);
}

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  static Future<Placemark?> getCityName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<LatLngData?> geocodeCityName(String cityName) async {
    try {
      final locations = await locationFromAddress(cityName);
      if (locations.isEmpty) return null;
      final first = locations.first;
      return LatLngData(first.latitude, first.longitude);
    } catch (_) {
      return null;
    }
  }
}
