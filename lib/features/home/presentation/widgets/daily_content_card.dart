import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/features/home/data/daily_ayah_repository.dart';

class DailyContentCard extends StatelessWidget {
  const DailyContentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DailyAyahRepository();
    return GlassContainer(
      padding: const EdgeInsets.all(25),
      borderRadius: 24,
      color: AppColors.primary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: AppColors.accent),
              const SizedBox(width: 10),
              Text(
                AppStrings.ayahOfDay.tr,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<DailyAyah>(
            future: repo.getDailyAyah(),
            builder: (context, snapshot) {
              final ayah = snapshot.data;
              if (ayah == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              return Column(
                children: [
                  Text(
                    ayah.content,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.6,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ayah.source,
                      style: const TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
