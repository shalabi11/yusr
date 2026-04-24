// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../prayer_times/domain/entities/next_prayer_info.dart';
import '../../../prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../../prayer_times/presentation/widgets/next_prayer_summary_card.dart';
import '../../../prayer_times/presentation/widgets/prayer_card_shell.dart';

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PrayerTimesCubit, dynamic, NextPrayerInfo?>(
      selector: _selectNextPrayerInfo,
      builder: (context, nextPrayerInfo) {
        if (nextPrayerInfo == null) {
          return _buildLoadingCard(context);
        }

        return NextPrayerSummaryCard(nextPrayerInfo: nextPrayerInfo);
      },
    );
  }

  NextPrayerInfo? _selectNextPrayerInfo(dynamic state) {
    final candidates = <dynamic>[
      _tryRead(() => state.nextPrayerInfo),
      _tryRead(() => state.nextPrayer),
      _tryRead(() => state.currentPrayerInfo),
      _tryRead(() => state.currentPrayer),
      _tryRead(() => state.info),
      _tryRead(() => state.prayerInfo),
    ];

    for (final candidate in candidates) {
      if (candidate is NextPrayerInfo) {
        return candidate;
      }
    }

    return null;
  }

  T? _tryRead<T>(T Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);

    return PrayerCardShell(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الصلاة القادمة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}