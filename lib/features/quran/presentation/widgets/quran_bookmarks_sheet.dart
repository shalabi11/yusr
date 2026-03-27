import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';

class QuranBookmarksSheet extends StatefulWidget {
  const QuranBookmarksSheet({
    required this.parentContext,
    required this.readAsText,
    required this.repo,
    required this.surahs,
    required this.onReload,
    super.key,
  });

  final BuildContext parentContext;
  final bool readAsText;
  final QuranRepository repo;
  final List<QuranSurah> surahs;
  final Future<void> Function() onReload;

  @override
  State<QuranBookmarksSheet> createState() => _QuranBookmarksSheetState();
}

class _QuranBookmarksSheetState extends State<QuranBookmarksSheet> {
  late List<QuranBookmark> _bookmarks;

  @override
  void initState() {
    super.initState();
    _bookmarks = widget.repo.getBookmarks();
  }

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
                itemCount: _bookmarks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final bookmark = _bookmarks[index];
                  final surahName = _surahNameFor(bookmark.surahNumber);

                  return ListTile(
                    leading: const Icon(Icons.bookmark, color: AppColors.accent),
                    title: Text(
                      surahName,
                      style: const TextStyle(color: AppColors.textWhite),
                    ),
                    subtitle: Text(
                      'آية ${bookmark.verseNumber} • صفحة ${bookmark.pageNumber} • جزء ${bookmark.juzNumber}',
                      style: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                    onTap: () => _openBookmark(bookmark),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteBookmark(bookmark),
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

  String _surahNameFor(int surahNumber) {
    for (final surah in widget.surahs) {
      if (surah.number == surahNumber) {
        return surah.nameAr;
      }
    }
    return 'سورة $surahNumber';
  }

  Future<void> _openBookmark(QuranBookmark bookmark) async {
    Navigator.of(context).pop();
    if (!widget.parentContext.mounted) return;

    if (widget.readAsText) {
      final surah = widget.surahs.firstWhere(
        (s) => s.number == bookmark.surahNumber,
        orElse: () => widget.surahs.first,
      );
      await Navigator.of(widget.parentContext).push(
        MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)),
      );
    } else {
      await Navigator.of(widget.parentContext).push(
        MaterialPageRoute(
          builder: (_) => QuranPageViewerScreen(
            initialPage: bookmark.pageNumber,
            showPageTitle: false,
          ),
        ),
      );
    }

    if (!widget.parentContext.mounted) return;
    await widget.onReload();
  }

  Future<void> _deleteBookmark(QuranBookmark bookmark) async {
    await widget.repo.removeBookmark(bookmark.id);
    if (!mounted) return;

    setState(() {
      _bookmarks.removeWhere((b) => b.id == bookmark.id);
    });

    if (_bookmarks.isEmpty && context.mounted) {
      Navigator.of(context).pop();
    }

    if (!widget.parentContext.mounted) return;
    await widget.onReload();
  }
}
