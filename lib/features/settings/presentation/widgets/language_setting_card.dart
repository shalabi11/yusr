import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';

class LanguageSettingCard extends StatelessWidget {
  const LanguageSettingCard({super.key});

  @override
  Widget build(BuildContext context) {
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
