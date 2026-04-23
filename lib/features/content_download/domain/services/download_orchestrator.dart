import 'dart:async';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/services/download_manifest_service.dart';
import 'package:yusr_app/features/content_download/domain/services/download_notification_throttler.dart';
import 'package:yusr_app/features/content_download/domain/services/download_progress_tracker.dart';
import 'package:yusr_app/features/content_download/domain/services/download_task_runner.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';

class DownloadOrchestrator {
  final ContentDownloadRepository _repository;
  final DownloadManifestService _manifestService;
  final DownloadTaskRunner _taskRunner;
  final DownloadProgressTracker _progressTracker;
  final DownloadNotificationThrottler _notificationThrottler;

  DownloadOrchestrator(
    this._repository,
    this._manifestService,
    this._taskRunner,
    this._progressTracker,
    this._notificationThrottler,
  );

  ContentDownloadState _state = const ContentDownloadState();
  List<DownloadableContentFile> _manifest = const [];
  int _currentIndex = 0;
  bool _pauseRequested = false;

  final StreamController<ContentDownloadState> _controller = StreamController.broadcast();
  Stream<ContentDownloadState> get stream => _controller.stream;
  ContentDownloadState get state => _state;

  void updateState(ContentDownloadState next) {
    _state = next;
    if (!_controller.isClosed) _controller.add(next);
  }

  Future<void> start(ContentDownloadOption option) async {
    if (_state.isDownloading || _state.isPreparing) return;

    updateState(_state.copyWith(
      status: ContentDownloadStatus.preparing,
      selectedOption: option,
      clearError: true,
      downloadedBytes: 0,
      totalBytes: 0,
      bytesPerSecond: 0,
      completedFiles: 0,
      totalFiles: 0,
    ));

    try {
      final manifestResult = await _manifestService.prepareManifest(option.targetTypes);
      
      if (manifestResult.isEmpty) {
        updateState(_state.copyWith(
          status: ContentDownloadStatus.failed,
          errorMessage: 'لا توجد ملفات متاحة للتنزيل الآن.',
        ));
        return;
      }

      _manifest = manifestResult.pendingFiles;
      _currentIndex = 0;
      _pauseRequested = false;
      _progressTracker.resetSession(stableDownloadedBytes: manifestResult.alreadyDownloadedBytes);
      _notificationThrottler.reset();

      if (_manifest.isEmpty) {
        await _finalize(option, manifestResult.totalBytes, manifestResult.totalFiles);
        return;
      }

      updateState(_state.copyWith(
        status: ContentDownloadStatus.downloading,
        totalBytes: manifestResult.totalBytes,
        totalFiles: manifestResult.totalFiles,
        completedFiles: manifestResult.alreadyCompletedFiles,
        downloadedBytes: manifestResult.alreadyDownloadedBytes,
        currentFileName: _manifest.first.name,
        bytesPerSecond: 0,
      ));
      
      await _notificationThrottler.notify(_state, paused: false, force: true);
      await _downloadLoop();
    } catch (e) {
      updateState(_state.copyWith(status: ContentDownloadStatus.failed, errorMessage: 'فشل بدء التحميل: $e'));
    }
  }

  Future<void> _downloadLoop() async {
    while (_currentIndex < _manifest.length && !_pauseRequested) {
      final file = _manifest[_currentIndex];
      final savedDir = await _repository.ensureTypeDirectory(file.type);

      final success = await _taskRunner.run(
        file,
        savedDir: savedDir,
        pauseRequested: _pauseRequested,
        onProgress: (snapshot) async {
          final progress = snapshot.progress.clamp(0, 100);
          if (_progressTracker.shouldEmitProgress(progress: progress, taskState: snapshot.state)) {
            final sample = _progressTracker.captureInFlight(
              fileSize: file.size,
              progress: progress,
              currentSpeed: _state.bytesPerSecond,
            );
            updateState(_state.copyWith(
              downloadedBytes: sample.downloadedBytes,
              currentFileName: file.name,
              bytesPerSecond: sample.bytesPerSecond,
            ));
            await _notificationThrottler.notify(_state, paused: false);
          }
        },
      );

      if (!success) {
        if (!_pauseRequested) {
           updateState(_state.copyWith(status: ContentDownloadStatus.failed, errorMessage: 'فشل تنزيل ${file.name}'));
        }
        return;
      }

      _currentIndex++;
      final sample = _progressTracker.markFileCompleted(fileSize: file.size);
      updateState(_state.copyWith(
        completedFiles: _state.completedFiles + 1,
        downloadedBytes: sample.downloadedBytes,
        currentFileName: _currentIndex < _manifest.length ? _manifest[_currentIndex].name : null,
        bytesPerSecond: 0,
      ));
      await _notificationThrottler.notify(_state, paused: false, force: true);
    }

    if (!_pauseRequested && _currentIndex >= _manifest.length) {
      await _finalize(_state.selectedOption!, _state.totalBytes, _state.totalFiles);
    }
  }

  Future<void> _finalize(ContentDownloadOption option, int totalBytes, int totalFiles) async {
    final basePath = await _repository.ensureBaseDirectory();
    await _repository.markSelectionCompleted(option: option, version: 1, basePath: basePath);

    updateState(_state.copyWith(
      status: ContentDownloadStatus.completed,
      downloadedBytes: totalBytes,
      completedFiles: totalFiles,
      bytesPerSecond: 0,
    ));
    await _notificationThrottler.clear();
  }

  Future<void> pause() async {
    _pauseRequested = true;
    updateState(_state.copyWith(status: ContentDownloadStatus.paused, bytesPerSecond: 0));
    await _notificationThrottler.notify(_state, paused: true, force: true);
  }

  Future<void> resume() async {
    if (_state.status != ContentDownloadStatus.paused) return;
    _pauseRequested = false;
    updateState(_state.copyWith(status: ContentDownloadStatus.downloading, clearError: true));
    await _notificationThrottler.notify(_state, paused: false, force: true);
    await _downloadLoop();
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
