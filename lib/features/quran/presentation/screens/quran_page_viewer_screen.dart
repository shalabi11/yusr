import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/injection_container.dart';

import 'quran_page_viewer_widgets.dart';

class QuranPageViewerScreen extends StatefulWidget {
  final int initialPage;
  final List<int>? pages;
  final bool showPageTitle;

  const QuranPageViewerScreen({
    super.key,
    required this.initialPage,
    this.pages,
    this.showPageTitle = false,
  });

  @override
  State<QuranPageViewerScreen> createState() => _QuranPageViewerScreenState();
}

class _QuranPageViewerScreenState extends State<QuranPageViewerScreen> {
  final QuranRepository _repo = sl<QuranRepository>();
  late final PageController _controller;
  late final List<int> _pages;
  late int _currentPage;
  bool _reverse = false;
  final Set<int> _savedPages = <int>{};
  final Map<int, _PageMeta> _pageMetaByPage = <int, _PageMeta>{};

  @override
  void initState() {
    super.initState();
    _pages = widget.pages == null || widget.pages!.isEmpty
        ? List<int>.generate(604, (i) => i + 1)
        : widget.pages!;
    final initial = _pages.contains(widget.initialPage)
        ? widget.initialPage
        : _pages.first;
    _currentPage = initial;
    _controller = PageController(initialPage: _pages.indexOf(initial));
    final bookmarks = _repo.getBookmarks();
    _savedPages
      ..clear()
      ..addAll(bookmarks.map((b) => b.pageNumber));
    final lastReadPage = _repo.getLastRead()?.pageNumber;
    if (lastReadPage != null) _savedPages.add(lastReadPage);
    _loadPageMetaByPage();
  }

  Future<void> _loadPageMetaByPage() async {
    final surahs = await _repo.loadSurahs();
    final map = <int, _PageMeta>{};
    for (final surah in surahs) {
      for (final verse in surah.verses) {
        map.putIfAbsent(
          verse.page,
          () => _PageMeta(surahName: surah.nameAr, juzNumber: verse.juz),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _pageMetaByPage
        ..clear()
        ..addAll(map);
    });
  }

  Widget _buildPageOverlay(int page) {
    final meta = _pageMetaByPage[page];
    final surahName = meta?.surahName ?? 'سورة غير محددة';
    final juzLabel = meta == null ? '-' : '${meta.juzNumber}';
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            // top: 1,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      surahName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.amiri(
                        color: AppColors.primaryDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'الجزء $juzLabel',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  page.toString(),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bookmarkCurrentPage() async {
    final fromPage = await _repo.getLastReadForPage(_currentPage);
    if (fromPage != null) {
      await _repo.addBookmark(fromPage);
    } else {
      final previous = _repo.getLastRead();
      await _repo.saveLastRead(
        QuranLastRead(
          surahNumber: previous?.surahNumber ?? 1,
          verseNumber: previous?.verseNumber ?? 1,
          pageNumber: _currentPage,
          juzNumber: previous?.juzNumber ?? 1,
        ),
      );
    }

    setState(() => _savedPages.add(_currentPage));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ المرجعية عند الصفحة $_currentPage')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildQuranPageAppBar(
        context: context,
        currentPage: _currentPage,
        showPageTitle: widget.showPageTitle,
        savedPages: _savedPages,
        onBookmark: _bookmarkCurrentPage,
        onToggleReverse: () => setState(() => _reverse = !_reverse),
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: PageView.builder(
            controller: _controller,
            reverse: _reverse,
            itemCount: _pages.length,
            onPageChanged: (index) =>
                setState(() => _currentPage = _pages[index]),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [buildQuranPageImage(page), _buildPageOverlay(page)],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PageMeta {
  final String surahName;
  final int juzNumber;

  const _PageMeta({required this.surahName, required this.juzNumber});
}
