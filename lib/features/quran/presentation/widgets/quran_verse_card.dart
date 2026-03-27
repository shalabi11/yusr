import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';

class QuranVerseCard extends StatelessWidget {
  const QuranVerseCard({
    required this.verse,
    required this.onSaveBookmark,
    super.key,
  });

  final QuranVerse verse;
  final VoidCallback onSaveBookmark;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accent,
                child: Text(
                  '${verse.number}',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                onPressed: onSaveBookmark,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('حفظ'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            verse.textAr,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 22,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الجزء ${verse.juz} • الصفحة ${verse.page}',
            style: TextStyle(
              color: AppColors.textWhite.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
