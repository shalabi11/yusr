part of '../settings_cubit.dart';

mixin SettingsCubitMutations on Cubit<SettingsState> {
  IStorageService get _storageService;
  INotificationService get _notificationService;

  void changeLanguage(String code) {
    if (code == state.langCode) return;
    _storageService.setLanguage(code);
    AppLocalizations.currentLang = code;
    final nextState = state.copyWith(langCode: code);
    emit(nextState);
    syncStateToRemoteInternal(nextState);
  }

  void setPrayerOffset(int offset) {
    if (offset == state.prayerOffset) return;
    _storageService.setPrayerOffset(offset);
    final nextState = state.copyWith(prayerOffset: offset);
    emit(nextState);
    syncStateToRemoteInternal(nextState);
  }

  void setPlayAdhan(bool play) {
    if (play == state.playAdhan) return;
    _storageService.setPlayAdhan(play);
    final nextState = state.copyWith(playAdhan: play);
    emit(nextState);
    syncStateToRemoteInternal(nextState);
  }

  void setStickyNotification(bool sticky) {
    if (sticky == state.stickyNotification) return;
    _storageService.setStickyNotification(sticky);
    final nextState = state.copyWith(stickyNotification: sticky);
    emit(nextState);
    syncStateToRemoteInternal(nextState);

    if (!sticky) {
      _notificationService.removePersistentNotification();
    }
  }

  void setAdhanSound(String soundKey) {
    if (soundKey == state.adhanSound) return;
    _storageService.setAdhanSound(soundKey);
    final nextState = state.copyWith(adhanSound: soundKey);
    emit(nextState);
    syncStateToRemoteInternal(nextState);
  }

  void setQuranReadAsText(bool readAsText) {
    if (readAsText == state.quranReadAsText) return;
    _storageService.setQuranReadAsText(readAsText);
    final nextState = state.copyWith(quranReadAsText: readAsText);
    emit(nextState);
    syncStateToRemoteInternal(nextState);
  }

  Future<void> setFastingRemindersEnabled(bool enabled) async {
    if (enabled == state.fastingRemindersEnabled) return;
    await _storageService.setFastingRemindersEnabled(enabled);
    final nextState = state.copyWith(fastingRemindersEnabled: enabled);
    emit(nextState);
    await syncStateToRemoteInternal(nextState);
  }

  Future<void> setWhiteDaysReminderEnabled(bool enabled) async {
    if (enabled == state.whiteDaysReminderEnabled) return;
    await _storageService.setWhiteDaysReminderEnabled(enabled);
    final nextState = state.copyWith(whiteDaysReminderEnabled: enabled);
    emit(nextState);
    await syncStateToRemoteInternal(nextState);
  }

  Future<void> setMondayThursdayReminderEnabled(bool enabled) async {
    if (enabled == state.mondayThursdayReminderEnabled) return;
    await _storageService.setMondayThursdayReminderEnabled(enabled);
    final nextState = state.copyWith(mondayThursdayReminderEnabled: enabled);
    emit(nextState);
    await syncStateToRemoteInternal(nextState);
  }

  Future<void> syncStateToRemoteInternal(SettingsState snapshot);
}
