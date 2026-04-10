import 'package:flutter/material.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';

String buildSurahSubtitle(QuranSurah surah, String search) {
  if (search.isEmpty) return '${surah.versesCount} آية';

  final match = surah.verses.where((v) => v.textAr.contains(search));
  if (match.isEmpty) return '${surah.versesCount} آية';

  final preview = match.first.textAr;
  final short = preview.length > 45
      ? '${preview.substring(0, 45)}...'
      : preview;
  return 'نتيجة آية: $short';
}

Future<void> openSurah(
  BuildContext context, {
  required QuranSurah surah,
  required bool readAsText,
  required QuranRepository repo,
  required Future<void> Function() onReload,
}) async {
  if (readAsText) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)),
    );
  } else {
    final pages = await repo.pagesForSurah(surah.number);
    if (!context.mounted || pages.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranPageViewerScreen(
          initialPage: pages.first,
          pages: pages,
          showPageTitle: false,
        ),
      ),
    );
  }

  if (!context.mounted) return;
  await onReload();
}
