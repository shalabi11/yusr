part of 'quran_screen.dart';

extension QuranScreenAppBar on QuranScreenState {
  PreferredSizeWidget buildQuranAppBar(bool readAsText) {
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
        IconButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QuranPageViewerScreen(
                  initialPage: 1,
                  showPageTitle: false,
                ),
              ),
            );
            await loadData();
          },
          icon: const Icon(Icons.menu_book),
          tooltip: 'ابدأ من أول صفحة',
        ),
        IconButton(
          onPressed: () => openQuickJumpSheet(readAsText),
          icon: const Icon(Icons.travel_explore),
          tooltip: 'انتقال مباشر',
        ),
        IconButton(
          onPressed: () => openBookmarksSheet(readAsText),
          icon: const Icon(Icons.bookmarks),
          tooltip: 'العلامات المرجعية',
        ),
        IconButton(
          onPressed: () => openLastRead(readAsText),
          icon: const Icon(Icons.bookmark),
          tooltip: 'الرجوع لآخر موضع',
        ),
      ],
    );
  }
}
