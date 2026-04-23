import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_view_model.dart';
import 'package:yusr_app/features/prayer_times/presentation/widgets/manual_location_dialog.dart';
import 'package:yusr_app/features/prayer_times/presentation/widgets/prayer_times_loaded_view.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    await context.read<PrayerTimesCubit>().fetchPrayerTimes(force: true);
  }

  @override
  Widget build(BuildContext context) {
    // Trigger fetch if not loaded.
    final cubit = context.read<PrayerTimesCubit>();
    if (cubit.state is! PrayerTimesLoaded && cubit.state is! PrayerTimesLoading) {
      cubit.fetchPrayerTimes();
    }

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
            onPressed: () => _refresh(context),
            icon: const Icon(Icons.refresh, color: AppColors.accent),
          ),
        ],
      ),
      body: AppRadialBackground(
        child: BlocSelector<PrayerTimesCubit, PrayerTimesState, PrayerTimesViewModel>(
          selector: PrayerTimesViewModel.fromState,
          builder: (context, viewModel) {
            if (viewModel.type == PrayerTimesViewType.loading) {
              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                color: AppColors.accent,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 420,
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.type == PrayerTimesViewType.error) {
              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                color: AppColors.accent,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    SizedBox(
                      height: 420,
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
                            viewModel.errorMessage ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _refresh(context),
                            icon: const Icon(Icons.refresh),
                            label: Text(AppStrings.refreshNow.tr),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.type == PrayerTimesViewType.loaded && viewModel.loaded != null) {
              return PrayerTimesLoadedView(
                state: viewModel.loaded!,
                onRefresh: () => _refresh(context),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
