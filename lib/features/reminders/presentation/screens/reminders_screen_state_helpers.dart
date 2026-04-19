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
      reminders.removeWhere((r) => r.id == id);
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
      reminder.enabled = enabled;
    });
  }

  void _updateReminderTime(ReminderModel reminder, TimeOfDay newTime) {
    if (!mounted) return;
    setState(() {
      reminder.hour = newTime.hour;
      reminder.minute = newTime.minute;
    });
  }
}
