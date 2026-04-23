part of 'quran_screen.dart';

extension _QuranScreenNavigation on _QuranScreenState {
  Future<void> openLastRead(bool readAsText, QuranState state) async {
    if (state.lastRead == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد موضع قراءة محفوظ بعد')),
      );
      return;
    }

    if (readAsText) {
      if (state.surahs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بيانات القرآن غير متوفرة بعد')),
        );
        return;
      }
      final surah = state.surahs.firstWhere(
        (s) => s.number == state.lastRead!.surahNumber,
        orElse: () => state.surahs.first,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranReaderScreen(
            surah: surah,
            useCases: context.read<QuranCubit>().useCases,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranPageViewerScreen(
            initialPage: state.lastRead!.pageNumber,
            useCases: context.read<QuranCubit>().useCases,
            showPageTitle: false,
          ),
        ),
      );
    }

    if (mounted) {
      context.read<QuranCubit>().refreshCachedState();
    }
  }

  Future<void> openQuickJumpSheet(bool readAsText, QuranState state) async {
    if (readAsText && state.surahs.isEmpty) {
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
        surahs: state.surahs,
        readAsText: readAsText,
        useCases: context.read<QuranCubit>().useCases,
        onReload: () async {
          context.read<QuranCubit>().refreshCachedState();
        },
      ),
    );
  }

  Future<void> openBookmarksSheet(bool readAsText, QuranState state) async {
    final bookmarks = context.read<QuranCubit>().useCases.getBookmarks();
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
        useCases: context.read<QuranCubit>().useCases,
        surahs: state.surahs,
        onReload: () async {
          context.read<QuranCubit>().refreshCachedState();
        },
      ),
    );
  }
}
