abstract class IStorageService {
  String get language;
  Future<void> setLanguage(String langCode);

  Future<void> saveData(String key, dynamic value);
  dynamic getData(String key);

  int get prayerOffset;
  Future<void> setPrayerOffset(int offset);

  bool get playAdhan;
  Future<void> setPlayAdhan(bool play);

  bool get stickyNotification;
  Future<void> setStickyNotification(bool sticky);

  String get adhanSound;
  Future<void> setAdhanSound(String soundKey);

  bool get lastThirdNightReminderEnabled;
  Future<void> setLastThirdNightReminderEnabled(bool enabled);

  bool get sunnahPrayerRemindersEnabled;
  Future<void> setSunnahPrayerRemindersEnabled(bool enabled);

  double? get manualLat;
  double? get manualLng;
  String? get manualCity;
  bool get hasManualLocation;

  Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String city,
  });
  Future<void> clearManualLocation();

  bool get quranReadAsText;
  Future<void> setQuranReadAsText(bool readAsText);

  bool get remindersSwipeHintSeen;
  Future<void> setRemindersSwipeHintSeen(bool seen);

  bool get introSeen;
  Future<void> setIntroSeen(bool seen);

  bool get accountOnboardingSeen;
  Future<void> setAccountOnboardingSeen(bool seen);

  bool get isContentDownloaded;
  Future<void> setContentDownloaded(bool downloaded);

  bool get quranContentDownloaded;
  Future<void> setQuranContentDownloaded(bool downloaded);

  bool get adhkarContentDownloaded;
  Future<void> setAdhkarContentDownloaded(bool downloaded);

  int get downloadedContentVersion;
  Future<void> setDownloadedContentVersion(int version);

  String? get downloadedContentBasePath;
  Future<void> setDownloadedContentBasePath(String? path);

  bool get fastingRemindersEnabled;
  Future<void> setFastingRemindersEnabled(bool enabled);

  bool get whiteDaysReminderEnabled;
  Future<void> setWhiteDaysReminderEnabled(bool enabled);

  bool get mondayThursdayReminderEnabled;
  Future<void> setMondayThursdayReminderEnabled(bool enabled);

  String? get lastWhiteDaysScheduleToken;
  Future<void> setLastWhiteDaysScheduleToken(String? token);
}
