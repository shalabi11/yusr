part of 'reminders_screen.dart';

extension RemindersScreenActions on _RemindersScreenState {
  Future<void> loadAndSyncOnStart() async {
    final loaded = await _repository.loadRemindersOnStartup();
    _applyLoadedReminders(loaded);

    await NotificationService.syncReminders(reminders);
  }

  Future<void> saveAndSyncData() async {
    await _repository.saveReminders(reminders);
    await NotificationService.syncReminders(reminders);
  }

  Future<void> showSwipeHintIfNeeded() async {
    if (StorageService.remindersSwipeHintSeen || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('طريقة الحذف'),
          content: const Text('لحذف التذكير اسحب البطاقة لليسار.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('حسنًا'),
            ),
          ],
        );
      },
    );

    await StorageService.setRemindersSwipeHintSeen(true);
  }

  Future<void> deleteReminderBySwipe(ReminderModel reminder) async {
    final notificationId = int.tryParse(reminder.id);
    if (notificationId != null) {
      await NotificationService.cancelNotification(notificationId);
    }

    _removeReminderById(reminder.id);
    await saveAndSyncData();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف التذكير')));
  }
}
