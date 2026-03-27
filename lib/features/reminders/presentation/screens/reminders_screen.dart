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

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final RemindersRepository _repository = RemindersRepository();
  final AdhkarRepository _adhkarRepository = AdhkarRepository();
  late List<ReminderModel> reminders;

  Future<void> _showAddReminderDialog() async {
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
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
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
                        setModalState(() => selectedCategory = value);
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
                        setModalState(() => frequency = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        TimePickerUtil.showCupertinoTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          onTimeChanged: (newTime) {
                            setModalState(() => selectedTime = newTime);
                          },
                        );
                      },
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        'الوقت: ${MaterialLocalizations.of(context).formatTimeOfDay(selectedTime)}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final reminder = ReminderModel(
                          id: '0',
                          titleKey: selectedCategory.category,
                          subtitleKey: frequency,
                          hour: selectedTime.hour,
                          minute: selectedTime.minute,
                          enabled: true,
                          iconCodeInfo: Icons.auto_awesome.codePoint,
                        );

                        final updated = await _repository.addOrUpdateByTitle(
                          reminder,
                        );

                        if (!mounted) return;
                        setState(() {
                          reminders = updated
                            ..sort(
                              (a, b) => (a.hour * 60 + a.minute).compareTo(
                                b.hour * 60 + b.minute,
                              ),
                            );
                        });
                        await NotificationService.syncReminders(reminders);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('حفظ التذكير'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    reminders = _repository.getReminders();
    _syncOnStart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSwipeHintIfNeeded();
    });
  }

  Future<void> _syncOnStart() async {
    await NotificationService.syncReminders(reminders);
  }

  Future<void> _saveAndSyncData() async {
    await _repository.saveReminders(reminders);
    await NotificationService.syncReminders(reminders);
  }

  Future<void> _showSwipeHintIfNeeded() async {
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

  Future<void> _deleteReminderBySwipe(ReminderModel reminder) async {
    final notificationId = int.tryParse(reminder.id);
    if (notificationId != null) {
      await NotificationService.cancelNotification(notificationId);
    }

    setState(() {
      reminders.removeWhere((r) => r.id == reminder.id);
    });
    await _saveAndSyncData();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف التذكير')));
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
          onDelete: _deleteReminderBySwipe,
          onToggle: (reminder, enabled) async {
            setState(() {
              reminder.enabled = enabled;
            });
            await _saveAndSyncData();
          },
          onTimeChanged: (reminder, newTime) async {
            setState(() {
              reminder.hour = newTime.hour;
              reminder.minute = newTime.minute;
            });
            await _saveAndSyncData();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryDark,
        child: const Icon(Icons.add),
      ),
    );
  }
}
