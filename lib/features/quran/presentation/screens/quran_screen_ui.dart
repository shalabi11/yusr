part of 'quran_screen.dart';

extension QuranScreenUi on QuranScreenState {
  Widget buildQuranBody(bool readAsText, {required bool isArabic}) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_surahs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_download_outlined,
                size: 62,
                color: AppColors.accent,
              ),
              const SizedBox(height: 12),
              const Text(
                'بيانات القرآن غير متوفرة بعد',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'نزّل القرآن من شاشة تنزيل المحتوى ثم أعد المحاولة.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/content-download'),
                icon: const Icon(Icons.download_for_offline_outlined),
                label: const Text('فتح تنزيل المحتوى'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: loadData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        /*
        // TODO: Re-enable search feature in the future once performance is improved.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchController,
            onChanged: _updateSearch,
            decoration: InputDecoration(
              hintText: isArabic
                  ? 'ابحث بكلمة أو موضوع (topic:الصبر)...'
                  : 'Search by keyword or topic (topic:patience)...',
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
        */
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadData,
            color: AppColors.accent,
            notificationPredicate: (notification) => notification.depth >= 1,
            child: TabBarView(
              controller: _tabController,
              children: [
                QuranSurahTab(
                  surahs: _filteredSurahs,
                  search: _search,
                  matchedPreviewBySurah: _matchedPreviewBySurah,
                  offlineAvailabilityBySurah: _offlineAvailabilityBySurah,
                  readAsText: readAsText,
                  isArabic: isArabic,
                  useCases: widget.useCases,
                  onReload: loadData,
                ),
                QuranJuzTab(useCases: widget.useCases, onReload: loadData),
                QuranPagesTab(useCases: widget.useCases),
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
        ),
      ],
    );
  }
}
