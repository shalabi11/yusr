import 'package:yusr_app/core/services/storage/istorage_service.dart';

class FakeStorageService implements IStorageService {
  final Map<String, dynamic> _data = <String, dynamic>{};

  @override
  String language = 'ar';

  @override
  int prayerOffset = 0;

  @override
  bool playAdhan = true;

  @override
  bool stickyNotification = true;

  @override
  String adhanSound = 'adhan1';

  @override
  double? manualLat;

  @override
  double? manualLng;

  @override
  String? manualCity;

  @override
  bool quranReadAsText = false;

  @override
  bool remindersSwipeHintSeen = false;

  @override
  bool introSeen = false;

  @override
  bool accountOnboardingSeen = false;

  @override
  bool isContentDownloaded = false;

  @override
  bool quranContentDownloaded = false;

  @override
  bool adhkarContentDownloaded = false;

  @override
  int downloadedContentVersion = 0;

  @override
  String? downloadedContentBasePath;

  @override
  bool fastingRemindersEnabled = true;

  @override
  bool whiteDaysReminderEnabled = true;

  @override
  bool mondayThursdayReminderEnabled = true;

  @override
  String? lastWhiteDaysScheduleToken;

  @override
  bool get hasManualLocation =>
      manualLat != null &&
      manualLng != null &&
      (manualCity?.isNotEmpty ?? false);

  @override
  Future<void> clearManualLocation() async {
    manualLat = null;
    manualLng = null;
    manualCity = null;
  }

  @override
  dynamic getData(String key) => _data[key];

  @override
  Future<void> saveData(String key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<void> setAccountOnboardingSeen(bool seen) async {
    accountOnboardingSeen = seen;
  }

  @override
  Future<void> setAdhanSound(String soundKey) async {
    adhanSound = soundKey;
  }

  @override
  Future<void> setAdhkarContentDownloaded(bool downloaded) async {
    adhkarContentDownloaded = downloaded;
  }

  @override
  Future<void> setContentDownloaded(bool downloaded) async {
    isContentDownloaded = downloaded;
  }

  @override
  Future<void> setDownloadedContentBasePath(String? path) async {
    downloadedContentBasePath = path;
  }

  @override
  Future<void> setDownloadedContentVersion(int version) async {
    downloadedContentVersion = version;
  }

  @override
  Future<void> setFastingRemindersEnabled(bool enabled) async {
    fastingRemindersEnabled = enabled;
  }

  @override
  Future<void> setIntroSeen(bool seen) async {
    introSeen = seen;
  }

  @override
  Future<void> setLanguage(String langCode) async {
    language = langCode;
  }

  @override
  Future<void> setLastWhiteDaysScheduleToken(String? token) async {
    lastWhiteDaysScheduleToken = token;
  }

  @override
  Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String city,
  }) async {
    manualLat = lat;
    manualLng = lng;
    manualCity = city;
  }

  @override
  Future<void> setMondayThursdayReminderEnabled(bool enabled) async {
    mondayThursdayReminderEnabled = enabled;
  }

  @override
  Future<void> setPlayAdhan(bool play) async {
    playAdhan = play;
  }

  @override
  Future<void> setPrayerOffset(int offset) async {
    prayerOffset = offset;
  }

  @override
  Future<void> setQuranContentDownloaded(bool downloaded) async {
    quranContentDownloaded = downloaded;
  }

  @override
  Future<void> setQuranReadAsText(bool readAsText) async {
    quranReadAsText = readAsText;
  }

  @override
  Future<void> setRemindersSwipeHintSeen(bool seen) async {
    remindersSwipeHintSeen = seen;
  }

  @override
  Future<void> setStickyNotification(bool sticky) async {
    stickyNotification = sticky;
  }

  @override
  Future<void> setWhiteDaysReminderEnabled(bool enabled) async {
    whiteDaysReminderEnabled = enabled;
  }
}
