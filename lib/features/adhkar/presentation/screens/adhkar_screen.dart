import 'package:flutter/material.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/adhkar/data/models/adhkar_models.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_repository.dart';
import 'package:yusr_app/features/adhkar/presentation/widgets/adhkar_category_card.dart';
import 'package:yusr_app/features/reminders/data/models/reminder_model.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  final AdhkarRepository _repo = AdhkarRepository();
  final RemindersRepository _remindersRepo = RemindersRepository();
  bool _loading = true;
  List<AdhkarCategory> _categories = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.loadCategories();
    setState(() {
      _categories = data;
      _loading = false;
    });
  }

  Future<void> _addCategoryReminder(AdhkarCategory category) async {
    final reminder = ReminderModel(
      id: '0',
      titleKey: category.category,
      subtitleKey: 'يوميًا',
      hour: 7,
      minute: 0,
      enabled: true,
      iconCodeInfo: Icons.auto_awesome.codePoint,
    );

    final reminders = await _remindersRepo.addOrUpdateByTitle(reminder);
    await NotificationService.syncReminders(reminders);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة ${category.category} إلى التذكيرات')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('الأذكار'),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: AppRadialBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return AdhkarCategoryCard(
                    category: category,
                    onAddReminder: () => _addCategoryReminder(category),
                  );
                },
              ),
      ),
    );
  }
}
