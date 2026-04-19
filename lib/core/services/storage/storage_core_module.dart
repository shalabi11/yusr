import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageCoreModule {
  StorageCoreModule(this._prefs);

  final SharedPreferences _prefs;

  Future<void> saveData(String key, dynamic value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  dynamic getData(String key) {
    final String? data = _prefs.getString(key);
    if (data == null) return null;
    return jsonDecode(data);
  }
}
