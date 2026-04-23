import 'package:yusr_app/core/services/storage/istorage_service.dart';

/// A utility to manage caching of repository data with timestamps.
class CacheManager {
  final IStorageService _storageService;

  CacheManager(this._storageService);

  /// Saves [data] to storage with a timestamp key.
  Future<void> saveWithTimestamp(String key, dynamic data) async {
    await _storageService.saveData(key, data);
    await _storageService.saveData(
      _timestampKey(key),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Checks if the cached data for [key] is still within the [window].
  bool isFresh(String key, Duration window) {
    final rawTimestamp = _storageService.getData(_timestampKey(key));
    final lastFetchAt = _parseTimestamp(rawTimestamp);
    
    if (lastFetchAt == null) return false;

    final hasData = _storageService.getData(key) != null;
    if (!hasData) return false;

    return DateTime.now().difference(lastFetchAt) < window;
  }

  /// Retrieves the timestamp for a given [key].
  DateTime? getTimestamp(String key) {
    return _parseTimestamp(_storageService.getData(_timestampKey(key)));
  }

  String _timestampKey(String key) => '${key}_last_fetch_at';

  DateTime? _parseTimestamp(dynamic value) {
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
