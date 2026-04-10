import 'package:flutter/material.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';

import 'quran_bookmarks_sheet_view.dart';

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
    return QuranBookmarksSheetView(
      bookmarks: _bookmarks,
      surahNameFor: _surahNameFor,
      onOpen: _openBookmark,
      onDelete: _deleteBookmark,
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
