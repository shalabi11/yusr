import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_countdown_service.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'next_prayer_card_sections.dart';

class _NextPrayerCardViewData {
  const _NextPrayerCardViewData({
    required this.fallbackName,
    required this.fallbackIcon,
    required this.isLoading,
    this.locationName,
  });

  final String fallbackName;
  final IconData fallbackIcon;
  final bool isLoading;
  final String? locationName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _NextPrayerCardViewData &&
        other.fallbackName == fallbackName &&
        other.fallbackIcon == fallbackIcon &&
        other.isLoading == isLoading &&
        other.locationName == locationName;
  }

  @override
  int get hashCode =>
      Object.hash(fallbackName, fallbackIcon, isLoading, locationName);
}

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      PrayerTimesCubit,
      PrayerTimesState,
      _NextPrayerCardViewData
    >(
      selector: (state) {
        final loaded = state is PrayerTimesLoaded ? state : null;
        return _NextPrayerCardViewData(
          fallbackName: loaded == null
              ? 'جاري الحساب...'
              : loaded.nextPrayerKey.tr,
          fallbackIcon: loaded?.nextPrayerIcon ?? Icons.access_time,
          isLoading: state is PrayerTimesLoading,
          locationName: loaded?.locationName,
        );
      },
      builder: (context, viewData) {
        PrayerCountdownService? countdownService;
        try {
          countdownService = RepositoryProvider.of<PrayerCountdownService>(
            context,
          );
        } catch (_) {
          countdownService = null;
        }

        final leftSection = countdownService == null
            ? NextPrayerLeftSection(
                icon: viewData.fallbackIcon,
                name: viewData.fallbackName,
              )
            : StreamBuilder<PrayerCountdownTick>(
                stream: countdownService.stream,
                initialData: countdownService.current,
                builder: (context, snapshot) {
                  final tick = snapshot.data;
                  return NextPrayerLeftSection(
                    icon: tick?.nextPrayerIcon ?? viewData.fallbackIcon,
                    name: tick == null
                        ? viewData.fallbackName
                        : tick.nextPrayerKey.tr,
                  );
                },
              );

        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leftSection,
              NextPrayerRightSection(
                isLoading: viewData.isLoading,
                locationName: viewData.locationName,
              ),
            ],
          ),
        );
      },
    );
  }
}
