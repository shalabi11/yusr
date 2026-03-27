import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/prayer_times/data/models/prayer_time_model.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class FastingSettingsCard extends StatelessWidget {
  const FastingSettingsCard({required this.state, super.key});

  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    final isArabic = state.langCode == 'ar';

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.nightlight_round, color: AppColors.accent),
              const SizedBox(width: 10),
              Text(
                isArabic ? 'تنبيهات صيام التطوع' : 'Voluntary Fasting Alerts',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'تفعيل تنبيهات الصيام' : 'Enable fasting alerts',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                ),
              ),
              Switch(
                value: state.fastingRemindersEnabled,
                activeThumbColor: AppColors.accent,
                onChanged: (val) async {
                  final settingsCubit = context.read<SettingsCubit>();
                  final prayerTimes = _currentPrayerTimes(context);
                  await settingsCubit.setFastingRemindersEnabled(val);
                  await NotificationService.syncFastingReminders(
                    prayerTimes: prayerTimes,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: state.fastingRemindersEnabled ? 1 : 0.45,
            child: IgnorePointer(
              ignoring: !state.fastingRemindersEnabled,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isArabic
                            ? 'الأيام البيض (13-14-15)'
                            : 'White days (13-14-15 Hijri)',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                        ),
                      ),
                      Switch(
                        value: state.whiteDaysReminderEnabled,
                        activeThumbColor: AppColors.accent,
                        onChanged: (val) async {
                          final settingsCubit = context.read<SettingsCubit>();
                          final prayerTimes = _currentPrayerTimes(context);
                          await settingsCubit.setWhiteDaysReminderEnabled(val);
                          await NotificationService.syncFastingReminders(
                            prayerTimes: prayerTimes,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isArabic ? 'الاثنين والخميس' : 'Monday & Thursday',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                        ),
                      ),
                      Switch(
                        value: state.mondayThursdayReminderEnabled,
                        activeThumbColor: AppColors.accent,
                        onChanged: (val) async {
                          final settingsCubit = context.read<SettingsCubit>();
                          final prayerTimes = _currentPrayerTimes(context);
                          await settingsCubit.setMondayThursdayReminderEnabled(
                            val,
                          );
                          await NotificationService.syncFastingReminders(
                            prayerTimes: prayerTimes,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'تنبيه الاثنين بعد عشاء الأحد، وتنبيه الخميس بعد عشاء الأربعاء.'
                : 'Monday alert is after Sunday Isha, Thursday alert is after Wednesday Isha.',
            style: TextStyle(
              color: AppColors.textWhite.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  PrayerTimeModel? _currentPrayerTimes(BuildContext context) {
    final prayerState = context.read<PrayerTimesCubit>().state;
    if (prayerState is PrayerTimesLoaded) {
      return prayerState.prayerTimes;
    }
    return null;
  }
}
