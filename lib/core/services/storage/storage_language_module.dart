import 'package:shared_preferences/shared_preferences.dart';

class StorageLanguageModule {
  StorageLanguageModule(this._prefs);

  final SharedPreferences _prefs;

  String get language => _prefs.getString('language') ?? 'ar';

  Future<void> setLanguage(String langCode) async {
    await _prefs.setString('language', langCode);
  }
}
