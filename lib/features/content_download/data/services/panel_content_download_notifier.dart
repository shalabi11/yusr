import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/features/content_download/domain/services/content_download_notifier.dart';

class PanelContentDownloadNotifier implements ContentDownloadNotifier {
  const PanelContentDownloadNotifier();

  @override
  Future<void> showProgress({
    required int progressPercent,
    required int downloadedBytes,
    required int totalBytes,
    required int bytesPerSecond,
    required bool paused,
  }) {
    return NotificationService.showContentDownloadProgress(
      progressPercent: progressPercent,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
      bytesPerSecond: bytesPerSecond,
      paused: paused,
    );
  }

  @override
  Future<void> clearProgress() {
    return NotificationService.clearContentDownloadProgress();
  }
}
