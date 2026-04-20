import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:yusr_app/features/prayer_times/presentation/widgets/manual_location_dialog.dart';
import 'package:yusr_app/features/prayer_times/presentation/widgets/prayer_times_loaded_view.dart';

enum _PrayerTimesViewType { loading, error, loaded, empty }

class _PrayerTimesViewModel {
  const _PrayerTimesViewModel({
    required this.type,
    this.loaded,
    this.errorMessage,
  });

  final _PrayerTimesViewType type;
  final PrayerTimesLoaded? loaded;
  final String? errorMessage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _PrayerTimesViewModel &&
        other.type == type &&
        other.loaded == loaded &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(type, loaded, errorMessage);
}

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

  _PrayerTimesViewModel _toViewModel(PrayerTimesState state) {
    if (state is PrayerTimesLoading) {
      return const _PrayerTimesViewModel(type: _PrayerTimesViewType.loading);
    }
    if (state is PrayerTimesError) {
      return _PrayerTimesViewModel(
        type: _PrayerTimesViewType.error,
        errorMessage: state.message,
      );
    }
    if (state is PrayerTimesLoaded) {
      return _PrayerTimesViewModel(
        type: _PrayerTimesViewType.loaded,
        loaded: state,
      );
    }
    return const _PrayerTimesViewModel(type: _PrayerTimesViewType.empty);
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
        child:
            BlocSelector<
              PrayerTimesCubit,
              PrayerTimesState,
              _PrayerTimesViewModel
            >(
              selector: _toViewModel,
              builder: (context, viewModel) {
                if (viewModel.type == _PrayerTimesViewType.loading) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.accent,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 420,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.type == _PrayerTimesViewType.error) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
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
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                ),
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
                      ],
                    ),
                  );
                }

                if (viewModel.type == _PrayerTimesViewType.loaded &&
                    viewModel.loaded != null) {
                  return PrayerTimesLoadedView(
                    state: viewModel.loaded!,
                    onRefresh: _refresh,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
      ),
    );
  }
}
