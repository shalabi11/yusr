import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';

import '../services/notification_service.dart';
import '../localization/app_localizations.dart';
import 'settings/settings_remote_sync_service.dart';
import 'settings/settings_state.dart';

export 'settings/settings_state.dart';

part 'settings/settings_cubit_storage_sync.dart';
part 'settings/settings_cubit_mutations.dart';

class SettingsCubit extends Cubit<SettingsState>
    with SettingsCubitStorageSync, SettingsCubitMutations {
  SettingsCubit(
    this._storageService,
    this._notificationService, {
    SupabaseClient? supabaseClient,
  }) : _remoteSync = SettingsRemoteSyncService(supabaseClient),
       super(
         SettingsState(
           langCode: _storageService.language,
           prayerOffset: _storageService.prayerOffset,
           playAdhan: _storageService.playAdhan,
           stickyNotification: _storageService.stickyNotification,
           adhanSound: _storageService.adhanSound,
           quranReadAsText: _storageService.quranReadAsText,
           fastingRemindersEnabled: _storageService.fastingRemindersEnabled,
           whiteDaysReminderEnabled: _storageService.whiteDaysReminderEnabled,
           mondayThursdayReminderEnabled:
               _storageService.mondayThursdayReminderEnabled,
         ),
       ) {
    // Sync current lang on boot
    AppLocalizations.currentLang = state.langCode;
  }

  final IStorageService _storageService;
  final INotificationService _notificationService;
  final SettingsRemoteSyncService _remoteSync;
  bool _isApplyingRemoteState = false;

  Future<void> loadFromRemoteOnStartup() async {
    try {
      final remoteState = await _remoteSync.load(state);
      if (remoteState == null) {
        await syncStateToRemoteInternal(state);
        return;
      }

      _isApplyingRemoteState = true;
      try {
        await _applyStateToStorage(remoteState);

        AppLocalizations.currentLang = remoteState.langCode;
        emit(remoteState);

        if (!remoteState.stickyNotification) {
          await _notificationService.removePersistentNotification();
        }
      } finally {
        _isApplyingRemoteState = false;
      }
    } catch (_) {
      // Keep local settings as source of truth if remote load fails.
    }
  }
}
