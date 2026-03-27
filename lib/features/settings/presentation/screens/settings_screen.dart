import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/settings/presentation/widgets/fasting_settings_card.dart';
import 'package:yusr_app/features/settings/presentation/widgets/language_setting_card.dart';
import 'package:yusr_app/features/settings/presentation/widgets/prayer_settings_card.dart';

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
      body: AppRadialBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const LanguageSettingCard(),
            const SizedBox(height: 20),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return PrayerSettingsCard(state: state);
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return FastingSettingsCard(state: state);
              },
            ),
          ],
        ),
      ),
    );
  }
}
