part of 'quran_repository.dart';

extension QuranRepositoryProgress on QuranRepository {
  Future<void> saveLastRead(QuranLastRead lastRead) async {
    await StorageService.saveData(
      QuranRepository._lastReadKey,
      lastRead.toJson(),
    );
    try {
      await _remoteSync?.saveLastRead(lastRead);
    } catch (error, stackTrace) {
      AppLogger.error(
        'quran',
        'saveLastRead',
        'Remote last-read sync failed; local value retained.',
        error: error,
        stackTrace: stackTrace,
      );
      // Keep local data as fallback if remote sync fails.
    }
  }

  QuranLastRead? getLastRead() {
    final data = StorageService.getData(QuranRepository._lastReadKey);
    if (data == null) return null;
    return QuranLastRead.fromJson(data as Map<String, dynamic>);
  }

  List<QuranBookmark> getBookmarks() {
    final data = StorageService.getData(QuranRepository._bookmarksKey);
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
      QuranRepository._bookmarksKey,
      bookmarks.map((e) => e.toJson()).toList(),
    );
    try {
      await _remoteSync?.saveBookmarks(bookmarks);
    } catch (error, stackTrace) {
      AppLogger.error(
        'quran',
        'addBookmark',
        'Remote bookmark sync failed; local bookmarks retained.',
        error: error,
        stackTrace: stackTrace,
      );
      // Keep local data as fallback if remote sync fails.
    }
    await saveLastRead(bookmarkData);
  }

  Future<void> removeBookmark(String id) async {
    final bookmarks = List<QuranBookmark>.from(getBookmarks());
    bookmarks.removeWhere((b) => b.id == id);
    await StorageService.saveData(
      QuranRepository._bookmarksKey,
      bookmarks.map((e) => e.toJson()).toList(),
    );
    try {
      await _remoteSync?.saveBookmarks(bookmarks);
    } catch (error, stackTrace) {
      AppLogger.error(
        'quran',
        'removeBookmark',
        'Remote bookmark delete sync failed; local bookmarks retained.',
        error: error,
        stackTrace: stackTrace,
      );
      // Keep local data as fallback if remote sync fails.
    }
  }
}
