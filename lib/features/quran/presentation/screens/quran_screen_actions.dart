part of 'quran_screen.dart';

extension QuranScreenActions on QuranScreenState {
  Future<void> loadData() async {
    try {
      final surahs = await widget.useCases.loadSurahs();
      unawaited(_primeSmartSearchIndexSafely(surahs));
      final localPageImagePathsFuture = widget.useCases
          .loadLocalPageImagePaths();
      await widget.useCases.syncProgressOnStartup();
      final localPageImagePaths = await localPageImagePathsFuture;
      final lastRead = widget.useCases.getLastRead();
      _applyLoadedData(
        surahs,
        lastRead,
        localPageImagePaths: localPageImagePaths,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'quran',
        'loadData',
        'Failed to load Quran screen data; falling back to cached state.',
        error: error,
        stackTrace: stackTrace,
      );
      _applyLoadedData(const <QuranSurah>[], widget.useCases.getLastRead());
    }
  }

  Future<void> _primeSmartSearchIndexSafely(List<QuranSurah> surahs) async {
    try {
      await widget.useCases.primeSmartSearchIndex(surahs);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'quran',
        'primeSmartSearchIndex',
        'Skipping smart search indexing due to startup failure.',
        error: error,
      );
      AppLogger.error(
        'quran',
        'primeSmartSearchIndex',
        'Stack trace for smart search index startup failure.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void computeKhatmaPlan() {
    final days = int.tryParse(_daysController.text.trim()) ?? 30;
    _applyKhatmaPlan(days);
  }

  Future<void> scheduleKhatmaReminder() async {
    if (_khatmaPlan == null) return;
    await NotificationService.scheduleDailyNotification(
      id: 7001,
      title: 'تذكير الختمة',
      body:
          'ورد اليوم: ${_khatmaPlan!.pagesPerDay} صفحات (${_khatmaPlan!.juzPerDay} جزء)',
      time: const TimeOfDay(hour: 20, minute: 0),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت جدولة تذكير الختمة يوميًا')),
    );
  }
}
