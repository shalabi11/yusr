import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppStrings.settings.tr,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildLanguageSetting(context),
              const SizedBox(height: 20),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return _buildPrayerSettings(context, state);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerSettings(BuildContext context, SettingsState state) {
    bool isArabic = state.langCode == 'ar';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'صوت الأذان كامل' : 'Full Adhan Sound',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                ),
              ),
              Switch(
                value: state.playAdhan,
                activeThumbColor: AppColors.accent,
                onChanged: (val) {
                  context.read<SettingsCubit>().setPlayAdhan(val);
                  context.read<PrayerTimesCubit>().fetchPrayerTimes();
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.quranReadAsText.tr,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                ),
              ),
              Switch(
                value: state.quranReadAsText,
                activeThumbColor: AppColors.accent,
                onChanged: (val) {
                  context.read<SettingsCubit>().setQuranReadAsText(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.adhanSound.tr,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                ),
              ),
              DropdownButton<String>(
                value: state.adhanSound,
                dropdownColor: AppColors.primaryDark,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                underline: const SizedBox(),
                items: NotificationService.adhanSoundOptions.map((String val) {
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<SettingsCubit>().setAdhanSound(val);
                    context.read<PrayerTimesCubit>().fetchPrayerTimes();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                NotificationService.previewAdhanSound(
                  adhanSound: state.adhanSound,
                  playAdhan: state.playAdhan,
                );
              },
              icon: const Icon(Icons.play_arrow, color: AppColors.accent),
              label: Text(
                AppStrings.previewSound.tr,
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'تثبيت في لوحة الإشعارات' : 'Pin in Notifications',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                ),
              ),
              Switch(
                value: state.stickyNotification,
                activeThumbColor: AppColors.accent,
                onChanged: (val) {
                  context.read<SettingsCubit>().setStickyNotification(val);
                  context.read<PrayerTimesCubit>().fetchPrayerTimes();
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'التنبيه قبل (دقائق)' : 'Alert Before (Mins)',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                ),
              ),
              DropdownButton<int>(
                value: state.prayerOffset,
                dropdownColor: AppColors.primaryDark,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                underline: const SizedBox(),
                items: [0, 5, 10, 15].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text(
                      val == 0 ? (isArabic ? 'في الوقت' : 'On Time') : '$val',
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<SettingsCubit>().setPrayerOffset(val);
                    context.read<PrayerTimesCubit>().fetchPrayerTimes();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: AppColors.accent),
              const SizedBox(width: 10),
              Text(
                AppStrings.language.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: _buildLangButton(
                      context,
                      title: AppStrings.arabic.tr,
                      code: 'ar',
                      isSelected: state.langCode == 'ar',
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildLangButton(
                      context,
                      title: AppStrings.english.tr,
                      code: 'en',
                      isSelected: state.langCode == 'en',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(
    BuildContext context, {
    required String title,
    required String code,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        context.read<SettingsCubit>().changeLanguage(code);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : AppColors.primaryDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: isSelected ? 1.0 : 0.3),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryDark : AppColors.textWhite,
            ),
          ),
        ),
      ),
    );
  }
}
