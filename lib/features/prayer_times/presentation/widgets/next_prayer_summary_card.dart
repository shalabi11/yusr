// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';

import '../../../../core/widgets/prayer_countdown_text.dart';
import '../../domain/entities/next_prayer_info.dart';
import 'prayer_card_shell.dart';

class NextPrayerSummaryCard extends StatelessWidget {
  final NextPrayerInfo nextPrayerInfo;

  const NextPrayerSummaryCard({
    super.key,
    required this.nextPrayerInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prayerTitle = _resolvePrayerLabel(nextPrayerInfo);
    final prayerTime = _resolvePrayerTime(nextPrayerInfo);

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
              Text(
                'الصلاة القادمة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            prayerTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (prayerTime.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              prayerTime,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildCountdownText(nextPrayerInfo),
        ],
      ),
    );
  }

  Widget _buildCountdownText(NextPrayerInfo info) {
    final builders = <Widget Function()>[
      () => Function.apply(PrayerCountdownText.new, [info]) as Widget,
      () => Function.apply(
            PrayerCountdownText.new,
            const [],
            {#nextPrayerInfo: info},
          ) as Widget,
      () => Function.apply(
            PrayerCountdownText.new,
            const [],
            {#info: info},
          ) as Widget,
      () => Function.apply(
            PrayerCountdownText.new,
            const [],
            {#prayerInfo: info},
          ) as Widget,
      () => Function.apply(
            PrayerCountdownText.new,
            const [],
            {#data: info},
          ) as Widget,
    ];

    for (final builder in builders) {
      try {
        return builder();
      } catch (_) {}
    }

    return const SizedBox.shrink();
  }

  String _resolvePrayerLabel(NextPrayerInfo info) {
    final candidates = <String?>[
      _tryRead(() => (info as dynamic).prayerName?.toString()),
      _tryRead(() => (info as dynamic).name?.toString()),
      _tryRead(() => (info as dynamic).title?.toString()),
      _tryRead(() => (info as dynamic).displayName?.toString()),
      _tryRead(() => (info as dynamic).prayer?.toString()),
      _tryRead(() => (info as dynamic).formattedName?.toString()),
      _tryRead(() => (info as dynamic).nextPrayerName?.toString()),
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }

    return 'الصلاة القادمة';
  }

  String _resolvePrayerTime(NextPrayerInfo info) {
    final candidates = <String?>[
      _tryRead(() => (info as dynamic).prayerTime?.toString()),
      _tryRead(() => (info as dynamic).time?.toString()),
      _tryRead(() => (info as dynamic).formattedTime?.toString()),
      _tryRead(() => (info as dynamic).displayTime?.toString()),
      _tryRead(() => (info as dynamic).timeLabel?.toString()),
      _tryRead(() => (info as dynamic).formattedPrayerTime?.toString()),
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }

    return '';
  }

  T? _tryRead<T>(T Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }
}