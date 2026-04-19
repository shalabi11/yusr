import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';

import '../support/fake_notification_service.dart';
import '../support/fake_storage_service.dart';

void main() {
  group('SettingsCubit', () {
    test('updates language and prayer preferences immutably', () async {
      final storage = FakeStorageService();
      final notifications = FakeNotificationService();
      final cubit = SettingsCubit(storage, notifications);

      cubit.changeLanguage('en');
      cubit.setPrayerOffset(10);
      cubit.setPlayAdhan(false);
      cubit.setStickyNotification(false);

      expect(cubit.state.langCode, 'en');
      expect(cubit.state.prayerOffset, 10);
      expect(cubit.state.playAdhan, isFalse);
      expect(cubit.state.stickyNotification, isFalse);
      expect(storage.language, 'en');
      expect(storage.prayerOffset, 10);
      expect(storage.playAdhan, isFalse);
      expect(storage.stickyNotification, isFalse);
      expect(notifications.persistentRemoveCalls, 1);

      await cubit.close();
    });

    test('updates fasting toggles and keeps state synchronized', () async {
      final storage = FakeStorageService();
      final notifications = FakeNotificationService();
      final cubit = SettingsCubit(storage, notifications);

      await cubit.setFastingRemindersEnabled(false);
      await cubit.setWhiteDaysReminderEnabled(false);
      await cubit.setMondayThursdayReminderEnabled(false);

      expect(cubit.state.fastingRemindersEnabled, isFalse);
      expect(cubit.state.whiteDaysReminderEnabled, isFalse);
      expect(cubit.state.mondayThursdayReminderEnabled, isFalse);
      expect(storage.fastingRemindersEnabled, isFalse);
      expect(storage.whiteDaysReminderEnabled, isFalse);
      expect(storage.mondayThursdayReminderEnabled, isFalse);

      await cubit.close();
    });
  });
}
