import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:yusr_app/features/prayer_times/presentation/widgets/manual_location_dialog.dart';
import 'package:yusr_app/features/prayer_times/presentation/widgets/prayer_times_loaded_view.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    final current = context.read<PrayerTimesCubit>().state;
    if (current is! PrayerTimesLoaded) {
      context.read<PrayerTimesCubit>().fetchPrayerTimes();
    }
  }

  Future<void> _refresh() async {
    await context.read<PrayerTimesCubit>().fetchPrayerTimes(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppStrings.prayerTimes.tr,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        actions: [
          IconButton(
            onPressed: () => showManualLocationDialog(
              context: context,
              cubit: context.read<PrayerTimesCubit>(),
            ),
            icon: const Icon(Icons.edit_location_alt, color: AppColors.accent),
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
          ),
        ],
      ),
      body: AppRadialBackground(
        child: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
          builder: (context, state) {
            if (state is PrayerTimesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }

            if (state is PrayerTimesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.accent,
                        size: 42,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: Text(AppStrings.refreshNow.tr),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is PrayerTimesLoaded) {
              return PrayerTimesLoadedView(state: state, onRefresh: _refresh);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
