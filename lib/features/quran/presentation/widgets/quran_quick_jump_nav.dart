import 'package:flutter/material.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';

Future<void> goToSurahJump({
  required BuildContext sheetContext,
  required BuildContext parentContext,
  required List<QuranSurah> surahs,
  required bool readAsText,
  required QuranRepository repo,
  required Future<void> Function() onReload,
  required String input,
}) async {
  final surahNumber = int.tryParse(input.trim());
  if (surahNumber == null || surahNumber < 1 || surahNumber > 114) {
    _showQuickJumpMessage(sheetContext, 'رقم السورة غير صالح');
    return;
  }

  Navigator.of(sheetContext).pop();
  if (!parentContext.mounted) return;

  final surah = surahs.firstWhere(
    (s) => s.number == surahNumber,
    orElse: () => surahs.first,
  );
  if (readAsText) {
    await Navigator.of(
      parentContext,
    ).push(MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)));
  } else {
    final pages = await repo.pagesForSurah(surahNumber);
    if (!parentContext.mounted || pages.isEmpty) return;
    await Navigator.of(parentContext).push(
      MaterialPageRoute(
        builder: (_) => QuranPageViewerScreen(
          initialPage: pages.first,
          pages: pages,
          showPageTitle: false,
        ),
      ),
    );
  }

  if (!parentContext.mounted) return;
  await onReload();
}

Future<void> goToJuzJump({
  required BuildContext sheetContext,
  required BuildContext parentContext,
  required QuranRepository repo,
  required Future<void> Function() onReload,
  required String input,
}) async {
  final juz = int.tryParse(input.trim());
  if (juz == null || juz < 1 || juz > 30) {
    _showQuickJumpMessage(sheetContext, 'رقم الجزء غير صالح');
    return;
  }

  final pages = await repo.pagesForJuz(juz);
  if (!sheetContext.mounted || pages.isEmpty) return;

  Navigator.of(sheetContext).pop();
  if (!parentContext.mounted) return;

  await Navigator.of(parentContext).push(
    MaterialPageRoute(
      builder: (_) => QuranPageViewerScreen(
        initialPage: pages.first,
        pages: pages,
        showPageTitle: false,
      ),
    ),
  );

  if (!parentContext.mounted) return;
  await onReload();
}

Future<void> goToPageJump({
  required BuildContext sheetContext,
  required BuildContext parentContext,
  required Future<void> Function() onReload,
  required String input,
}) async {
  final page = int.tryParse(input.trim());
  if (page == null || page < 1 || page > 604) {
    _showQuickJumpMessage(sheetContext, 'رقم الصفحة غير صالح');
    return;
  }

  Navigator.of(sheetContext).pop();
  if (!parentContext.mounted) return;

  await Navigator.of(parentContext).push(
    MaterialPageRoute(
      builder: (_) =>
          QuranPageViewerScreen(initialPage: page, showPageTitle: false),
    ),
  );

  if (!parentContext.mounted) return;
  await onReload();
}

void _showQuickJumpMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
