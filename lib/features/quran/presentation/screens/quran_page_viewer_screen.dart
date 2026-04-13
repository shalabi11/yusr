import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/injection_container.dart';

import 'quran_page_viewer_widgets.dart';

part 'quran_page_viewer_actions.dart';
part 'quran_page_viewer_overlay.dart';

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

  void _replacePageMeta(Map<int, _PageMeta> map) {
    setState(() {
      _pageMetaByPage
        ..clear()
        ..addAll(map);
    });
  }

  void _markPageSaved(int page) {
    setState(() => _savedPages.add(page));
  }

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
