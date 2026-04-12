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
}
