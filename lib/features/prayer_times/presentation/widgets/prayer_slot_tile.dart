import 'package:flutter/material.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_schedule_models.dart';

class PrayerSlotTile extends StatelessWidget {
  const PrayerSlotTile({
    required this.slot,
    required this.isNext,
    required this.timeLabel,
    super.key,
  });

  final PrayerSlot slot;
  final bool isNext;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: isNext
            ? AppColors.primary.withValues(alpha: 0.45)
            : const Color(0x1AFFFFFF),
        child: Row(
          children: [
            Icon(slot.icon, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                slot.key.tr,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              timeLabel,
              style: TextStyle(
                color: isNext ? AppColors.accent : AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
