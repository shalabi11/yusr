part of 'reminders_screen.dart';

mixin RemindersScreenStateHelpers on State<RemindersScreen> {
  List<ReminderModel> get reminders;
  set reminders(List<ReminderModel> value);

  void _applyLoadedReminders(List<ReminderModel> loaded) {
    if (!mounted) return;
    setState(() {
      reminders = loaded
        ..sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
        );
    });
  }

  void _removeReminderById(String id) {
    if (!mounted) return;
    setState(() {
      reminders = reminders.where((r) => r.id != id).toList();
    });
  }

  void _replaceReminders(List<ReminderModel> updated) {
    if (!mounted) return;
    setState(() {
      reminders = updated
        ..sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
        );
    });
  }

  void _updateReminderEnabled(ReminderModel reminder, bool enabled) {
    if (!mounted) return;
    setState(() {
      reminders = reminders
          .map(
            (item) =>
                item.id == reminder.id ? item.copyWith(enabled: enabled) : item,
          )
          .toList();
    });
  }

  void _updateReminderTime(ReminderModel reminder, TimeOfDay newTime) {
    if (!mounted) return;
    setState(() {
      reminders = reminders
          .map(
            (item) => item.id == reminder.id
                ? item.copyWith(hour: newTime.hour, minute: newTime.minute)
                : item,
          )
          .toList();
    });
  }
}
