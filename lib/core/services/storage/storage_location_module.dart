import 'package:shared_preferences/shared_preferences.dart';

class StorageLocationModule {
  StorageLocationModule(this._prefs);

  final SharedPreferences _prefs;

  double? get manualLat => _prefs.getDouble('manual_lat');
  double? get manualLng => _prefs.getDouble('manual_lng');
  String? get manualCity => _prefs.getString('manual_city');

  bool get hasManualLocation => manualLat != null && manualLng != null;

  Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String city,
  }) async {
    await _prefs.setDouble('manual_lat', lat);
    await _prefs.setDouble('manual_lng', lng);
    await _prefs.setString('manual_city', city);
  }

  Future<void> clearManualLocation() async {
    await _prefs.remove('manual_lat');
    await _prefs.remove('manual_lng');
    await _prefs.remove('manual_city');
  }
}
