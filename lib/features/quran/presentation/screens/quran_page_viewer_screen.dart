import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';

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
  final QuranRepository _repo = QuranRepository();
  late final PageController _controller;
  late int _currentPage;
  late final List<int> _pages;
  bool _reverse = false;
  final Set<int> _savedPages = <int>{};

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
    _hydrateSavedPages();
  }

  void _hydrateSavedPages() {
    final bookmarks = _repo.getBookmarks();
    final saved = bookmarks.map((b) => b.pageNumber);
    final lastReadPage = _repo.getLastRead()?.pageNumber;

    setState(() {
      _savedPages
        ..clear()
        ..addAll(saved);
      if (lastReadPage != null) {
        _savedPages.add(lastReadPage);
      }
    });
  }

  Future<void> _bookmarkCurrentPage() async {
    final fromPage = await _repo.getLastReadForPage(_currentPage);
    if (fromPage != null) {
      await _repo.addBookmark(fromPage);
    } else {
      // Fallback: persist current page as last-read even if page->verse mapping is unavailable.
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

    setState(() {
      _savedPages.add(_currentPage);
    });
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
      appBar: AppBar(
        // backgroundColor: AppColors.primary.withValues(alpha: 0.8),
        title: widget.showPageTitle ? Text('الصفحة $_currentPage') : null,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        actionsIconTheme: const IconThemeData(color: AppColors.primaryDark),
        actions: [
          IconButton(
            onPressed: _bookmarkCurrentPage,
            icon: Icon(
              _savedPages.contains(_currentPage)
                  ? Icons.bookmark_added
                  : Icons.bookmark_add_outlined,
              color: _savedPages.contains(_currentPage)
                  ? Colors.green.shade700
                  : AppColors.primaryDark,
            ),
            tooltip: 'حفظ مرجعية القراءة',
          ),
          IconButton(
            onPressed: () => setState(() => _reverse = !_reverse),
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'تبديل اتجاه التقليب',
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: PageView.builder(
            controller: _controller,
            reverse: _reverse,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = _pages[index];
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.asset(
                    'assets/quran_images/$page.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'تعذر تحميل الصورة',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
