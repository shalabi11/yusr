part of 'quran_repository.dart';

extension QuranRepositoryStartupSync on QuranRepository {
  Future<void> syncProgressOnStartup() async {
    if (_startupSynced) return;
    _startupSynced = true;

    final localLastRead = getLastRead();
    final localBookmarks = getBookmarks();

    try {
      final remoteLastRead = await _remoteSync?.loadLastRead();
      final remoteBookmarks = await _remoteSync?.loadBookmarks();

      final hasRemoteData =
          remoteLastRead != null ||
          (remoteBookmarks != null && remoteBookmarks.isNotEmpty);

      if (!hasRemoteData) {
        if (localLastRead != null) {
          await _remoteSync?.saveLastRead(localLastRead);
        }
        if (localBookmarks.isNotEmpty) {
          await _remoteSync?.saveBookmarks(localBookmarks);
        }
        return;
      }

      if (remoteLastRead != null) {
        await StorageService.saveData(
          QuranRepository._lastReadKey,
          remoteLastRead.toJson(),
        );
      }

      if (remoteBookmarks != null && remoteBookmarks.isNotEmpty) {
        await StorageService.saveData(
          QuranRepository._bookmarksKey,
          remoteBookmarks.map((e) => e.toJson()).toList(),
        );
      }
    } catch (_) {
      // Keep local data as fallback if startup remote sync fails.
    }
  }
}
