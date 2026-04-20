part of 'quran_page_viewer_screen.dart';

extension _QuranPageViewerActions on _QuranPageViewerScreenState {
  Future<void> _loadPageMetaByPage() async {
    final map = await widget.useCases.loadPageMetaByPage();
    if (!mounted) return;
    _replacePageMeta(map);
  }

  Future<void> _bookmarkCurrentPage() async {
    final fromPage = await widget.useCases.getLastReadForPage(_currentPage);
    if (fromPage != null) {
      await widget.useCases.addBookmark(fromPage);
    } else {
      final previous = widget.useCases.getLastRead();
      await widget.useCases.saveLastRead(
        QuranLastRead(
          surahNumber: previous?.surahNumber ?? 1,
          verseNumber: previous?.verseNumber ?? 1,
          pageNumber: _currentPage,
          juzNumber: previous?.juzNumber ?? 1,
        ),
      );
    }

    _markPageSaved(_currentPage);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ المرجعية عند الصفحة $_currentPage')),
    );
  }
}
