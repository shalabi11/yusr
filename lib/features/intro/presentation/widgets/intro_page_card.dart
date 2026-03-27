import 'package:flutter/material.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';

class IntroPageCard extends StatelessWidget {
  const IntroPageCard({
    required this.titleKey,
    required this.descKey,
    required this.iconName,
    super.key,
  });

  final String titleKey;
  final String descKey;
  final String iconName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(40),
            borderRadius: 100,
            child: Icon(_getIcon(iconName), size: 80, color: AppColors.accent),
          ),
          const SizedBox(height: 60),
          Text(
            titleKey.tr,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            descKey.tr,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'mosque':
        return Icons.mosque_outlined;
      case 'notifications':
        return Icons.notifications_active_outlined;
      case 'book':
        return Icons.menu_book_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
