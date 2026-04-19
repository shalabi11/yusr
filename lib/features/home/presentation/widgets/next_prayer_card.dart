import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'next_prayer_card_sections.dart';

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      buildWhen: (previous, current) {
        return current is PrayerTimesLoaded ||
            current is PrayerTimesLoading ||
            current is PrayerTimesError;
      },
      builder: (context, state) {
        final loaded = state is PrayerTimesLoaded ? state : null;
        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NextPrayerLeftSection(
                icon: loaded?.nextPrayerIcon ?? Icons.access_time,
                name: loaded == null
                    ? 'جاري الحساب...'
                    : loaded.nextPrayerKey.tr,
              ),
              NextPrayerRightSection(state: state),
            ],
          ),
        );
      },
    );
  }
}
