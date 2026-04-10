import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_verse_card.dart';
import 'package:yusr_app/injection_container.dart';

class QuranReaderScreen extends StatefulWidget {
  final QuranSurah surah;

  const QuranReaderScreen({super.key, required this.surah});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final QuranRepository _repo = sl<QuranRepository>();

  String _formatRange(List<int> values) {
    if (values.isEmpty) return '-';
    final sorted = values.toSet().toList()..sort();
    final first = sorted.first;
    final last = sorted.last;
    return first == last ? '$first' : '$first - $last';
  }

  Widget _buildSurahMetaHeader() {
    final verses = widget.surah.verses;
    final pageText = _formatRange(verses.map((v) => v.page).toList());
    final juzText = _formatRange(verses.map((v) => v.juz).toList());
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.surah.nameAr,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الصفحات: $pageText  •  الجزء: $juzText',
            style: TextStyle(
              color: AppColors.textWhite.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          itemCount: widget.surah.verses.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) return _buildSurahMetaHeader();
            final verse = widget.surah.verses[index - 1];
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
