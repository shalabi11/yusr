part of 'storage_sevice_impl.dart';

mixin StoragePrayerDelegates {
  StoragePrayerModule get _prayer;
  StorageQuranModule get _quran;

  int get prayerOffset => _prayer.prayerOffset;

  Future<void> setPrayerOffset(int offset) => _prayer.setPrayerOffset(offset);

  bool get playAdhan => _prayer.playAdhan;

  Future<void> setPlayAdhan(bool play) => _prayer.setPlayAdhan(play);

  bool get stickyNotification => _prayer.stickyNotification;

  Future<void> setStickyNotification(bool sticky) =>
      _prayer.setStickyNotification(sticky);

  String get adhanSound => _prayer.adhanSound;

  Future<void> setAdhanSound(String soundKey) =>
      _prayer.setAdhanSound(soundKey);

  bool get lastThirdNightReminderEnabled =>
      _prayer.lastThirdNightReminderEnabled;

  Future<void> setLastThirdNightReminderEnabled(bool enabled) =>
      _prayer.setLastThirdNightReminderEnabled(enabled);

  bool get sunnahPrayerRemindersEnabled => _prayer.sunnahPrayerRemindersEnabled;

  Future<void> setSunnahPrayerRemindersEnabled(bool enabled) =>
      _prayer.setSunnahPrayerRemindersEnabled(enabled);

  bool get quranReadAsText => _quran.quranReadAsText;

  Future<void> setQuranReadAsText(bool readAsText) =>
      _quran.setQuranReadAsText(readAsText);
}
