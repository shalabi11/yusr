import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_schedule_helper.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class PrayerCountdownText extends StatefulWidget {
  const PrayerCountdownText({
    super.key,
    this.style,
    this.placeholder = '--:--:--',
  });

  final TextStyle? style;
  final String placeholder;

  @override
  State<PrayerCountdownText> createState() => _PrayerCountdownTextState();
}

class _PrayerCountdownTextState extends State<PrayerCountdownText> {
  Timer? _ticker;
  String _countdown = '--:--:--';

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = context.read<PrayerTimesCubit>().state;
      if (state is! PrayerTimesLoaded) {
        if (_countdown != widget.placeholder && mounted) {
          setState(() => _countdown = widget.placeholder);
        }
        return;
      }

      final next = PrayerScheduleHelper.computeNextPrayer(state.prayerTimes);
      final value = PrayerScheduleHelper.formatCountdown(next.remaining);
      if (value != _countdown && mounted) {
        setState(() => _countdown = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      buildWhen: (previous, current) =>
          current is PrayerTimesLoaded || current is PrayerTimesLoading,
      builder: (context, state) {
        final displayValue =
            (state is PrayerTimesLoaded && _countdown == widget.placeholder)
            ? PrayerScheduleHelper.formatCountdown(
                PrayerScheduleHelper.computeNextPrayer(
                  state.prayerTimes,
                ).remaining,
              )
            : _countdown;

        return Text(
          displayValue,
          style:
              widget.style ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
        );
      },
    );
  }
}
