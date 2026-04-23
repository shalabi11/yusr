part of 'quran_screen.dart';

extension _QuranScreenAppBar on _QuranScreenState {
  PreferredSizeWidget buildQuranAppBar(bool readAsText, QuranState state) {
    // Search is temporarily disabled
    /*
    if (state.isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<QuranCubit>().toggleSearch(),
        ),
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'بحث في القرآن (سورة أو محتوى)...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) => context.read<QuranCubit>().filterSurahs(value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => context.read<QuranCubit>().filterSurahs(''),
          ),
        ],
      );
    }
    */

    return AppBar(
      title: const Text('القرآن الكريم'),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'السور'),
          Tab(text: 'الأجزاء'),
          Tab(text: 'الصفحات'),
          Tab(text: 'الختمة'),
        ],
      ),
      actions: [
        /*
        IconButton(
          onPressed: () => context.read<QuranCubit>().toggleSearch(),
          icon: const Icon(Icons.search),
          tooltip: 'بحث',
        ),
        */
        IconButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranPageViewerScreen(
                  initialPage: 1,
                  useCases: context.read<QuranCubit>().useCases,
                  showPageTitle: false,
                ),
              ),
            );
            if (mounted) {
              context.read<QuranCubit>().refreshCachedState();
            }
          },
          icon: const Icon(Icons.menu_book),
          tooltip: 'ابدأ من أول صفحة',
        ),
        IconButton(
          onPressed: () => openQuickJumpSheet(readAsText, state),
          icon: const Icon(Icons.travel_explore),
          tooltip: 'انتقال مباشر',
        ),
        IconButton(
          onPressed: () => openBookmarksSheet(readAsText, state),
          icon: const Icon(Icons.bookmarks),
          tooltip: 'العلامات المرجعية',
        ),
        IconButton(
          onPressed: () => openLastRead(readAsText, state),
          icon: const Icon(Icons.bookmark),
          tooltip: 'الرجوع لآخر موضع',
        ),
      ],
    );
  }
}
