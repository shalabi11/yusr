import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_verse_card.dart';

class QuranReaderScreen extends StatefulWidget {
  final QuranSurah surah;

  const QuranReaderScreen({super.key, required this.surah});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final QuranRepository _repo = QuranRepository();

  Future<void> _saveBookmark(QuranVerse verse) async {
    final data = QuranLastRead(
      surahNumber: widget.surah.number,
      verseNumber: verse.number,
      pageNumber: verse.page,
      juzNumber: verse.juz,
    );
    await _repo.addBookmark(data);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ العلامة المرجعية')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.surah.nameAr),
        iconTheme: const IconThemeData(color: AppColors.accent),
        actionsIconTheme: const IconThemeData(color: AppColors.accent),
      ),
      body: AppRadialBackground(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: widget.surah.verses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final verse = widget.surah.verses[index];
            return QuranVerseCard(
              verse: verse,
              onSaveBookmark: () => _saveBookmark(verse),
            );
          },
        ),
      ),
    );
  }
}
