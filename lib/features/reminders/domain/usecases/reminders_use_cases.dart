import 'package:yusr_app/features/reminders/data/models/reminder_model.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';

class RemindersUseCases {
  const RemindersUseCases(this._repository);

  final RemindersRepository _repository;

  List<ReminderModel> getReminders() {
    return _repository.getReminders();
  }

  Future<List<ReminderModel>> loadRemindersOnStartup() {
    return _repository.loadRemindersOnStartup();
  }

  Future<void> saveReminders(List<ReminderModel> reminders) {
    return _repository.saveReminders(reminders);
  }

  Future<List<ReminderModel>> addOrUpdateByTitle(ReminderModel reminder) {
    return _repository.addOrUpdateByTitle(reminder);
  }
}
