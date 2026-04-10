import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';

class QuranBookmarksSheetView extends StatelessWidget {
  const QuranBookmarksSheetView({
    required this.bookmarks,
    required this.surahNameFor,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  final List<QuranBookmark> bookmarks;
  final String Function(int) surahNameFor;
  final Future<void> Function(QuranBookmark) onOpen;
  final Future<void> Function(QuranBookmark) onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'العلامات المرجعية',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: bookmarks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final bookmark = bookmarks[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.bookmark,
                      color: AppColors.accent,
                    ),
                    title: Text(
                      surahNameFor(bookmark.surahNumber),
                      style: const TextStyle(color: AppColors.textWhite),
                    ),
                    subtitle: Text(
                      'آية ${bookmark.verseNumber} • صفحة ${bookmark.pageNumber} • جزء ${bookmark.juzNumber}',
                      style: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                    onTap: () => onOpen(bookmark),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => onDelete(bookmark),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
