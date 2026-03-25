import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.greeting.tr,
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 5),
            Text(
              AppStrings.welcomeBack.tr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/settings'); // 🚀 Fixed to transition properly to settings view!
          },
          borderRadius: BorderRadius.circular(12),
          child: const GlassContainer(
            padding: EdgeInsets.all(12),
            borderRadius: 12,
            child: Icon(Icons.settings, color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}
