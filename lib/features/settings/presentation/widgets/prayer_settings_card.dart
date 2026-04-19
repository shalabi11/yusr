import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'prayer_settings_card_sections.dart';

class PrayerSettingsCard extends StatelessWidget {
  const PrayerSettingsCard({required this.state, super.key});

  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    final isArabic = state.langCode == 'ar';
    final settings = context.read<SettingsCubit>();
    final prayerCubit = context.read<PrayerTimesCubit>();
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active, color: AppColors.accent),
              const SizedBox(width: 10),
              Text(
                isArabic ? 'إعدادات تنبيه الصلاة' : 'Prayer Notifications',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsSwitchRow(
            label: isArabic ? 'صوت الأذان كامل' : 'Full Adhan Sound',
            value: state.playAdhan,
            onChanged: (val) {
              settings.setPlayAdhan(val);
              prayerCubit.fetchPrayerTimes(force: true);
            },
          ),
          const SizedBox(height: 15),
          SettingsSwitchRow(
            label: AppStrings.quranReadAsText.tr,
            value: state.quranReadAsText,
            onChanged: settings.setQuranReadAsText,
          ),
          const SizedBox(height: 15),
          SettingsDropdownRow<String>(
            label: AppStrings.adhanSound.tr,
            value: state.adhanSound,
            items: NotificationService.adhanSoundOptions
                .map(
                  (val) =>
                      DropdownMenuItem<String>(value: val, child: Text(val)),
                )
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              settings.setAdhanSound(val);
              prayerCubit.fetchPrayerTimes(force: true);
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => NotificationService.previewAdhanSound(
                adhanSound: state.adhanSound,
                playAdhan: state.playAdhan,
              ),
              icon: const Icon(Icons.play_arrow, color: AppColors.accent),
              label: Text(
                AppStrings.previewSound.tr,
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SettingsSwitchRow(
            label: isArabic
                ? 'تثبيت في لوحة الإشعارات'
                : 'Pin in Notifications',
            value: state.stickyNotification,
            onChanged: (val) {
              settings.setStickyNotification(val);
              prayerCubit.fetchPrayerTimes(force: true);
            },
          ),
          const SizedBox(height: 15),
          SettingsDropdownRow<int>(
            label: isArabic ? 'التنبيه قبل (دقائق)' : 'Alert Before (Mins)',
            value: state.prayerOffset,
            items: [0, 5, 10, 15]
                .map(
                  (val) => DropdownMenuItem<int>(
                    value: val,
                    child: Text(
                      val == 0 ? (isArabic ? 'في الوقت' : 'On Time') : '$val',
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              settings.setPrayerOffset(val);
              prayerCubit.fetchPrayerTimes(force: true);
            },
          ),
        ],
      ),
    );
  }
}
