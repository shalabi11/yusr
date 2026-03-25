import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';

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
    final surahController = TextEditingController();
    final juzController = TextEditingController();
    final pageController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'انتقال مباشر',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: surahController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رقم السورة (1-114)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: juzController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رقم الجزء (1-30)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رقم الصفحة (1-604)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final surahNumber = int.tryParse(
                      surahController.text.trim(),
                    );
                    if (surahNumber == null ||
                        surahNumber < 1 ||
                        surahNumber > 114) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('رقم السورة غير صالح')),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    final surah = _surahs.firstWhere(
                      (s) => s.number == surahNumber,
                      orElse: () => _surahs.first,
                    );

                    if (readAsText) {
                      await Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (_) => QuranReaderScreen(surah: surah),
                        ),
                      );
                    } else {
                      final pages = await _repo.pagesForSurah(surahNumber);
                      if (!mounted || pages.isEmpty) return;
                      await Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (_) => QuranPageViewerScreen(
                            initialPage: pages.first,
                            pages: pages,
                            showPageTitle: false,
                          ),
                        ),
                      );
                    }

                    await _load();
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('اذهب إلى السورة'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final juz = int.tryParse(juzController.text.trim());
                    if (juz == null || juz < 1 || juz > 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('رقم الجزء غير صالح')),
                      );
                      return;
                    }

                    final pages = await _repo.pagesForJuz(juz);
                    if (!context.mounted || !mounted || pages.isEmpty) return;
                    Navigator.pop(context);
                    await Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => QuranPageViewerScreen(
                          initialPage: pages.first,
                          pages: pages,
                          showPageTitle: false,
                        ),
                      ),
                    );
                    await _load();
                  },
                  icon: const Icon(Icons.auto_stories),
                  label: const Text('اذهب إلى الجزء'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final page = int.tryParse(pageController.text.trim());
                    if (page == null || page < 1 || page > 604) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('رقم الصفحة غير صالح')),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => QuranPageViewerScreen(
                          initialPage: page,
                          showPageTitle: false,
                        ),
                      ),
                    );
                    await _load();
                  },
                  icon: const Icon(Icons.find_in_page_outlined),
                  label: const Text('اذهب إلى الصفحة'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openBookmarksSheet(bool readAsText) async {
    final initialBookmarks = _repo.getBookmarks();
    if (initialBookmarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد علامات مرجعية محفوظة بعد')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bookmarks = List<QuranBookmark>.from(initialBookmarks);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'العلامات المرجعية',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: bookmarks.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final bookmark = bookmarks[index];
                          String? surahName;
                          for (final s in _surahs) {
                            if (s.number == bookmark.surahNumber) {
                              surahName = s.nameAr;
                              break;
                            }
                          }

                          return ListTile(
                            leading: const Icon(
                              Icons.bookmark,
                              color: AppColors.accent,
                            ),
                            title: Text(
                              surahName ?? 'سورة ${bookmark.surahNumber}',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                              ),
                            ),
                            subtitle: Text(
                              'آية ${bookmark.verseNumber} • صفحة ${bookmark.pageNumber} • جزء ${bookmark.juzNumber}',
                              style: TextStyle(
                                color: AppColors.textWhite.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            onTap: () async {
                              Navigator.pop(context);

                              if (readAsText) {
                                final surah = _surahs.firstWhere(
                                  (s) => s.number == bookmark.surahNumber,
                                  orElse: () => _surahs.first,
                                );
                                await Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        QuranReaderScreen(surah: surah),
                                  ),
                                );
                              } else {
                                await Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                    builder: (_) => QuranPageViewerScreen(
                                      initialPage: bookmark.pageNumber,
                                      showPageTitle: false,
                                    ),
                                  ),
                                );
                              }

                              await _load();
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                await _repo.removeBookmark(bookmark.id);
                                setModalState(
                                  () => bookmarks.removeWhere(
                                    (b) => b.id == bookmark.id,
                                  ),
                                );
                                if (bookmarks.isEmpty && context.mounted) {
                                  Navigator.pop(context);
                                }
                                if (mounted) {
                                  await _load();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSurahTab(bool readAsText) {
    final filtered = _surahs.where((s) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      final hasAyahMatch = s.verses.any((v) => v.textAr.contains(_search));
      return s.nameAr.contains(_search) ||
          s.nameEn.toLowerCase().contains(q) ||
          s.number.toString().contains(q) ||
          hasAyahMatch;
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) {
        final surah = filtered[index];
        return InkWell(
          onTap: () async {
            if (readAsText) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuranReaderScreen(surah: surah),
                ),
              );
            } else {
              final pages = await _repo.pagesForSurah(surah.number);
              if (!mounted || pages.isEmpty) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuranPageViewerScreen(
                    initialPage: pages.first,
                    pages: pages,
                    showPageTitle: false,
                  ),
                ),
              );
            }

            await _load();
          },
          borderRadius: BorderRadius.circular(16),
          child: GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameAr,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _search.isEmpty
                            ? '${surah.versesCount} آية'
                            : (() {
                                final match = surah.verses.where(
                                  (v) => v.textAr.contains(_search),
                                );
                                if (match.isEmpty) {
                                  return '${surah.versesCount} آية';
                                }
                                final preview = match.first.textAr;
                                final short = preview.length > 45
                                    ? '${preview.substring(0, 45)}...'
                                    : preview;
                                return 'نتيجة آية: $short';
                              })(),
                        style: TextStyle(
                          color: AppColors.textWhite.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: AppColors.accent),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: filtered.length,
    );
  }

  Widget _buildJuzTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 30,
      itemBuilder: (_, index) {
        final juz = index + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () async {
              final pages = await _repo.pagesForJuz(juz);
              if (!mounted || pages.isEmpty) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuranPageViewerScreen(
                    initialPage: pages.first,
                    pages: pages,
                    showPageTitle: false,
                  ),
                ),
              );
              await _load();
            },
            borderRadius: BorderRadius.circular(16),
            child: GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(
                    'الجزء $juz',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: 604,
      itemBuilder: (_, index) {
        final page = index + 1;
        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranPageViewerScreen(
                  initialPage: page,
                  showPageTitle: false,
                ),
              ),
            );
            await _load();
          },
          borderRadius: BorderRadius.circular(12),
          child: GlassContainer(
            borderRadius: 12,
            child: Center(
              child: Text(
                '$page',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKhatmaTab() {
    final progressValue = ((_lastRead?.pageNumber ?? 0) / 604)
        .clamp(0.0, 1.0)
        .toDouble();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'خطة الختمة',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تقدم الختمة',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progressValue,
                  backgroundColor: AppColors.textWhite.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'الصفحة الحالية: ${_lastRead?.pageNumber ?? 0} من 604 (${(progressValue * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: AppColors.textWhite.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الأيام',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _computeKhatmaPlan,
                child: const Text('احسب الخطة'),
              ),
              if (_khatmaPlan != null) ...[
                const SizedBox(height: 12),
                Text(
                  'الورد اليومي: ${_khatmaPlan!.pagesPerDay} صفحة',
                  style: const TextStyle(color: AppColors.textWhite),
                ),
                Text(
                  'تقريبًا: ${_khatmaPlan!.juzPerDay} جزء يوميًا',
                  style: const TextStyle(color: AppColors.textWhite),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _scheduleKhatmaReminder,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('جدولة تذكير يومي للختمة'),
                ),
              ],
            ],
          ),
        ),
      ],
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [AppColors.primaryDark, AppColors.background],
          ),
        ),
        child: SafeArea(
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
                          _buildSurahTab(readAsText),
                          _buildJuzTab(),
                          _buildPagesTab(),
                          _buildKhatmaTab(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
