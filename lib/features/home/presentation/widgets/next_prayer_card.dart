import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../prayer_times/data/models/prayer_time_model.dart';
import '../../../prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../../prayer_times/domain/prayer_schedule_helper.dart';
import '../../../../core/localization/app_localizations.dart';

class NextPrayerCard extends StatefulWidget {
  const NextPrayerCard({super.key});

  @override
  NextPrayerCardState createState() => NextPrayerCardState();
}

class NextPrayerCardState extends State<NextPrayerCard> {
  Timer? _timer;
  String _countdownStr = '--:--:--';
  String _nextPrayerName = 'جاري الحساب...';
  IconData _nextPrayerIcon = Icons.access_time;

  @override
  void initState() {
    super.initState();
    context.read<PrayerTimesCubit>().fetchPrayerTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final state = context.read<PrayerTimesCubit>().state;
      if (state is PrayerTimesLoaded) {
        _updateNextPrayerDisplay(state.prayerTimes);
      }
    });
  }

  void _updateNextPrayerDisplay(PrayerTimeModel times) {
    final next = PrayerScheduleHelper.computeNextPrayer(times);

    if (mounted) {
      setState(() {
        _nextPrayerName = next.slot.key.tr;
        _nextPrayerIcon = next.slot.icon;
        _countdownStr = PrayerScheduleHelper.formatCountdown(next.remaining);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      builder: (context, state) {
        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_nextPrayerIcon, color: AppColors.accent, size: 35),
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
                        _nextPrayerName,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
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
                    Text(
                      _countdownStr,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (state is PrayerTimesLoaded)
                      Text(
                        state.locationName,
                        style: TextStyle(
                          color: AppColors.textWhite.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
