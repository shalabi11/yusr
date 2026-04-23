abstract class ContentDownloadNotifier {
  Future<void> showProgress({
    required int progressPercent,
    required int downloadedBytes,
    required int totalBytes,
    required int bytesPerSecond,
    required bool paused,
  });

  Future<void> clearProgress();
}
