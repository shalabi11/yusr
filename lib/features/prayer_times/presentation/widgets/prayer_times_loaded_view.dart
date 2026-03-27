import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/utils/hijri_utils.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_schedule_helper.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class PrayerTimesLoadedView extends StatelessWidget {
  const PrayerTimesLoadedView({
    required this.state,
    required this.onRefresh,
    super.key,
  });

  final PrayerTimesLoaded state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijriDate = HijriUtils.fromGregorian(now);
    final next = PrayerScheduleHelper.computeNextPrayer(
      state.prayerTimes,
      reference: now,
    );
    final prayers = PrayerScheduleHelper.prayerSlots(state.prayerTimes, now);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accent,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassContainer(
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
                        state.locationName,
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
                  '${AppStrings.lastUpdated.tr}: ${DateFormat('hh:mm a').format(state.lastUpdatedAt)}',
                  style: TextStyle(
                    color: AppColors.textWhite.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'التاريخ الهجري: ${hijriDate.formattedAr}',
                  style: TextStyle(
                    color: AppColors.textWhite.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (state.isFromCache) ...[
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
          ),
          const SizedBox(height: 16),
          GlassContainer(
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
                Text(
                  PrayerScheduleHelper.formatCountdown(next.remaining),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...prayers.map((slot) {
            final isNext = slot.id == next.slot.id;
            final timeLabel = DateFormat('hh:mm a').format(slot.time);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
          }),
        ],
      ),
    );
  }
}
