import 'package:yusr_app/features/content_download/domain/services/content_download_notifier.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';

class DownloadNotificationThrottler {
  DownloadNotificationThrottler(
    this._notifier, {
    this.notificationInterval = const Duration(seconds: 1),
  });

  final ContentDownloadNotifier _notifier;
  final Duration notificationInterval;

  DateTime? _lastNotificationAt;
  int _lastNotifiedPercent = -1;

  void reset() {
    _lastNotificationAt = null;
    _lastNotifiedPercent = -1;
  }

  Future<void> notify(
    ContentDownloadState state, {
    required bool paused,
    bool force = false,
  }) {
    final totalBytes = state.totalBytes;
    final percent = totalBytes <= 0
        ? 0
        : ((state.downloadedBytes * 100) / totalBytes).round();

    final now = DateTime.now();
    final canNotifyByTime =
        _lastNotificationAt == null ||
        now.difference(_lastNotificationAt!) >= notificationInterval;
    final hasMeaningfulProgress = percent != _lastNotifiedPercent;

    if (!force && !canNotifyByTime && !hasMeaningfulProgress) {
      return Future<void>.value();
    }

    _lastNotificationAt = now;
    _lastNotifiedPercent = percent;

    return _notifier.showProgress(
      progressPercent: percent,
      downloadedBytes: state.downloadedBytes,
      totalBytes: totalBytes,
      bytesPerSecond: paused ? 0 : state.bytesPerSecond,
      paused: paused,
    );
  }

  Future<void> clear() {
    reset();
    return _notifier.clearProgress();
  }
}
