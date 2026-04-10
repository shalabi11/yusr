part of 'quran_screen.dart';

extension QuranScreenNavigation on _QuranScreenState {
  Future<void> openLastRead(bool readAsText) async {
    if (_lastRead == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد موضع قراءة محفوظ بعد')),
      );
      return;
    }

    if (readAsText) {
      final surah = _surahs.firstWhere(
        (s) => s.number == _lastRead!.surahNumber,
        orElse: () => _surahs.first,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)),
      );
    } else {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranPageViewerScreen(
            initialPage: _lastRead!.pageNumber,
            showPageTitle: false,
          ),
        ),
      );
    }

    await loadData();
  }

  Future<void> openQuickJumpSheet(bool readAsText) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuranQuickJumpSheet(
        parentContext: context,
        surahs: _surahs,
        readAsText: readAsText,
        repo: _repo,
        onReload: loadData,
      ),
    );
  }

  Future<void> openBookmarksSheet(bool readAsText) async {
    final bookmarks = _repo.getBookmarks();
    if (bookmarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد علامات مرجعية محفوظة بعد')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuranBookmarksSheet(
        parentContext: context,
        readAsText: readAsText,
        repo: _repo,
        surahs: _surahs,
        onReload: loadData,
      ),
    );
  }
}
