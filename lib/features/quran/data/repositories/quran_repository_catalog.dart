part of 'quran_repository.dart';

extension QuranRepositoryCatalog on QuranRepository {
  Future<List<QuranSurah>> loadSurahs() async {
    if (QuranRepository._cachedSurahs != null) {
      return QuranRepository._cachedSurahs!;
    }

    final remote = await _loadSurahsFromRemote();
    if (remote.isNotEmpty) {
      QuranRepository._cachedSurahs = remote;
      return QuranRepository._cachedSurahs!;
    }

    return _loadSurahsFromAsset();
  }

  Future<List<QuranSurah>> _loadSurahsFromRemote() async {
    try {
      return await _catalogRemote?.loadSurahs() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  Future<List<QuranSurah>> _loadSurahsFromAsset() async {
    final raw = await rootBundle.loadString(QuranRepository._quranAssetPath);
    final data = jsonDecode(raw) as List<dynamic>;
    QuranRepository._cachedSurahs = data
        .map((e) => QuranSurah.fromJson(e as Map<String, dynamic>))
        .toList();
    return QuranRepository._cachedSurahs!;
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
