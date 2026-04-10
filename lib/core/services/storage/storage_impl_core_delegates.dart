part of 'storage_sevice_impl.dart';

mixin StorageCoreDelegates {
  StorageCoreModule get _core;
  StorageLanguageModule get _language;

  String get language => _language.language;

  Future<void> setLanguage(String langCode) => _language.setLanguage(langCode);

  Future<void> saveData(String key, dynamic value) =>
      _core.saveData(key, value);

  dynamic getData(String key) => _core.getData(key);
}
