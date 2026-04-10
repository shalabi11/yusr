part of 'storage_sevice_impl.dart';

mixin StorageLocationUiFastingDelegates {
  StorageLocationModule get _location;
  StorageUiModule get _ui;
  StorageFastingModule get _fasting;

  double? get manualLat => _location.manualLat;

  double? get manualLng => _location.manualLng;

  String? get manualCity => _location.manualCity;

  bool get hasManualLocation => _location.hasManualLocation;

  Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String city,
  }) => _location.setManualLocation(lat: lat, lng: lng, city: city);

  Future<void> clearManualLocation() => _location.clearManualLocation();

  bool get remindersSwipeHintSeen => _ui.remindersSwipeHintSeen;

  Future<void> setRemindersSwipeHintSeen(bool seen) =>
      _ui.setRemindersSwipeHintSeen(seen);

  bool get introSeen => _ui.introSeen;

  Future<void> setIntroSeen(bool seen) => _ui.setIntroSeen(seen);

  bool get fastingRemindersEnabled => _fasting.fastingRemindersEnabled;

  Future<void> setFastingRemindersEnabled(bool enabled) =>
      _fasting.setFastingRemindersEnabled(enabled);

  bool get whiteDaysReminderEnabled => _fasting.whiteDaysReminderEnabled;

  Future<void> setWhiteDaysReminderEnabled(bool enabled) =>
      _fasting.setWhiteDaysReminderEnabled(enabled);

  bool get mondayThursdayReminderEnabled =>
      _fasting.mondayThursdayReminderEnabled;

  Future<void> setMondayThursdayReminderEnabled(bool enabled) =>
      _fasting.setMondayThursdayReminderEnabled(enabled);

  String? get lastWhiteDaysScheduleToken => _fasting.lastWhiteDaysScheduleToken;

  Future<void> setLastWhiteDaysScheduleToken(String? token) =>
      _fasting.setLastWhiteDaysScheduleToken(token);
}
