import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:yusr_app/features/home/presentation/cubit/home_state.dart';

class DailyContentCard extends StatelessWidget {
  const DailyContentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return GlassContainer(
          padding: const EdgeInsets.all(25),
          borderRadius: 24,
          color: AppColors.primary.withValues(alpha: 0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.ayahOfDay.tr,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state.isLoadingAyah)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                )
              else if (state.dailyAyah != null)
                Column(
                  children: [
                    Text(
                      state.dailyAyah!.content,
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        height: 1.6,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        state.dailyAyah!.source,
                        style: const TextStyle(color: AppColors.accent),
                      ),
                    ),
                  ],
                )
              else
                const Center(
                  child: Text(
                    'Failed to load daily content',
                    style: TextStyle(color: AppColors.textWhite),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
