part of 'quran_screen.dart';

extension QuranScreenUi on _QuranScreenState {
  Widget buildQuranBody(bool readAsText) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchController,
            onChanged: _updateSearch,
            decoration: InputDecoration(
              hintText: 'ابحث بالسورة أو نص الآية...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              QuranSurahTab(
                surahs: _surahs,
                search: _search,
                readAsText: readAsText,
                repo: _repo,
                onReload: loadData,
              ),
              QuranJuzTab(repo: _repo, onReload: loadData),
              const QuranPagesTab(),
              QuranKhatmaTab(
                lastRead: _lastRead,
                daysController: _daysController,
                khatmaPlan: _khatmaPlan,
                onComputePlan: computeKhatmaPlan,
                onScheduleReminder: scheduleKhatmaReminder,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
