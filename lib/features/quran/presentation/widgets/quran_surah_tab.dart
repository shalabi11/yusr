import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';

import 'quran_surah_tab_helpers.dart';

class QuranSurahTab extends StatelessWidget {
  const QuranSurahTab({
    required this.surahs,
    required this.search,
    required this.readAsText,
    required this.repo,
    required this.onReload,
    super.key,
  });

  final List<QuranSurah> surahs;
  final String search;
  final bool readAsText;
  final QuranRepository repo;
  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    final filtered = surahs.where((s) {
      if (search.isEmpty) return true;
      final q = search.toLowerCase();
      final hasAyahMatch = s.verses.any((v) => v.textAr.contains(search));
      return s.nameAr.contains(search) ||
          s.nameEn.toLowerCase().contains(q) ||
          s.number.toString().contains(q) ||
          hasAyahMatch;
    }).toList();

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final surah = filtered[index];
        return InkWell(
          onTap: () => openSurah(
            context,
            surah: surah,
            readAsText: readAsText,
            repo: repo,
            onReload: onReload,
          ),
          borderRadius: BorderRadius.circular(16),
          child: GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
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
                      Text(
                        buildSurahSubtitle(surah, search),
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
      itemCount: filtered.length,
    );
  }
}
