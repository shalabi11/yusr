import 'package:flutter/material.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';

String buildSurahSubtitle(QuranSurah surah, String search, String? preview) {
  if (search.isEmpty) return '${surah.versesCount} آية';

  if (preview == null || preview.isEmpty) {
    return '${surah.versesCount} آية';
  }

  final short = preview.length > 45
      ? '${preview.substring(0, 45)}...'
      : preview;
  return 'نتيجة آية: $short';
}

Future<void> openSurah(
  BuildContext context, {
  required QuranSurah surah,
  required bool readAsText,
  required QuranUseCases useCases,
  required Future<void> Function() onReload,
  String? heroTag,
}) async {
  if (readAsText) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranReaderScreen(surah: surah, useCases: useCases),
      ),
    );
  } else {
    int? initialPage = surah.verses.isEmpty ? null : surah.verses.first.page;
    if (initialPage == null || initialPage < 1 || initialPage > 604) {
      final pages = await useCases.pagesForSurah(surah.number);
      if (!context.mounted || pages.isEmpty) return;
      initialPage = pages.first;
    }

    final targetPage = initialPage;
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranPageViewerScreen(
          initialPage: targetPage,
          useCases: useCases,
          showPageTitle: false,
          entryHeroTag: heroTag,
          entrySurahNumber: surah.number,
          entrySurahName: surah.nameAr,
        ),
      ),
    );
  }

  if (!context.mounted) return;
  await onReload();
}
