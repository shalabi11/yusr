import 'package:shared_preferences/shared_preferences.dart';

class StorageQuranModule {
  StorageQuranModule(this._prefs);

  final SharedPreferences _prefs;

  bool get quranReadAsText => _prefs.getBool('quran_read_as_text') ?? false;

  Future<void> setQuranReadAsText(bool readAsText) async {
    await _prefs.setBool('quran_read_as_text', readAsText);
  }
}
