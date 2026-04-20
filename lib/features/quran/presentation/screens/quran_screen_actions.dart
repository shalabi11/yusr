part of 'quran_screen.dart';

extension QuranScreenActions on QuranScreenState {
  Future<void> loadData() async {
    try {
      final surahs = await widget.useCases.loadSurahs();
      unawaited(widget.useCases.primeSmartSearchIndex(surahs));
      final localPageImagePaths = await widget.useCases
          .loadLocalPageImagePaths();
      await widget.useCases.syncProgressOnStartup();
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
