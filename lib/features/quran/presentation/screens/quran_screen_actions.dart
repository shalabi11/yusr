part of 'quran_screen.dart';

extension QuranScreenActions on QuranScreenState {
  Future<void> loadData() async {
    try {
      final surahs = await _repo.loadSurahs();
      await _repo.syncProgressOnStartup();
      final lastRead = _repo.getLastRead();
      _applyLoadedData(surahs, lastRead);
    } catch (_) {
      _applyLoadedData(const <QuranSurah>[], _repo.getLastRead());
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
