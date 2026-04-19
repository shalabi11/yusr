import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/core/services/storage/storage_core_module.dart';
import 'package:yusr_app/core/services/storage/storage_fasting_module.dart';
import 'package:yusr_app/core/services/storage/storage_language_module.dart';
import 'package:yusr_app/core/services/storage/storage_location_module.dart';
import 'package:yusr_app/core/services/storage/storage_prayer_module.dart';
import 'package:yusr_app/core/services/storage/storage_quran_module.dart';
import 'package:yusr_app/core/services/storage/storage_ui_module.dart';

part 'storage_impl_core_delegates.dart';
part 'storage_impl_prayer_delegates.dart';
part 'storage_impl_location_ui_fasting_delegates.dart';

class StorageServiceImpl
    with
        StorageCoreDelegates,
        StoragePrayerDelegates,
        StorageLocationUiFastingDelegates
    implements IStorageService {
  StorageServiceImpl(SharedPreferences prefs)
    : _core = StorageCoreModule(prefs),
      _language = StorageLanguageModule(prefs),
      _prayer = StoragePrayerModule(prefs),
      _location = StorageLocationModule(prefs),
      _quran = StorageQuranModule(prefs),
      _ui = StorageUiModule(prefs),
      _fasting = StorageFastingModule(prefs);

  @override
  final StorageCoreModule _core;
  @override
  final StorageLanguageModule _language;
  @override
  final StoragePrayerModule _prayer;
  @override
  final StorageLocationModule _location;
  @override
  final StorageQuranModule _quran;
  @override
  final StorageUiModule _ui;
  @override
  final StorageFastingModule _fasting;
}
