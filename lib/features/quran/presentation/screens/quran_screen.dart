import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_juz_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_bookmarks_sheet.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_khatma_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_pages_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_quick_jump_sheet.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_surah_tab.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  final QuranRepository _repo = QuranRepository();
  late final TabController _tabController;
  late final TextEditingController _daysController;
  late final TextEditingController _searchController;
  List<QuranSurah> _surahs = const [];
  String _search = '';
  bool _loading = true;
  QuranLastRead? _lastRead;
  KhatmaPlan? _khatmaPlan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _daysController = TextEditingController(text: '30');
    _searchController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final surahs = await _repo.loadSurahs();
    final lastRead = _repo.getLastRead();
    setState(() {
      _surahs = surahs;
      _lastRead = lastRead;
      _loading = false;
      _khatmaPlan = _repo.calculateKhatmaPlan(30);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _daysController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _computeKhatmaPlan() {
    final days = int.tryParse(_daysController.text.trim()) ?? 30;
    setState(() {
      _khatmaPlan = _repo.calculateKhatmaPlan(days);
    });
  }

  Future<void> _scheduleKhatmaReminder() async {
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

  Future<void> _openLastRead(bool readAsText) async {
    if (_lastRead == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد موضع قراءة محفوظ بعد')),
      );
      return;
    }

    if (readAsText) {
      final surah = _surahs.firstWhere(
        (s) => s.number == _lastRead!.surahNumber,
        orElse: () => _surahs.first,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)),
      );
    } else {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranPageViewerScreen(
            initialPage: _lastRead!.pageNumber,
            showPageTitle: false,
          ),
        ),
      );
    }

    await _load();
  }

  Future<void> _openQuickJumpSheet(bool readAsText) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuranQuickJumpSheet(
        parentContext: context,
        surahs: _surahs,
        readAsText: readAsText,
        repo: _repo,
        onReload: _load,
      ),
    );
  }

  Future<void> _openBookmarksSheet(bool readAsText) async {
    final bookmarks = _repo.getBookmarks();
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
        repo: _repo,
        surahs: _surahs,
        onReload: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readAsText = context.watch<SettingsCubit>().state.quranReadAsText;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
              await _load();
            },
            icon: const Icon(Icons.menu_book),
            tooltip: 'ابدأ من أول صفحة',
          ),
          IconButton(
            onPressed: () => _openQuickJumpSheet(readAsText),
            icon: const Icon(Icons.travel_explore),
            tooltip: 'انتقال مباشر',
          ),
          IconButton(
            onPressed: () => _openBookmarksSheet(readAsText),
            icon: const Icon(Icons.bookmarks),
            tooltip: 'العلامات المرجعية',
          ),
          IconButton(
            onPressed: () => _openLastRead(readAsText),
            icon: const Icon(Icons.bookmark),
            tooltip: 'الرجوع لآخر موضع',
          ),
        ],
      ),
      body: AppRadialBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _search = value.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث بالسورة أو نص الآية...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _search = '');
                                },
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
                          onReload: _load,
                        ),
                        QuranJuzTab(repo: _repo, onReload: _load),
                        const QuranPagesTab(),
                        QuranKhatmaTab(
                          lastRead: _lastRead,
                          daysController: _daysController,
                          khatmaPlan: _khatmaPlan,
                          onComputePlan: _computeKhatmaPlan,
                          onScheduleReminder: _scheduleKhatmaReminder,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
