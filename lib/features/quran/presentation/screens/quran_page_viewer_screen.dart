import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';

import 'quran_page_viewer_widgets.dart';

part 'quran_page_viewer_actions.dart';
part 'quran_page_viewer_overlay.dart';

class QuranPageViewerScreen extends StatefulWidget {
  final int initialPage;
  final List<int>? pages;
  final bool showPageTitle;
  final QuranUseCases useCases;
  final String? entryHeroTag;
  final int? entrySurahNumber;
  final String? entrySurahName;

  const QuranPageViewerScreen({
    super.key,
    required this.initialPage,
    required this.useCases,
    this.pages,
    this.showPageTitle = false,
    this.entryHeroTag,
    this.entrySurahNumber,
    this.entrySurahName,
  });

  @override
  State<QuranPageViewerScreen> createState() => _QuranPageViewerScreenState();
}

class _QuranPageViewerScreenState extends State<QuranPageViewerScreen> {
  late final PageController _controller;
  late final List<int> _pages;
  late int _currentPage;
  bool _reverse = false;
  final Set<int> _savedPages = <int>{};
  final Map<int, QuranPageMeta> _pageMetaByPage = <int, QuranPageMeta>{};
  final Map<int, String> _pageImageUrlByPage = <int, String>{};
  final Map<int, String> _localPageImagePathByPage = <int, String>{};
  final Set<int> _prefetchedPages = <int>{};
  final List<int> _prefetchQueue = <int>[];

  static const int _maxPrefetchedPages = 5;
  static const int _maxPrefetchDistance = 2;

  void _evictPageImage(int page) {
    final provider = _providerForPage(page);
    if (provider == null) {
      return;
    }
    unawaited(provider.evict());
  }

  void _evictTrackedPageImages() {
    final pagesToEvict = <int>{..._prefetchedPages, _currentPage};
    for (final page in pagesToEvict) {
      _evictPageImage(page);
    }
    _prefetchedPages.clear();
    _prefetchQueue.clear();
  }

  void _replacePageMeta(Map<int, QuranPageMeta> map) {
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

  ImageProvider? _providerForPage(int page) {
    final localPath = _localPageImagePathByPage[page];
    final remoteUrl = _pageImageUrlByPage[page];

    if (localPath != null && localPath.isNotEmpty) {
      return FileImage(File(localPath));
    }
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return CachedNetworkImageProvider(remoteUrl);
    }
    return null;
  }

  void _trackPrefetch(int page) {
    if (_prefetchedPages.contains(page)) {
      return;
    }

    _prefetchedPages.add(page);
    _prefetchQueue.add(page);

    while (_prefetchQueue.length > _maxPrefetchedPages) {
      final oldest = _prefetchQueue.removeAt(0);
      _prefetchedPages.remove(oldest);
      _evictPageImage(oldest);
    }
  }

  void _precacheAroundPage(int currentPage) {
    final currentIndex = _pages.indexOf(currentPage);
    if (currentIndex < 0) {
      return;
    }

    final candidateIndexes = <int>{
      currentIndex,
      for (var offset = 1; offset <= _maxPrefetchDistance; offset++) ...[
        currentIndex + offset,
        currentIndex - offset,
      ],
    };

    for (final candidateIndex in candidateIndexes) {
      if (candidateIndex < 0 || candidateIndex >= _pages.length) {
        continue;
      }

      final page = _pages[candidateIndex];
      if (_prefetchedPages.contains(page)) {
        continue;
      }

      final provider = _providerForPage(page);
      if (provider == null) {
        continue;
      }

      _trackPrefetch(page);
      precacheImage(provider, context);
    }
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
    final bookmarks = widget.useCases.getBookmarks();
    _savedPages
      ..clear()
      ..addAll(bookmarks.map((b) => b.pageNumber));
    final lastReadPage = widget.useCases.getLastRead()?.pageNumber;
    if (lastReadPage != null) _savedPages.add(lastReadPage);
    _loadRemotePageImages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPageMetaByPage();
      _loadLocalPageImages();
      _precacheAroundPage(_currentPage);
    });
  }

  Future<void> _loadLocalPageImages() async {
    final map = await widget.useCases.loadLocalPageImagePaths();
    if (!mounted || map.isEmpty) return;
    _replaceLocalPageImagePaths(map);
    _precacheAroundPage(_currentPage);
  }

  Future<void> _loadRemotePageImages() async {
    final map = await widget.useCases.loadPageImageUrls();
    if (!mounted || map.isEmpty) return;
    _replacePageImageUrls(map);
    _precacheAroundPage(_currentPage);
  }

  @override
  void dispose() {
    _evictTrackedPageImages();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildQuranPageAppBar(
        context: context,
        // currentPage: _currentPage,
        // showPageTitle: widget.showPageTitle,
        // entryHeroTag: widget.entryHeroTag,
        // entrySurahNumber: widget.entrySurahNumber,
        // entrySurahName: widget.entrySurahName,
        savedPages: _savedPages,
        onBookmark: _bookmarkCurrentPage,
        onToggleReverse: () => setState(() => _reverse = !_reverse),
        currentPage: 1,
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
              _precacheAroundPage(page);
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
