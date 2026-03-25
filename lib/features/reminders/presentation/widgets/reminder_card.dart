import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import '../../data/models/reminder_model.dart';
import '../../../../core/localization/app_localizations.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEditTime;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onChanged,
    required this.onEditTime,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic system locale formatting of TimeOfDay correctly AM/PM based!
    final String displayTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(reminder.timeOfDay);

    return InkWell(
      onTap: onEditTime,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        color: reminder.enabled
            ? AppColors.primaryDark.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                reminder.icon,
                color: reminder.enabled
                    ? AppColors.accent
                    : AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.titleKey.tr, // Auto translate Title!
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: reminder.enabled
                          ? AppColors.textWhite
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '${reminder.subtitleKey.tr} • $displayTime', // Safe automatic String formatting
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(
                            alpha: reminder.enabled ? 1.0 : 0.5,
                          ),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.accent.withValues(
                          alpha: reminder.enabled ? 1.0 : 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: reminder.enabled,
              onChanged: onChanged,
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.textSecondary,
              inactiveTrackColor: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
