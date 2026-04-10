import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../prayer_times/data/models/prayer_time_model.dart';
import '../../../prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../../prayer_times/domain/prayer_schedule_helper.dart';
import 'next_prayer_card_sections.dart';

class NextPrayerCard extends StatefulWidget {
  const NextPrayerCard({super.key});

  @override
  NextPrayerCardState createState() => NextPrayerCardState();
}

class NextPrayerCardState extends State<NextPrayerCard> {
  Timer? _timer;
  String _nextPrayerName = 'جاري الحساب...';
  IconData _nextPrayerIcon = Icons.access_time;

  @override
  void initState() {
    super.initState();
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
    if (!mounted) return;
    setState(() {
      _nextPrayerName = next.slot.key.tr;
      _nextPrayerIcon = next.slot.icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      buildWhen: (previous, current) {
        return current is PrayerTimesLoaded ||
            current is PrayerTimesLoading ||
            current is PrayerTimesError;
      },
      builder: (context, state) {
        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NextPrayerLeftSection(
                icon: _nextPrayerIcon,
                name: _nextPrayerName,
              ),
              NextPrayerRightSection(state: state),
            ],
          ),
        );
      },
    );
  }
}
