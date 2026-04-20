class SettingsState {
  final String langCode;
  final int prayerOffset;
  final bool playAdhan;
  final bool stickyNotification;
  final String adhanSound;
  final bool lastThirdNightReminderEnabled;
  final bool sunnahPrayerRemindersEnabled;
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
    required this.lastThirdNightReminderEnabled,
    required this.sunnahPrayerRemindersEnabled,
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
    bool? lastThirdNightReminderEnabled,
    bool? sunnahPrayerRemindersEnabled,
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
      lastThirdNightReminderEnabled:
          lastThirdNightReminderEnabled ?? this.lastThirdNightReminderEnabled,
      sunnahPrayerRemindersEnabled:
          sunnahPrayerRemindersEnabled ?? this.sunnahPrayerRemindersEnabled,
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
