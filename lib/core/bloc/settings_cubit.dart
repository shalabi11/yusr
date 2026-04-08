import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import '../services/notification_service.dart';
import '../localization/app_localizations.dart';

class SettingsState {
  final String langCode;
  final int prayerOffset;
  final bool playAdhan;
  final bool stickyNotification;
  final String adhanSound;
  final bool quranReadAsText;
  final bool fastingRemindersEnabled;
  final bool whiteDaysReminderEnabled;
  final bool mondayThursdayReminderEnabled;

  const SettingsState({
    required this.langCode,
    required this.prayerOffset,
    required this.playAdhan,
    required this.stickyNotification,
    required this.adhanSound,
    required this.quranReadAsText,
    required this.fastingRemindersEnabled,
    required this.whiteDaysReminderEnabled,
    required this.mondayThursdayReminderEnabled,
  });

  SettingsState copyWith({
    String? langCode,
    int? prayerOffset,
    bool? playAdhan,
    bool? stickyNotification,
    String? adhanSound,
    bool? quranReadAsText,
    bool? fastingRemindersEnabled,
    bool? whiteDaysReminderEnabled,
    bool? mondayThursdayReminderEnabled,
  }) {
    return SettingsState(
      langCode: langCode ?? this.langCode,
      prayerOffset: prayerOffset ?? this.prayerOffset,
      playAdhan: playAdhan ?? this.playAdhan,
      stickyNotification: stickyNotification ?? this.stickyNotification,
      adhanSound: adhanSound ?? this.adhanSound,
      quranReadAsText: quranReadAsText ?? this.quranReadAsText,
      fastingRemindersEnabled:
          fastingRemindersEnabled ?? this.fastingRemindersEnabled,
      whiteDaysReminderEnabled:
          whiteDaysReminderEnabled ?? this.whiteDaysReminderEnabled,
      mondayThursdayReminderEnabled:
          mondayThursdayReminderEnabled ?? this.mondayThursdayReminderEnabled,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._storageService, this._notificationService)
    : super(
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

  void changeLanguage(String code) {
    if (code == state.langCode) return;
    _storageService.setLanguage(code);
    AppLocalizations.currentLang = code;
    emit(state.copyWith(langCode: code));
  }

  void setPrayerOffset(int offset) {
    if (offset == state.prayerOffset) return;
    _storageService.setPrayerOffset(offset);
    emit(state.copyWith(prayerOffset: offset));
  }

  void setPlayAdhan(bool play) {
    if (play == state.playAdhan) return;
    _storageService.setPlayAdhan(play);
    emit(state.copyWith(playAdhan: play));
  }

  void setStickyNotification(bool sticky) {
    if (sticky == state.stickyNotification) return;
    _storageService.setStickyNotification(sticky);
    emit(state.copyWith(stickyNotification: sticky));

    if (!sticky) {
      _notificationService.removePersistentNotification();
    }
  }

  void setAdhanSound(String soundKey) {
    if (soundKey == state.adhanSound) return;
    _storageService.setAdhanSound(soundKey);
    emit(state.copyWith(adhanSound: soundKey));
  }

  void setQuranReadAsText(bool readAsText) {
    if (readAsText == state.quranReadAsText) return;
    _storageService.setQuranReadAsText(readAsText);
    emit(state.copyWith(quranReadAsText: readAsText));
  }

  Future<void> setFastingRemindersEnabled(bool enabled) async {
    if (enabled == state.fastingRemindersEnabled) return;
    await _storageService.setFastingRemindersEnabled(enabled);
    emit(state.copyWith(fastingRemindersEnabled: enabled));
  }

  Future<void> setWhiteDaysReminderEnabled(bool enabled) async {
    if (enabled == state.whiteDaysReminderEnabled) return;
    await _storageService.setWhiteDaysReminderEnabled(enabled);
    emit(state.copyWith(whiteDaysReminderEnabled: enabled));
  }

  Future<void> setMondayThursdayReminderEnabled(bool enabled) async {
    if (enabled == state.mondayThursdayReminderEnabled) return;
    await _storageService.setMondayThursdayReminderEnabled(enabled);
    emit(state.copyWith(mondayThursdayReminderEnabled: enabled));
  }
}
