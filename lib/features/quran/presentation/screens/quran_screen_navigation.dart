part of 'quran_screen.dart';

extension QuranScreenNavigation on QuranScreenState {
  Future<void> openLastRead(bool readAsText) async {
    if (_lastRead == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد موضع قراءة محفوظ بعد')),
      );
      return;
    }

    if (readAsText) {
      if (_surahs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بيانات القرآن غير متوفرة بعد')),
        );
        return;
      }
      final surah = _surahs.firstWhere(
        (s) => s.number == _lastRead!.surahNumber,
        orElse: () => _surahs.first,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranReaderScreen(surah: surah, repo: widget.repo),
        ),
      );
    } else {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranPageViewerScreen(
            initialPage: _lastRead!.pageNumber,
            repo: widget.repo,
            showPageTitle: false,
          ),
        ),
      );
    }

    await loadData();
  }

  Future<void> openQuickJumpSheet(bool readAsText) async {
    if (readAsText && _surahs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات القرآن غير متوفرة بعد')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuranQuickJumpSheet(
        parentContext: context,
        surahs: _surahs,
        readAsText: readAsText,
        repo: widget.repo,
        onReload: loadData,
      ),
    );
  }

  Future<void> openBookmarksSheet(bool readAsText) async {
    final bookmarks = widget.repo.getBookmarks();
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
        repo: widget.repo,
        surahs: _surahs,
        onReload: loadData,
      ),
    );
  }
}
