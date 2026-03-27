import 'package:flutter/material.dart';
import 'package:yusr_app/core/utils/time_picker_util.dart';
import 'package:yusr_app/features/reminders/data/models/reminder_model.dart';
import 'package:yusr_app/features/reminders/presentation/widgets/reminder_card.dart';

class RemindersListView extends StatelessWidget {
  const RemindersListView({
    required this.reminders,
    required this.onDelete,
    required this.onToggle,
    required this.onTimeChanged,
    super.key,
  });

  final List<ReminderModel> reminders;
  final Future<void> Function(ReminderModel reminder) onDelete;
  final Future<void> Function(ReminderModel reminder, bool enabled) onToggle;
  final Future<void> Function(ReminderModel reminder, TimeOfDay time)
  onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Dismissible(
            key: ValueKey(reminder.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) {
              onDelete(reminder);
            },
            child: ReminderCard(
              reminder: reminder,
              onChanged: (val) async {
                await onToggle(reminder, val);
              },
              onEditTime: () {
                TimePickerUtil.showCupertinoTimePicker(
                  context: context,
                  initialTime: reminder.timeOfDay,
                  onTimeChanged: (newTime) {
                    onTimeChanged(reminder, newTime);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
