part of 'quran_repository.dart';

extension QuranRepositoryCatalog on QuranRepository {
  Future<Map<int, String>> loadPageImageUrls() async {
    if (QuranRepository._cachedPageImageUrls != null) {
      return QuranRepository._cachedPageImageUrls!;
    }

    try {
      final remote =
          await _catalogRemote?.loadPageImageUrls() ?? const <int, String>{};
      QuranRepository._cachedPageImageUrls = remote;
      return QuranRepository._cachedPageImageUrls!;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'quran',
        'loadPageImageUrls',
        'Failed to load remote page image urls, using empty cache.',
        error: error,
      );
      AppLogger.error(
        'quran',
        'loadPageImageUrls',
        'Stack trace for remote page image urls failure.',
        error: error,
        stackTrace: stackTrace,
      );
      QuranRepository._cachedPageImageUrls = const <int, String>{};
      return QuranRepository._cachedPageImageUrls!;
    }
  }

  Future<List<QuranSurah>> loadSurahs() async {
    if (QuranRepository._cachedSurahs != null) {
      return QuranRepository._cachedSurahs!;
    }

    final result = await ContentFileLoader.loadAndParse<List<QuranSurah>>(
      fileCandidates: QuranRepository._downloadedQuranFileCandidates,
      type: DownloadContentType.quran,
      parser: _parseQuranSurahs,
    );

    if (result != null) {
      QuranRepository._cachedSurahs = result;
      return QuranRepository._cachedSurahs!;
    }

    final remote = await _loadSurahsFromRemote();
    if (remote.isNotEmpty) {
      QuranRepository._cachedSurahs = remote;
      return QuranRepository._cachedSurahs!;
    }

    QuranRepository._cachedSurahs = const [];
    return QuranRepository._cachedSurahs!;
  }

  Future<List<QuranSurah>> _loadSurahsFromRemote() async {
    try {
      return await _catalogRemote?.loadSurahs() ?? const [];
    } catch (error, stackTrace) {
      AppLogger.warning(
        'quran',
        'loadSurahsFromRemote',
        'Remote catalog load failed, falling back to local sources.',
        error: error,
      );
      AppLogger.error(
        'quran',
        'loadSurahsFromRemote',
        'Stack trace for remote surah load failure.',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<Map<int, String>> loadLocalPageImagePaths() async {
    if (QuranRepository._cachedLocalPageImagePaths != null) {
      return QuranRepository._cachedLocalPageImagePaths!;
    }

    if (!StorageService.quranContentDownloaded) {
      QuranRepository._cachedLocalPageImagePaths = const <int, String>{};
      return QuranRepository._cachedLocalPageImagePaths!;
    }

    final basePath = StorageService.downloadedContentBasePath;
    if (basePath == null || basePath.isEmpty) {
      QuranRepository._cachedLocalPageImagePaths = const <int, String>{};
      return QuranRepository._cachedLocalPageImagePaths!;
    }

    final quranDir = Directory(
      '$basePath${Platform.pathSeparator}${DownloadContentType.quran.value}',
    );
    if (!await quranDir.exists()) {
      QuranRepository._cachedLocalPageImagePaths = const <int, String>{};
      return QuranRepository._cachedLocalPageImagePaths!;
    }

    final map = <int, String>{};
    await for (final entity in quranDir.list()) {
      if (entity is! File) continue;
      final path = entity.path;
      final lower = path.toLowerCase();
      if (!lower.endsWith('.png') &&
          !lower.endsWith('.jpg') &&
          !lower.endsWith('.jpeg')) {
        continue;
      }

      final fileName = entity.uri.pathSegments.isEmpty
          ? ''
          : entity.uri.pathSegments.last;
      final withoutExt = fileName.split('.').first;
      final match = RegExp(r'(\d{1,3})').firstMatch(withoutExt);
      if (match == null) continue;
      final page = int.tryParse(match.group(1)!);
      if (page == null || page < 1 || page > 604) continue;

      map.putIfAbsent(page, () => path);
    }

    QuranRepository._cachedLocalPageImagePaths = map;
    return QuranRepository._cachedLocalPageImagePaths!;
  }

  List<QuranSurah>? peekCachedSurahs() {
    return QuranRepository._cachedSurahs;
  }

  Map<int, String>? peekCachedLocalPageImagePaths() {
    return QuranRepository._cachedLocalPageImagePaths;
  }

  Map<int, List<int>>? peekCachedPagesByJuz() {
    return QuranRepository._cachedPagesByJuz;
  }

  Map<int, List<int>>? peekCachedPagesBySurah() {
    return QuranRepository._cachedPagesBySurah;
  }

  Map<int, QuranPageMeta>? peekCachedPageMetaByPage() {
    return QuranRepository._cachedPageMetaByPage;
  }

  Map<int, QuranLastRead>? peekCachedLastReadByPage() {
    return QuranRepository._cachedLastReadByPage;
  }

  Future<void> _ensureIndexes() async {
    if (QuranRepository._cachedPagesByJuz != null &&
        QuranRepository._cachedPagesBySurah != null &&
        QuranRepository._cachedLastReadByPage != null &&
        QuranRepository._cachedPageMetaByPage != null) {
      return;
    }

    final surahs = await loadSurahs();
    final pagesByJuz = <int, Set<int>>{};
    final pagesBySurah = <int, Set<int>>{};
    final lastReadByPage = <int, QuranLastRead>{};
    final pageMetaByPage = <int, QuranPageMeta>{};

    for (final surah in surahs) {
      final surahPages = <int>{};
      for (final verse in surah.verses) {
        surahPages.add(verse.page);
        pagesByJuz.putIfAbsent(verse.juz, () => <int>{}).add(verse.page);
        pageMetaByPage.putIfAbsent(
          verse.page,
          () => QuranPageMeta(surahName: surah.nameAr, juzNumber: verse.juz),
        );
        lastReadByPage.putIfAbsent(
          verse.page,
          () => QuranLastRead(
            surahNumber: surah.number,
            verseNumber: verse.number,
            pageNumber: verse.page,
            juzNumber: verse.juz,
          ),
        );
      }
      pagesBySurah[surah.number] = surahPages;
    }

    QuranRepository._cachedPagesByJuz = {
      for (final entry in pagesByJuz.entries)
        entry.key: (entry.value.toList()..sort()),
    };
    QuranRepository._cachedPagesBySurah = {
      for (final entry in pagesBySurah.entries)
        entry.key: (entry.value.toList()..sort()),
    };
    QuranRepository._cachedLastReadByPage = lastReadByPage;
    QuranRepository._cachedPageMetaByPage = pageMetaByPage;
  }

  Future<List<int>> pagesForJuz(int juz) async {
    await _ensureIndexes();
    return QuranRepository._cachedPagesByJuz?[juz] ?? const <int>[];
  }

  Future<List<int>> pagesForSurah(int surahNumber) async {
    await _ensureIndexes();
    return QuranRepository._cachedPagesBySurah?[surahNumber] ?? const <int>[];
  }

  Future<Map<int, QuranPageMeta>> loadPageMetaByPage() async {
    await _ensureIndexes();
    return QuranRepository._cachedPageMetaByPage ??
        const <int, QuranPageMeta>{};
  }

  Future<QuranLastRead?> getLastReadForPage(int page) async {
    await _ensureIndexes();
    return QuranRepository._cachedLastReadByPage?[page];
  }

  /// Primes the static caches for the Quran catalog (surahs and local images).
  /// This should be called during app startup to ensure the Quran screen
  /// loads instantly when the user opens it.
  Future<void> primeCatalog() async {
    try {
      // Load surahs into cache
      await loadSurahs();
      // Load local image paths into cache
      await loadLocalPageImagePaths();
      // Pre-calculate indexes
      await _ensureIndexes();

      AppLogger.info(
        'quran',
        'primeCatalog',
        'Quran catalog primed successfully.',
      );
    } catch (error) {
      AppLogger.warning(
        'quran',
        'primeCatalog',
        'Failed to prime Quran catalog in background.',
        error: error,
      );
    }
  }

  KhatmaPlan calculateKhatmaPlan(int days) {
    final normalized = days <= 0 ? 1 : days;
    final pagesPerDay = (604 / normalized).ceil();
    final juzPerDay = double.parse((30 / normalized).toStringAsFixed(2));
    return KhatmaPlan(
      days: normalized,
      pagesPerDay: pagesPerDay,
      juzPerDay: juzPerDay,
    );
  }
}

List<QuranSurah> _parseQuranSurahs(String raw) {
  final data = jsonDecode(raw) as List<dynamic>;
  return data
      .map((e) => QuranSurah.fromJson(e as Map<String, dynamic>))
      .toList();
}
