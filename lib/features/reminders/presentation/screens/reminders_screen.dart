import 'package:flutter/material.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/utils/time_picker_util.dart';
import 'package:yusr_app/features/adhkar/data/models/adhkar_models.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_repository.dart';
import 'package:yusr_app/features/reminders/data/models/reminder_model.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
import 'package:yusr_app/features/reminders/presentation/widgets/reminders_list_view.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/injection_container.dart';

part 'reminders_screen_actions.dart';
part 'reminders_screen_add_dialog.dart';
part 'reminders_screen_add_dialog_sheet.dart';
part 'reminders_screen_state_helpers.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with RemindersScreenStateHelpers {
  final RemindersRepository _repository = sl<RemindersRepository>();
  final AdhkarRepository _adhkarRepository = sl<AdhkarRepository>();
  late List<ReminderModel> reminders;

  @override
  void initState() {
    super.initState();
    reminders = _repository.getReminders();
    loadAndSyncOnStart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSwipeHintIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppStrings.remindersTitle.tr,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: AppRadialBackground(
        child: RemindersListView(
          reminders: reminders,
          onRefresh: loadAndSyncOnStart,
          onConfirmDelete: confirmDeleteReminder,
          onDelete: deleteReminderBySwipe,
          onToggle: (reminder, enabled) async {
            _updateReminderEnabled(reminder, enabled);
            await saveAndSyncData();
          },
          onTimeChanged: (reminder, newTime) async {
            _updateReminderTime(reminder, newTime);
            await saveAndSyncData();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddReminderDialog,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryDark,
        child: const Icon(Icons.add),
      ),
    );
  }
}
