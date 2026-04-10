import 'package:flutter/material.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/prayer_countdown_text.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class NextPrayerLeftSection extends StatelessWidget {
  const NextPrayerLeftSection({
    required this.icon,
    required this.name,
    super.key,
  });

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 35),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الصلاة القادمة'.tr,
              style: TextStyle(
                color: AppColors.textWhite.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NextPrayerRightSection extends StatelessWidget {
  const NextPrayerRightSection({required this.state, super.key});

  final PrayerTimesState state;

  @override
  Widget build(BuildContext context) {
    final loaded = state is PrayerTimesLoaded
        ? state as PrayerTimesLoaded
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (state is PrayerTimesLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2,
            ),
          )
        else ...[
          const PrayerCountdownText(
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          if (loaded != null)
            Text(
              loaded.locationName,
              style: TextStyle(
                color: AppColors.textWhite.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
        ],
      ],
    );
  }
}
