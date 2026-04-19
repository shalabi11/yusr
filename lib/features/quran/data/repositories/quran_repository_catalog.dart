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
    } catch (_) {
      QuranRepository._cachedPageImageUrls = const <int, String>{};
      return QuranRepository._cachedPageImageUrls!;
    }
  }

  Future<List<QuranSurah>> loadSurahs() async {
    if (QuranRepository._cachedSurahs != null) {
      return QuranRepository._cachedSurahs!;
    }

    final downloaded = await _loadSurahsFromDownloadedFile();
    if (downloaded.isNotEmpty) {
      QuranRepository._cachedSurahs = downloaded;
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
    } catch (_) {
      return const [];
    }
  }

  Future<List<QuranSurah>> _loadSurahsFromDownloadedFile() async {
    if (!StorageService.quranContentDownloaded) {
      return const [];
    }

    final basePath = StorageService.downloadedContentBasePath;
    if (basePath == null || basePath.isEmpty) {
      return const [];
    }

    final quranDir = Directory(
      '$basePath${Platform.pathSeparator}${DownloadContentType.quran.value}',
    );
    if (!await quranDir.exists()) {
      return const [];
    }

    for (final fileName in QuranRepository._downloadedQuranFileCandidates) {
      final candidate = File(
        '${quranDir.path}${Platform.pathSeparator}$fileName',
      );
      final parsed = await _parseSurahsFromFile(candidate);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    await for (final entity in quranDir.list()) {
      if (entity is! File || !entity.path.toLowerCase().endsWith('.json')) {
        continue;
      }
      final parsed = await _parseSurahsFromFile(entity);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    return const [];
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

  Future<List<QuranSurah>> _parseSurahsFromFile(File file) async {
    try {
      if (!await file.exists()) {
        return const [];
      }
      final raw = await file.readAsString();
      return compute(_parseQuranSurahs, raw);
    } catch (_) {
      return const [];
    }
  }

  Future<List<int>> pagesForJuz(int juz) async {
    final surahs = await loadSurahs();
    final pages = <int>{};
    for (final surah in surahs) {
      for (final verse in surah.verses) {
        if (verse.juz == juz) {
          pages.add(verse.page);
        }
      }
    }
    final sorted = pages.toList()..sort();
    return sorted;
  }

  Future<List<int>> pagesForSurah(int surahNumber) async {
    final surahs = await loadSurahs();
    final surah = surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => surahs.first,
    );

    final pages = surah.verses.map((v) => v.page).toSet().toList()..sort();
    return pages;
  }

  Future<QuranLastRead?> getLastReadForPage(int page) async {
    final surahs = await loadSurahs();
    for (final surah in surahs) {
      for (final verse in surah.verses) {
        if (verse.page == page) {
          return QuranLastRead(
            surahNumber: surah.number,
            verseNumber: verse.number,
            pageNumber: page,
            juzNumber: verse.juz,
          );
        }
      }
    }
    return null;
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
