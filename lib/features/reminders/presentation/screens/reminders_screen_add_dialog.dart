part of 'reminders_screen.dart';

extension _RemindersAddDialog on _RemindersScreenState {
  Future<void> showAddReminderDialog() async {
    final categories = await _adhkarRepository.loadCategories();
    if (!mounted) return;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحميل بيانات الأذكار')),
      );
      return;
    }

    AdhkarCategory selectedCategory = categories.first;
    String frequency = AppStrings.daily;
    var selectedTime = const TimeOfDay(hour: 8, minute: 0);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return buildAddReminderBottomSheet(
              context: context,
              categories: categories,
              selectedCategory: selectedCategory,
              frequency: frequency,
              selectedTime: selectedTime,
              onCategoryChanged: (value) {
                setModalState(() => selectedCategory = value);
              },
              onFrequencyChanged: (value) {
                setModalState(() => frequency = value);
              },
              onTimeChanged: (value) {
                setModalState(() => selectedTime = value);
              },
              onSave: () async {
                final reminder = ReminderModel(
                  id: '0',
                  titleKey: selectedCategory.category,
                  subtitleKey: frequency,
                  hour: selectedTime.hour,
                  minute: selectedTime.minute,
                  enabled: true,
                  iconCodeInfo: Icons.auto_awesome.codePoint,
                );

                final updated = await _repository.addOrUpdateByTitle(reminder);
                if (!mounted) return;
                _replaceReminders(updated);
                await NotificationService.syncReminders(reminders);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
