part of 'quran_page_viewer_screen.dart';

extension _QuranPageViewerActions on _QuranPageViewerScreenState {
  Future<void> _loadPageMetaByPage() async {
    final surahs = await _repo.loadSurahs();
    final map = <int, _PageMeta>{};
    for (final surah in surahs) {
      for (final verse in surah.verses) {
        map.putIfAbsent(
          verse.page,
          () => _PageMeta(surahName: surah.nameAr, juzNumber: verse.juz),
        );
      }
    }
    if (!mounted) return;
    _replacePageMeta(map);
  }

  Future<void> _bookmarkCurrentPage() async {
    final fromPage = await _repo.getLastReadForPage(_currentPage);
    if (fromPage != null) {
      await _repo.addBookmark(fromPage);
    } else {
      final previous = _repo.getLastRead();
      await _repo.saveLastRead(
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
