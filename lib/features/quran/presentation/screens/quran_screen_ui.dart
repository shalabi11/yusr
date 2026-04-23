part of 'quran_screen.dart';

extension _QuranScreenUi on _QuranScreenState {
  Widget buildQuranBody(
    bool readAsText, {
    required bool isArabic,
    required QuranState state,
  }) {
    final contentDownloaded = StorageService.quranContentDownloaded;
    final isBlockingLoad =
        (state.status == QuranStatus.loading ||
            state.status == QuranStatus.initial) &&
        !contentDownloaded;

    if (isBlockingLoad) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (state.surahs.isEmpty && !contentDownloaded) {
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
                onPressed: () => context.read<QuranCubit>().loadData(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 0),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                context.read<QuranCubit>().refreshCachedState(),
            color: AppColors.accent,
            notificationPredicate: (notification) => notification.depth >= 1,
            child: TabBarView(
              controller: _tabController,
              children: [
                QuranSurahTab(
                  surahs: state.filteredSurahs,
                  // search: state.searchQuery,
                  // matchedPreviewBySurah: state.matchedPreviewBySurah,
                  offlineAvailabilityBySurah: state.offlineAvailabilityBySurah,
                  readAsText: readAsText,
                  isArabic: isArabic,
                  useCases: context.read<QuranCubit>().useCases,
                  onReload: () async {
                    context.read<QuranCubit>().refreshCachedState();
                  },
                ),
                QuranJuzTab(
                  useCases: context.read<QuranCubit>().useCases,
                  onReload: () async {
                    context.read<QuranCubit>().refreshCachedState();
                  },
                ),
                QuranPagesTab(useCases: context.read<QuranCubit>().useCases),
                QuranKhatmaTab(
                  lastRead: state.lastRead,
                  daysController: _daysController,
                  khatmaPlan: state.khatmaPlan,
                  onComputePlan: () {
                    final days = int.tryParse(_daysController.text) ?? 30;
                    context.read<QuranCubit>().computeKhatmaPlan(days);
                  },
                  onScheduleReminder: () async {
                    try {
                      await context.read<QuranCubit>().scheduleKhatmaReminder();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم جدولة التذكير بنجاح')),
                      );
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('فشل في جدولة التذكير')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
