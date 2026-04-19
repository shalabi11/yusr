import 'package:flutter/material.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/core/widgets/prayer_countdown_text.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_schedule_models.dart';

class NextPrayerSummaryCard extends StatelessWidget {
  const NextPrayerSummaryCard({required this.next, super.key});

  final NextPrayerInfo next;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Row(
        children: [
          Icon(next.slot.icon, color: AppColors.accent, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.nextPrayer.tr,
                  style: TextStyle(
                    color: AppColors.textWhite.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next.slot.key.tr,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const PrayerCountdownText(
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
