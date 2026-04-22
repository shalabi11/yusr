import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_countdown_service.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class PrayerCountdownText extends StatelessWidget {
  const PrayerCountdownText({
    super.key,
    this.style,
    this.placeholder = '--:--',
  });

  final TextStyle? style;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    PrayerCountdownService? countdownService;
    try {
      countdownService = RepositoryProvider.of<PrayerCountdownService>(context);
    } catch (_) {
      countdownService = null;
    }

    if (countdownService == null) {
      return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
        buildWhen: (previous, current) =>
            current is PrayerTimesLoaded || current is PrayerTimesLoading,
        builder: (context, state) {
          final displayValue = state is PrayerTimesLoaded
              ? state.countdownText
              : placeholder;

          return Text(displayValue, style: _effectiveStyle);
        },
      );
    }

    return StreamBuilder<PrayerCountdownTick>(
      stream: countdownService.stream,
      initialData: countdownService.current,
      builder: (context, snapshot) {
        final displayValue = snapshot.data?.countdownText ?? placeholder;
        return Text(displayValue, style: _effectiveStyle);
      },
    );
  }

  TextStyle get _effectiveStyle {
    return style ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        );
  }
}
