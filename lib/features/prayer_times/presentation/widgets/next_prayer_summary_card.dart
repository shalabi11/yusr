import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/widgets/prayer_countdown_text.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'prayer_card_shell.dart';

class NextPrayerSummaryCard extends StatelessWidget {
  const NextPrayerSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      builder: (context, state) {
        if (state is! PrayerTimesLoaded) {
          return const SizedBox.shrink();
        }

        return PrayerCardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'الصلاة القادمة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getPrayerName(state.nextPrayerKey),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const PrayerCountdownText(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPrayerName(String key) {
    switch (key.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return 'الصلاة';
    }
  }
}
