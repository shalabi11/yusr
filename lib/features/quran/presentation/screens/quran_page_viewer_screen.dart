import 'dart:io';

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
  final Map<int, String> _pageImageUrlByPage = <int, String>{};
  final Map<int, String> _localPageImagePathByPage = <int, String>{};

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

  void _replacePageImageUrls(Map<int, String> map) {
    setState(() {
      _pageImageUrlByPage
        ..clear()
        ..addAll(map);
    });
  }

  void _replaceLocalPageImagePaths(Map<int, String> map) {
    setState(() {
      _localPageImagePathByPage
        ..clear()
        ..addAll(map);
    });
  }

  void _precacheNextPage(int currentPage) {
    final currentIndex = _pages.indexOf(currentPage);
    if (currentIndex < 0 || currentIndex + 1 >= _pages.length) {
      return;
    }

    final nextPage = _pages[currentIndex + 1];
    final localPath = _localPageImagePathByPage[nextPage];
    final remoteUrl = _pageImageUrlByPage[nextPage];

    ImageProvider? provider;
    if (localPath != null && localPath.isNotEmpty) {
      provider = FileImage(File(localPath));
    } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
      provider = NetworkImage(remoteUrl);
    }

    if (provider == null) return;
    precacheImage(provider, context);
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
    _loadLocalPageImages();
    _loadRemotePageImages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _precacheNextPage(_currentPage);
    });
  }

  Future<void> _loadLocalPageImages() async {
    final map = await _repo.loadLocalPageImagePaths();
    if (!mounted || map.isEmpty) return;
    _replaceLocalPageImagePaths(map);
    _precacheNextPage(_currentPage);
  }

  Future<void> _loadRemotePageImages() async {
    final map = await _repo.loadPageImageUrls();
    if (!mounted || map.isEmpty) return;
    _replacePageImageUrls(map);
    _precacheNextPage(_currentPage);
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
            onPageChanged: (index) {
              final page = _pages[index];
              setState(() => _currentPage = page);
              _precacheNextPage(page);
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  buildQuranPageImage(
                    context,
                    page,
                    localImagePath: _localPageImagePathByPage[page],
                    remoteImageUrl: _pageImageUrlByPage[page],
                  ),
                  _buildPageOverlay(page),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
