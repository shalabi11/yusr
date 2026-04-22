import 'package:shared_preferences/shared_preferences.dart';

class StorageUiModule {
  StorageUiModule(this._prefs);

  final SharedPreferences _prefs;

  bool get remindersSwipeHintSeen =>
      _prefs.getBool('reminders_swipe_hint_seen') ?? false;

  Future<void> setRemindersSwipeHintSeen(bool seen) async {
    await _prefs.setBool('reminders_swipe_hint_seen', seen);
  }

  bool get introSeen => _prefs.getBool('intro_seen') ?? false;

  Future<void> setIntroSeen(bool seen) async {
    await _prefs.setBool('intro_seen', seen);
  }

  bool get accountOnboardingSeen =>
      _prefs.getBool('account_onboarding_seen') ?? false;

  Future<void> setAccountOnboardingSeen(bool seen) async {
    await _prefs.setBool('account_onboarding_seen', seen);
  }

  bool get isContentDownloaded =>
      _prefs.getBool('is_content_downloaded') ?? false;

  Future<void> setContentDownloaded(bool downloaded) async {
    await _prefs.setBool('is_content_downloaded', downloaded);
  }

  bool get quranContentDownloaded =>
      _prefs.getBool('quran_content_downloaded') ?? false;

  Future<void> setQuranContentDownloaded(bool downloaded) async {
    await _prefs.setBool('quran_content_downloaded', downloaded);
  }

  bool get adhkarContentDownloaded =>
      _prefs.getBool('adhkar_content_downloaded') ?? false;

  Future<void> setAdhkarContentDownloaded(bool downloaded) async {
    await _prefs.setBool('adhkar_content_downloaded', downloaded);
  }

  int get downloadedContentVersion =>
      _prefs.getInt('downloaded_content_version') ?? 0;

  Future<void> setDownloadedContentVersion(int version) async {
    await _prefs.setInt('downloaded_content_version', version);
  }

  String? get downloadedContentBasePath =>
      _prefs.getString('downloaded_content_base_path');

  Future<void> setDownloadedContentBasePath(String? path) async {
    if (path == null || path.isEmpty) {
      await _prefs.remove('downloaded_content_base_path');
      return;
    }
    await _prefs.setString('downloaded_content_base_path', path);
  }
}
