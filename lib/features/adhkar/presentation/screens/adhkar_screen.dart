import 'package:flutter/material.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/adhkar/data/models/adhkar_models.dart';
import 'package:yusr_app/features/adhkar/domain/usecases/adhkar_use_cases.dart';
import 'package:yusr_app/features/adhkar/presentation/widgets/adhkar_category_card.dart';
import 'package:yusr_app/features/reminders/data/models/reminder_model.dart';
import 'package:yusr_app/features/reminders/domain/usecases/reminders_use_cases.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({
    required this.adhkarUseCases,
    required this.remindersUseCases,
    super.key,
  });

  final AdhkarUseCases adhkarUseCases;
  final RemindersUseCases remindersUseCases;

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late final AdhkarUseCases _adhkarUseCases;
  late final RemindersUseCases _remindersUseCases;
  bool _loading = true;
  List<AdhkarCategory> _categories = const [];

  @override
  void initState() {
    super.initState();
    _adhkarUseCases = widget.adhkarUseCases;
    _remindersUseCases = widget.remindersUseCases;
    _load();
  }

  Future<void> _load() async {
    final data = await _adhkarUseCases.loadCategories();
    if (!mounted) return;
    setState(() {
      _categories = data;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });
    await _load();
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

    final reminders = await _remindersUseCases.addOrUpdateByTitle(reminder);
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
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.accent,
          child: _loading
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height: 360,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}
