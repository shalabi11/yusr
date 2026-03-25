import 'app_translations.dart';

// No need for ValueNotifier anymore, the Cubit will enforce view re-renders!
class AppLocalizations {
  static String currentLang = 'ar';

  static String tr(String key) {
    return AppStrings.translations[currentLang]?[key] ?? key;
  }
}

extension StringLocalization on String {
  String get tr => AppLocalizations.tr(this);
}
