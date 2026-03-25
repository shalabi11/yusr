import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_schedule_helper.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    final current = context.read<PrayerTimesCubit>().state;
    if (current is! PrayerTimesLoaded) {
      context.read<PrayerTimesCubit>().fetchPrayerTimes();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<PrayerTimesCubit>().fetchPrayerTimes();
  }

  Future<void> _showManualLocationDialog() async {
    final controller = TextEditingController();
    final cubit = context.read<PrayerTimesCubit>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.enterCity.tr),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: AppStrings.enterCity.tr),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await cubit.useCurrentLocation();
              },
              child: Text(AppStrings.useCurrentLocation.tr),
            ),
            TextButton(
              onPressed: () async {
                final city = controller.text.trim();
                if (city.isEmpty) return;
                Navigator.pop(dialogContext);
                final ok = await cubit.setManualLocation(city);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? AppStrings.locationSaved.tr
                          : AppStrings.locationNotFound.tr,
                    ),
                  ),
                );
              },
              child: Text(AppStrings.applyLocation.tr),
            ),
          ],
        );
      },
    );
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
            onPressed: _showManualLocationDialog,
            icon: const Icon(Icons.edit_location_alt, color: AppColors.accent),
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [AppColors.primaryDark, AppColors.background],
          ),
        ),
        child: SafeArea(
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
                final now = DateTime.now();
                final next = PrayerScheduleHelper.computeNextPrayer(
                  state.prayerTimes,
                  reference: now,
                );
                final prayers = PrayerScheduleHelper.prayerSlots(
                  state.prayerTimes,
                  now,
                );

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.accent,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(18),
                        borderRadius: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.locationName,
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${AppStrings.lastUpdated.tr}: ${DateFormat('hh:mm a').format(state.lastUpdatedAt)}',
                              style: TextStyle(
                                color: AppColors.textWhite.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 12,
                              ),
                            ),
                            if (state.isFromCache) ...[
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.offlineMode.tr,
                                style: TextStyle(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(18),
                        borderRadius: 20,
                        child: Row(
                          children: [
                            Icon(
                              next.slot.icon,
                              color: AppColors.accent,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.nextPrayer.tr,
                                    style: TextStyle(
                                      color: AppColors.textWhite.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    next.slot.key.tr,
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              PrayerScheduleHelper.formatCountdown(
                                next.remaining,
                              ),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...prayers.map((slot) {
                        final isNext = slot.id == next.slot.id;
                        final timeLabel = DateFormat(
                          'hh:mm a',
                        ).format(slot.time);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            color: isNext
                                ? AppColors.primary.withValues(alpha: 0.45)
                                : const Color(0x1AFFFFFF),
                            child: Row(
                              children: [
                                Icon(slot.icon, color: AppColors.accent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    slot.key.tr,
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  timeLabel,
                                  style: TextStyle(
                                    color: isNext
                                        ? AppColors.accent
                                        : AppColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
