import 'package:yusr_app/features/content_download/domain/entities/download_task_snapshot.dart';

class DownloadProgressSample {
  const DownloadProgressSample({
    required this.downloadedBytes,
    required this.bytesPerSecond,
  });

  final int downloadedBytes;
  final int bytesPerSecond;
}

class DownloadProgressTracker {
  DownloadProgressTracker({
    this.emitInterval = const Duration(milliseconds: 250),
    this.progressDeltaThreshold = 2,
    this.speedSampleInterval = const Duration(milliseconds: 600),
  });

  final Duration emitInterval;
  final int progressDeltaThreshold;
  final Duration speedSampleInterval;

  int _stableDownloadedBytes = 0;
  int _lastProgressPercent = -1;
  DateTime? _lastProgressEmitAt;
  DateTime? _lastSpeedSampleAt;
  int _lastSpeedSampleBytes = 0;

  int get stableDownloadedBytes => _stableDownloadedBytes;

  void resetSession({required int stableDownloadedBytes}) {
    _stableDownloadedBytes = stableDownloadedBytes;
    _lastSpeedSampleAt = DateTime.now();
    _lastSpeedSampleBytes = stableDownloadedBytes;
    resetTaskWindow();
  }

  void resetTaskWindow() {
    _lastProgressPercent = -1;
    _lastProgressEmitAt = null;
  }

  bool shouldEmitProgress({
    required int progress,
    required DownloadTaskState taskState,
  }) {
    final now = DateTime.now();
    final reachedInterval =
        _lastProgressEmitAt == null ||
        now.difference(_lastProgressEmitAt!) >= emitInterval;

    return _lastProgressPercent < 0 ||
        (progress - _lastProgressPercent).abs() >= progressDeltaThreshold ||
        taskState == DownloadTaskState.complete ||
        reachedInterval;
  }

  DownloadProgressSample captureInFlight({
    required int fileSize,
    required int progress,
    required int currentSpeed,
  }) {
    _lastProgressPercent = progress;
    _lastProgressEmitAt = DateTime.now();

    final inFlightBytes = ((fileSize * progress) / 100).round();
    final currentDownloaded = _stableDownloadedBytes + inFlightBytes;
    final speed = _computeSpeedBytesPerSecond(
      currentDownloadedBytes: currentDownloaded,
      fallbackSpeed: currentSpeed,
    );

    return DownloadProgressSample(
      downloadedBytes: currentDownloaded,
      bytesPerSecond: speed,
    );
  }

  DownloadProgressSample markFileCompleted({required int fileSize}) {
    _stableDownloadedBytes += fileSize;
    _lastSpeedSampleAt = DateTime.now();
    _lastSpeedSampleBytes = _stableDownloadedBytes;

    return DownloadProgressSample(
      downloadedBytes: _stableDownloadedBytes,
      bytesPerSecond: 0,
    );
  }

  int _computeSpeedBytesPerSecond({
    required int currentDownloadedBytes,
    required int fallbackSpeed,
  }) {
    final now = DateTime.now();
    final previousAt = _lastSpeedSampleAt;
    if (previousAt == null) {
      _lastSpeedSampleAt = now;
      _lastSpeedSampleBytes = currentDownloadedBytes;
      return 0;
    }

    final elapsedMs = now.difference(previousAt).inMilliseconds;
    if (elapsedMs < speedSampleInterval.inMilliseconds) {
      return fallbackSpeed;
    }

    final byteDelta = currentDownloadedBytes - _lastSpeedSampleBytes;
    _lastSpeedSampleAt = now;
    _lastSpeedSampleBytes = currentDownloadedBytes;
    if (byteDelta <= 0) {
      return 0;
    }

    return (byteDelta * 1000 / elapsedMs).round();
  }
}
