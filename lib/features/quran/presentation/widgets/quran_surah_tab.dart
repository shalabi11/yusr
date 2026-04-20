import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';
import 'package:yusr_app/features/quran/presentation/models/quran_offline_availability.dart';

import 'quran_surah_tab_helpers.dart';

class QuranSurahTab extends StatelessWidget {
  const QuranSurahTab({
    required this.surahs,
    required this.search,
    required this.matchedPreviewBySurah,
    required this.offlineAvailabilityBySurah,
    required this.readAsText,
    required this.isArabic,
    required this.useCases,
    required this.onReload,
    super.key,
  });

  final List<QuranSurah> surahs;
  final String search;
  final Map<int, String> matchedPreviewBySurah;
  final Map<int, QuranOfflineAvailability> offlineAvailabilityBySurah;
  final bool readAsText;
  final bool isArabic;
  final QuranUseCases useCases;
  final Future<void> Function() onReload;

  String _offlineLabel(QuranOfflineAvailability availability) {
    switch (availability) {
      case QuranOfflineAvailability.full:
        return isArabic ? 'متاح بدون إنترنت' : 'Offline Ready';
      case QuranOfflineAvailability.partial:
        return isArabic ? 'متاح جزئيًا' : 'Partially Offline';
      case QuranOfflineAvailability.none:
        return isArabic ? 'يحتاج تنزيل صفحات' : 'Needs Download';
    }
  }

  Color _offlineColor(QuranOfflineAvailability availability) {
    switch (availability) {
      case QuranOfflineAvailability.full:
        return const Color(0xFF34D399);
      case QuranOfflineAvailability.partial:
        return const Color(0xFFF59E0B);
      case QuranOfflineAvailability.none:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final surah = surahs[index];
        final heroTag = 'quran-surah-${surah.number}';
        final availability =
            offlineAvailabilityBySurah[surah.number] ??
            QuranOfflineAvailability.none;
        final statusColor = _offlineColor(availability);
        return InkWell(
          onTap: () => openSurah(
            context,
            surah: surah,
            readAsText: readAsText,
            useCases: useCases,
            onReload: onReload,
            heroTag: heroTag,
          ),
          borderRadius: BorderRadius.circular(16),
          child: GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Hero(
                  tag: heroTag,
                  child: Material(
                    color: Colors.transparent,
                    child: CircleAvatar(
                      backgroundColor: AppColors.accent,
                      child: Text(
                        '${surah.number}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameAr,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          _offlineLabel(availability),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        buildSurahSubtitle(
                          surah,
                          search,
                          matchedPreviewBySurah[surah.number],
                        ),
                        style: TextStyle(
                          color: AppColors.textWhite.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: AppColors.accent),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: surahs.length,
    );
  }
}
