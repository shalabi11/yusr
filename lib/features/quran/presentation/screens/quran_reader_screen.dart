import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [AppColors.primaryDark, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: widget.surah.verses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final verse = widget.surah.verses[index];
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
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                          ),
                          onPressed: () => _saveBookmark(verse),
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
            },
          ),
        ),
      ),
    );
  }
}
