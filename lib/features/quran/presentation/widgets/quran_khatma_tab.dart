import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';

class QuranKhatmaTab extends StatelessWidget {
  const QuranKhatmaTab({
    required this.lastRead,
    required this.daysController,
    required this.khatmaPlan,
    required this.onComputePlan,
    required this.onScheduleReminder,
    super.key,
  });

  final QuranLastRead? lastRead;
  final TextEditingController daysController;
  final KhatmaPlan? khatmaPlan;
  final VoidCallback onComputePlan;
  final VoidCallback onScheduleReminder;

  @override
  Widget build(BuildContext context) {
    final progressValue = ((lastRead?.pageNumber ?? 0) / 604)
        .clamp(0.0, 1.0)
        .toDouble();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'خطة الختمة',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تقدم الختمة',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progressValue,
                  backgroundColor: AppColors.textWhite.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'الصفحة الحالية: ${lastRead?.pageNumber ?? 0} من 604 (${(progressValue * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: AppColors.textWhite.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الأيام',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onComputePlan,
                child: const Text('احسب الخطة'),
              ),
              if (khatmaPlan != null) ...[
                const SizedBox(height: 12),
                Text(
                  'الورد اليومي: ${khatmaPlan!.pagesPerDay} صفحة',
                  style: const TextStyle(color: AppColors.textWhite),
                ),
                Text(
                  'تقريبًا: ${khatmaPlan!.juzPerDay} جزء يوميًا',
                  style: const TextStyle(color: AppColors.textWhite),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onScheduleReminder,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('جدولة تذكير يومي للختمة'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
