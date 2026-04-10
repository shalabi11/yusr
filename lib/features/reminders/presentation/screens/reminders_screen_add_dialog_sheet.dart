part of 'reminders_screen.dart';

Widget buildAddReminderBottomSheet({
  required BuildContext context,
  required List<AdhkarCategory> categories,
  required AdhkarCategory selectedCategory,
  required String frequency,
  required TimeOfDay selectedTime,
  required ValueChanged<AdhkarCategory> onCategoryChanged,
  required ValueChanged<String> onFrequencyChanged,
  required ValueChanged<TimeOfDay> onTimeChanged,
  required Future<void> Function() onSave,
}) {
  return Padding(
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
    ),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'إضافة تذكير',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          DropdownMenu<AdhkarCategory>(
            initialSelection: selectedCategory,
            width: double.infinity,
            label: const Text('اختر تصنيف الذكر'),
            dropdownMenuEntries: categories
                .map(
                  (c) => DropdownMenuEntry<AdhkarCategory>(
                    value: c,
                    label: c.category,
                  ),
                )
                .toList(),
            onSelected: (value) {
              if (value == null) return;
              onCategoryChanged(value);
            },
          ),
          const SizedBox(height: 10),
          DropdownMenu<String>(
            initialSelection: frequency,
            width: double.infinity,
            label: const Text('تكرار التذكير'),
            dropdownMenuEntries: const [
              DropdownMenuEntry<String>(
                value: AppStrings.daily,
                label: 'يوميًا',
              ),
              DropdownMenuEntry<String>(
                value: AppStrings.weeklyFriday,
                label: 'أسبوعيًا - يوم الجمعة',
              ),
            ],
            onSelected: (value) {
              if (value == null) return;
              onFrequencyChanged(value);
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              TimePickerUtil.showCupertinoTimePicker(
                context: context,
                initialTime: selectedTime,
                onTimeChanged: onTimeChanged,
              );
            },
            icon: const Icon(Icons.schedule),
            label: Text(
              'الوقت: ${MaterialLocalizations.of(context).formatTimeOfDay(selectedTime)}',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.check),
            label: const Text('حفظ التذكير'),
          ),
        ],
      ),
    ),
  );
}
