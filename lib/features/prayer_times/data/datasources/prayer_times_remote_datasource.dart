import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/prayer_time_model.dart';

class PrayerTimesRemoteDataSource {
  final Dio dio = Dio();

  Future<PrayerTimeModel?> getPrayerTimesByCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      final response = await dio.get(
        'https://api.aladhan.com/v1/timings',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'method': 4, // Umm Al-Qura Method
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['timings'];
        return PrayerTimeModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
      return null;
    }
  }
}
