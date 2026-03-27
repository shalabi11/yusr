import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/adhkar/data/models/adhkar_models.dart';

class AdhkarCategoryCard extends StatelessWidget {
  const AdhkarCategoryCard({
    required this.category,
    required this.onAddReminder,
    super.key,
  });

  final AdhkarCategory category;
  final VoidCallback onAddReminder;

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.7)),
          ),
          trailing: IconButton(
            onPressed: onAddReminder,
            icon: const Icon(Icons.notifications_active),
            color: AppColors.accent,
            tooltip: 'إضافة كتذكير',
          ),
          children: category.items.take(8).map((item) {
            return ListTile(
              title: Text(
                item.text,
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.textWhite, height: 1.6),
              ),
              subtitle: Text(
                'عدد التكرار: ${item.count}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
