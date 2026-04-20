part of 'reminders_screen.dart';

extension _RemindersScreenActions on _RemindersScreenState {
  Future<void> loadAndSyncOnStart() async {
    final loaded = await _remindersUseCases.loadRemindersOnStartup();
    _applyLoadedReminders(loaded);

    await NotificationService.syncReminders(reminders);
  }

  Future<void> saveAndSyncData() async {
    await _remindersUseCases.saveReminders(reminders);
    await NotificationService.syncReminders(reminders);
  }

  Future<void> showSwipeHintIfNeeded() async {
    if (StorageService.remindersSwipeHintSeen || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.swipe_left_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'حذف سريع للتذكير',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'اسحب البطاقة نحو اليسار لإظهار الحذف، بعدها سيظهر تأكيد قبل الحذف النهائي.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryDark,
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('فهمت'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    await StorageService.setRemindersSwipeHintSeen(true);
  }

  Future<bool> confirmDeleteReminder(ReminderModel reminder) async {
    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: AppColors.accent.withValues(alpha: 0.35)),
          ),
          title: const Text(
            'تأكيد الحذف',
            style: TextStyle(color: AppColors.textWhite),
          ),
          content: Text(
            'هل تريد حذف "${reminder.titleKey.tr}"؟',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    return result == true;
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
