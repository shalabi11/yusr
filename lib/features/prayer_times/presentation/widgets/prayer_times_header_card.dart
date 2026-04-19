import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';

class PrayerTimesHeaderCard extends StatelessWidget {
  const PrayerTimesHeaderCard({
    required this.locationName,
    required this.lastUpdatedAt,
    required this.hijriDate,
    required this.isFromCache,
    super.key,
  });

  final String locationName;
  final DateTime lastUpdatedAt;
  final String hijriDate;
  final bool isFromCache;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationName,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.lastUpdated.tr}: ${DateFormat('hh:mm a').format(lastUpdatedAt)}',
            style: TextStyle(
              color: AppColors.textWhite.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'التاريخ الهجري: $hijriDate',
            style: TextStyle(
              color: AppColors.textWhite.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isFromCache) ...[
            const SizedBox(height: 6),
            Text(
              AppStrings.offlineMode.tr,
              style: TextStyle(
                color: AppColors.accent.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
