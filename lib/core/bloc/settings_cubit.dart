import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';
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
  SettingsCubit()
    : super(
        SettingsState(
          langCode: StorageService.language,
          prayerOffset: StorageService.prayerOffset,
          playAdhan: StorageService.playAdhan,
          stickyNotification: StorageService.stickyNotification,
          adhanSound: StorageService.adhanSound,
          quranReadAsText: StorageService.quranReadAsText,
          fastingRemindersEnabled: StorageService.fastingRemindersEnabled,
          whiteDaysReminderEnabled: StorageService.whiteDaysReminderEnabled,
          mondayThursdayReminderEnabled:
              StorageService.mondayThursdayReminderEnabled,
        ),
      ) {
    // Sync current lang on boot
    AppLocalizations.currentLang = state.langCode;
  }

  void changeLanguage(String code) {
    if (code == state.langCode) return;
    StorageService.setLanguage(code);
    AppLocalizations.currentLang = code;
    emit(state.copyWith(langCode: code));
  }

  void setPrayerOffset(int offset) {
    if (offset == state.prayerOffset) return;
    StorageService.setPrayerOffset(offset);
    emit(state.copyWith(prayerOffset: offset));
  }

  void setPlayAdhan(bool play) {
    if (play == state.playAdhan) return;
    StorageService.setPlayAdhan(play);
    emit(state.copyWith(playAdhan: play));
  }

  void setStickyNotification(bool sticky) {
    if (sticky == state.stickyNotification) return;
    StorageService.setStickyNotification(sticky);
    emit(state.copyWith(stickyNotification: sticky));

    if (!sticky) {
      NotificationService.removePersistentNotification();
    }
  }

  void setAdhanSound(String soundKey) {
    if (soundKey == state.adhanSound) return;
    StorageService.setAdhanSound(soundKey);
    emit(state.copyWith(adhanSound: soundKey));
  }

  void setQuranReadAsText(bool readAsText) {
    if (readAsText == state.quranReadAsText) return;
    StorageService.setQuranReadAsText(readAsText);
    emit(state.copyWith(quranReadAsText: readAsText));
  }

  Future<void> setFastingRemindersEnabled(bool enabled) async {
    if (enabled == state.fastingRemindersEnabled) return;
    await StorageService.setFastingRemindersEnabled(enabled);
    emit(state.copyWith(fastingRemindersEnabled: enabled));
  }

  Future<void> setWhiteDaysReminderEnabled(bool enabled) async {
    if (enabled == state.whiteDaysReminderEnabled) return;
    await StorageService.setWhiteDaysReminderEnabled(enabled);
    emit(state.copyWith(whiteDaysReminderEnabled: enabled));
  }

  Future<void> setMondayThursdayReminderEnabled(bool enabled) async {
    if (enabled == state.mondayThursdayReminderEnabled) return;
    await StorageService.setMondayThursdayReminderEnabled(enabled);
    emit(state.copyWith(mondayThursdayReminderEnabled: enabled));
  }
}
