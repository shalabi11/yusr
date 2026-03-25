import '../models/reminder_model.dart';
import '../../../../core/services/storage_service.dart';
import '../datasources/dummy_reminders.dart';

class RemindersRepository {
  static const String _remindersKey = 'reminders_data';

  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final List<Map<String, dynamic>> jsonList = reminders
        .map((r) => r.toJson())
        .toList();
    await StorageService.saveData(_remindersKey, jsonList);
  }

  List<ReminderModel> getReminders() {
    final dynamic data = StorageService.getData(_remindersKey);
    if (data == null) {
      // First time user, save and fallback to dummy
      final initialReminders = getDummyReminders();
      saveReminders(initialReminders);
      return initialReminders;
    }

    final List<dynamic> jsonList = data as List<dynamic>;
    return jsonList
        .map((json) => ReminderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReminderModel>> addOrUpdateByTitle(ReminderModel reminder) async {
    final reminders = getReminders();
    final index = reminders.indexWhere((r) => r.titleKey == reminder.titleKey);

    if (index >= 0) {
      reminders[index] = reminder;
    } else {
      final maxId = reminders
          .map((r) => int.tryParse(r.id) ?? 0)
          .fold<int>(0, (a, b) => a > b ? a : b);
      reminders.add(
        ReminderModel(
          id: '${maxId + 1}',
          titleKey: reminder.titleKey,
          subtitleKey: reminder.subtitleKey,
          hour: reminder.hour,
          minute: reminder.minute,
          enabled: reminder.enabled,
          iconCodeInfo: reminder.iconCodeInfo,
        ),
      );
    }

    await saveReminders(reminders);
    return reminders;
  }
}
