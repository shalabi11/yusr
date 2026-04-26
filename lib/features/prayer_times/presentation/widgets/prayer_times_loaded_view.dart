import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/utils/hijri_utils.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_schedule_helper.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

import 'next_prayer_summary_card.dart';
import 'prayer_slot_tile.dart';
import 'prayer_times_header_card.dart';

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
          PrayerTimesHeaderCard(
            locationName: state.locationName,
            lastUpdatedAt: state.lastUpdatedAt,
            hijriDate: hijriDate.formattedAr,
            isFromCache: state.isFromCache,
          ),
          const SizedBox(height: 16),
          const NextPrayerSummaryCard(),
          const SizedBox(height: 16),
          ...prayers.map((slot) {
            final isNext = slot.id == next.slot.id;
            final timeLabel = DateFormat('hh:mm a').format(slot.time);
            return PrayerSlotTile(
              slot: slot,
              isNext: isNext,
              timeLabel: timeLabel,
            );
          }),
        ],
      ),
    );
  }
}
