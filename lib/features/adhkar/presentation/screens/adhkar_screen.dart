import 'package:flutter/material.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/adhkar/data/models/adhkar_models.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_repository.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [AppColors.primaryDark, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(12),
                        child: ExpansionTile(
                          collapsedIconColor: AppColors.accent,
                          iconColor: AppColors.accent,
                          title: Text(
                            category.category,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${category.items.length} ذكر',
                            style: TextStyle(
                              color: AppColors.textWhite.withValues(alpha: 0.7),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => _addCategoryReminder(category),
                            icon: const Icon(Icons.notifications_active),
                            color: AppColors.accent,
                            tooltip: 'إضافة كتذكير',
                          ),
                          children: category.items.take(8).map((item) {
                            return ListTile(
                              title: Text(
                                item.text,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  height: 1.6,
                                ),
                              ),
                              subtitle: Text(
                                'عدد التكرار: ${item.count}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: AppColors.textWhite.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
