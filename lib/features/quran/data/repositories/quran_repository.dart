import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yusr_app/core/services/storage_service.dart';

import '../models/quran_models.dart';

class QuranRepository {
  static const String _quranAssetPath = 'assets/data/mainDataQuran.json';
  static const String _lastReadKey = 'quran_last_read';
  static const String _bookmarksKey = 'quran_bookmarks';
  static List<QuranSurah>? _cachedSurahs;

  Future<List<QuranSurah>> loadSurahs() async {
    if (_cachedSurahs != null) return _cachedSurahs!;

    final raw = await rootBundle.loadString(_quranAssetPath);
    final data = jsonDecode(raw) as List<dynamic>;
    _cachedSurahs = data
        .map((e) => QuranSurah.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedSurahs!;
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

  Future<void> saveLastRead(QuranLastRead lastRead) async {
    await StorageService.saveData(_lastReadKey, lastRead.toJson());
  }

  QuranLastRead? getLastRead() {
    final data = StorageService.getData(_lastReadKey);
    if (data == null) return null;
    return QuranLastRead.fromJson(data as Map<String, dynamic>);
  }

  List<QuranBookmark> getBookmarks() {
    final data = StorageService.getData(_bookmarksKey);
    if (data == null) return [];
    final list = data as List<dynamic>;
    return list
        .map((e) => QuranBookmark.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addBookmark(QuranLastRead bookmarkData) async {
    final bookmarks = List<QuranBookmark>.from(getBookmarks());
    final already = bookmarks.any(
      (b) =>
          b.surahNumber == bookmarkData.surahNumber &&
          b.verseNumber == bookmarkData.verseNumber &&
          b.pageNumber == bookmarkData.pageNumber,
    );
    if (already) {
      await saveLastRead(bookmarkData);
      return;
    }

    bookmarks.insert(
      0,
      QuranBookmark(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        surahNumber: bookmarkData.surahNumber,
        verseNumber: bookmarkData.verseNumber,
        pageNumber: bookmarkData.pageNumber,
        juzNumber: bookmarkData.juzNumber,
        createdAt: DateTime.now(),
      ),
    );

    await StorageService.saveData(
      _bookmarksKey,
      bookmarks.map((e) => e.toJson()).toList(),
    );
    await saveLastRead(bookmarkData);
  }

  Future<void> removeBookmark(String id) async {
    final bookmarks = List<QuranBookmark>.from(getBookmarks());
    bookmarks.removeWhere((b) => b.id == id);
    await StorageService.saveData(
      _bookmarksKey,
      bookmarks.map((e) => e.toJson()).toList(),
    );
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
