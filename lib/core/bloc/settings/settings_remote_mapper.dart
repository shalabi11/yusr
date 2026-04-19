import 'package:yusr_app/core/services/notification_service.dart';

import 'settings_state.dart';

class SettingsRemoteMapper {
  static SettingsState fromRemote(
    Map<String, dynamic> data,
    SettingsState fallback,
  ) {
    final allowedLangs = {'ar', 'en'};
    final allowedOffsets = {0, 5, 10, 15};
    final allowedSounds = NotificationService.adhanSoundOptions.toSet();

    final langCode = (data['lang_code']?.toString() ?? fallback.langCode);
    final prayerOffset = _asInt(data['prayer_offset'], fallback.prayerOffset);
    final adhanSound = (data['adhan_sound']?.toString() ?? fallback.adhanSound);

    return SettingsState(
      langCode: allowedLangs.contains(langCode) ? langCode : fallback.langCode,
      prayerOffset: allowedOffsets.contains(prayerOffset)
          ? prayerOffset
          : fallback.prayerOffset,
      playAdhan: _asBool(data['play_adhan'], fallback.playAdhan),
      stickyNotification: _asBool(
        data['sticky_notification'],
        fallback.stickyNotification,
      ),
      adhanSound: allowedSounds.contains(adhanSound)
          ? adhanSound
          : fallback.adhanSound,
      quranReadAsText: _asBool(
        data['quran_read_as_text'],
        fallback.quranReadAsText,
      ),
      fastingRemindersEnabled: _asBool(
        data['fasting_reminders_enabled'],
        fallback.fastingRemindersEnabled,
      ),
      whiteDaysReminderEnabled: _asBool(
        data['white_days_reminder_enabled'],
        fallback.whiteDaysReminderEnabled,
      ),
      mondayThursdayReminderEnabled: _asBool(
        data['monday_thursday_reminder_enabled'],
        fallback.mondayThursdayReminderEnabled,
      ),
    );
  }

  static Map<String, dynamic> toRemote({
    required String userId,
    required SettingsState state,
  }) {
    return {
      'user_id': userId,
      'lang_code': state.langCode,
      'prayer_offset': state.prayerOffset,
      'play_adhan': state.playAdhan,
      'sticky_notification': state.stickyNotification,
      'adhan_sound': state.adhanSound,
      'quran_read_as_text': state.quranReadAsText,
      'fasting_reminders_enabled': state.fastingRemindersEnabled,
      'white_days_reminder_enabled': state.whiteDaysReminderEnabled,
      'monday_thursday_reminder_enabled': state.mondayThursdayReminderEnabled,
    };
  }

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _asBool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return fallback;
  }
}
