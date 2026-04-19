part of '../settings_cubit.dart';

mixin SettingsCubitStorageSync on Cubit<SettingsState> {
  IStorageService get _storageService;
  SettingsRemoteSyncService get _remoteSync;
  bool get _isApplyingRemoteState;

  Future<void> _applyStateToStorage(SettingsState settings) async {
    await _storageService.setLanguage(settings.langCode);
    await _storageService.setPrayerOffset(settings.prayerOffset);
    await _storageService.setPlayAdhan(settings.playAdhan);
    await _storageService.setStickyNotification(settings.stickyNotification);
    await _storageService.setAdhanSound(settings.adhanSound);
    await _storageService.setQuranReadAsText(settings.quranReadAsText);
    await _storageService.setFastingRemindersEnabled(
      settings.fastingRemindersEnabled,
    );
    await _storageService.setWhiteDaysReminderEnabled(
      settings.whiteDaysReminderEnabled,
    );
    await _storageService.setMondayThursdayReminderEnabled(
      settings.mondayThursdayReminderEnabled,
    );
  }

  Future<void> syncStateToRemoteInternal(SettingsState snapshot) async {
    if (_isApplyingRemoteState) return;

    try {
      await _remoteSync.save(snapshot);
    } catch (_) {
      // Local state remains primary fallback when network/database fails.
    }
  }
}
