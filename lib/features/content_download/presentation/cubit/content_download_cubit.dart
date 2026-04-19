import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_task_snapshot.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/usecases/download_content_use_case.dart';
import 'package:yusr_app/features/content_download/domain/usecases/pause_download_use_case.dart';
import 'package:yusr_app/features/content_download/domain/usecases/resume_download_use_case.dart';

import 'content_download_state.dart';

class ContentDownloadCubit extends Cubit<ContentDownloadState> {
  ContentDownloadCubit(
    this._repository,
    this._downloadContentUseCase,
    this._pauseDownloadUseCase,
    this._resumeDownloadUseCase,
  ) : super(const ContentDownloadState());

  static const int _manifestVersion = 1;

  final ContentDownloadRepository _repository;
  final DownloadContentUseCase _downloadContentUseCase;
  final PauseDownloadUseCase _pauseDownloadUseCase;
  final ResumeDownloadUseCase _resumeDownloadUseCase;

  List<DownloadableContentFile> _manifest = const [];
  int _currentIndex = 0;
  int _stableDownloadedBytes = 0;
  String? _currentTaskId;
  bool _pauseRequested = false;
  StreamSubscription<DownloadTaskSnapshot>? _taskSubscription;
  int _lastProgressPercent = -1;
  DateTime? _lastSpeedSampleAt;
  int _lastSpeedSampleBytes = 0;

  static const int _maxRetriesPerFile = 3;

  Future<void> syncInitialState() async {
    if (state.isPreparing || state.isDownloading || state.isPaused) {
      return;
    }

    if (_repository.isQuranContentDownloaded &&
        _repository.isAdhkarContentDownloaded) {
      unawaited(_clearPanelDownloadNotification());
      emit(
        state.copyWith(
          status: ContentDownloadStatus.completed,
          wasAlreadyDownloaded: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ContentDownloadStatus.initial,
        wasAlreadyDownloaded: false,
      ),
    );
    unawaited(_clearPanelDownloadNotification());
  }

  Future<void> startDownload(ContentDownloadOption option) async {
    if (state.status == ContentDownloadStatus.downloading ||
        state.status == ContentDownloadStatus.preparing) {
      return;
    }

    emit(
      state.copyWith(
        status: ContentDownloadStatus.preparing,
        selectedOption: option,
        clearError: true,
        downloadedBytes: 0,
        totalBytes: 0,
        bytesPerSecond: 0,
        completedFiles: 0,
        totalFiles: 0,
      ),
    );

    try {
      final requestedManifest = await _downloadContentUseCase(
        option.targetTypes,
      );
      if (requestedManifest.isEmpty) {
        emit(
          state.copyWith(
            status: ContentDownloadStatus.failed,
            errorMessage:
                'لا توجد ملفات متاحة للتنزيل الآن. تحقق من جدول files في Supabase.',
          ),
        );
        return;
      }

      final sortedManifest = [...requestedManifest]
        ..sort((a, b) => a.type.index.compareTo(b.type.index));

      final pending = <DownloadableContentFile>[];
      var downloadedBytes = 0;
      var completedFiles = 0;
      for (final file in sortedManifest) {
        final alreadyDownloaded = await _repository.isFileAlreadyDownloaded(
          file,
        );
        if (alreadyDownloaded) {
          downloadedBytes += file.size;
          completedFiles += 1;
          continue;
        }
        pending.add(file);
      }

      _manifest = pending;
      _currentIndex = 0;
      _stableDownloadedBytes = downloadedBytes;
      _pauseRequested = false;
      _currentTaskId = null;
      _lastSpeedSampleAt = DateTime.now();
      _lastSpeedSampleBytes = downloadedBytes;

      final totalBytes = sortedManifest.fold<int>(
        0,
        (sum, file) => sum + file.size,
      );
      final totalFiles = sortedManifest.length;

      if (_manifest.isEmpty) {
        final basePath = await _repository.ensureBaseDirectory();
        await _repository.markSelectionCompleted(
          option: option,
          version: _manifestVersion,
          basePath: basePath,
        );
        emit(
          state.copyWith(
            status: ContentDownloadStatus.completed,
            selectedOption: option,
            totalBytes: totalBytes,
            downloadedBytes: totalBytes,
            completedFiles: totalFiles,
            totalFiles: totalFiles,
            bytesPerSecond: 0,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ContentDownloadStatus.downloading,
          selectedOption: option,
          totalBytes: totalBytes,
          totalFiles: totalFiles,
          completedFiles: completedFiles,
          downloadedBytes: downloadedBytes,
          currentFileName: _manifest.first.name,
          bytesPerSecond: 0,
        ),
      );
      unawaited(_updatePanelDownloadNotification(paused: false));

      await _downloadRemainingFiles();
    } catch (e) {
      unawaited(_clearPanelDownloadNotification());
      emit(
        state.copyWith(
          status: ContentDownloadStatus.failed,
          errorMessage: 'فشل بدء التحميل: $e',
        ),
      );
    }
  }

  Future<void> pauseDownload() async {
    if (state.status != ContentDownloadStatus.downloading ||
        _currentTaskId == null) {
      return;
    }

    _pauseRequested = true;
    try {
      await _pauseDownloadUseCase(_currentTaskId!);
      emit(
        state.copyWith(status: ContentDownloadStatus.paused, bytesPerSecond: 0),
      );
      unawaited(_updatePanelDownloadNotification(paused: true));
    } catch (e) {
      unawaited(_clearPanelDownloadNotification());
      emit(
        state.copyWith(
          status: ContentDownloadStatus.failed,
          errorMessage: 'تعذر إيقاف التحميل مؤقتاً: $e',
        ),
      );
    }
  }

  Future<void> resumeDownload() async {
    if (state.status != ContentDownloadStatus.paused ||
        _currentTaskId == null) {
      return;
    }

    try {
      final resumedTaskId = await _resumeDownloadUseCase(_currentTaskId!);
      if (resumedTaskId == null) {
        emit(
          state.copyWith(
            status: ContentDownloadStatus.failed,
            errorMessage: 'تعذر استكمال التحميل. حاول إعادة المحاولة.',
          ),
        );
        return;
      }

      _currentTaskId = resumedTaskId;
      _pauseRequested = false;
      emit(
        state.copyWith(
          status: ContentDownloadStatus.downloading,
          clearError: true,
          bytesPerSecond: 0,
        ),
      );
      unawaited(_updatePanelDownloadNotification(paused: false));
      unawaited(_resumeCurrentFileThenContinue());
    } catch (e) {
      unawaited(_clearPanelDownloadNotification());
      emit(
        state.copyWith(
          status: ContentDownloadStatus.failed,
          errorMessage: 'فشل استكمال التحميل: $e',
        ),
      );
    }
  }

  Future<void> _downloadRemainingFiles() async {
    while (_currentIndex < _manifest.length) {
      final file = _manifest[_currentIndex];
      final savedDir = await _repository.ensureTypeDirectory(file.type);

      final completed = await _downloadFileWithRetries(file, savedDir);

      if (!completed) {
        return;
      }

      _currentIndex += 1;
      emit(
        state.copyWith(
          completedFiles: state.completedFiles + 1,
          currentFileName: _currentIndex < _manifest.length
              ? _manifest[_currentIndex].name
              : null,
          bytesPerSecond: 0,
        ),
      );
      unawaited(_updatePanelDownloadNotification(paused: false));
    }

    final option = state.selectedOption;
    if (option == null) return;

    final basePath = await _repository.ensureBaseDirectory();
    await _repository.markSelectionCompleted(
      option: option,
      version: _manifestVersion,
      basePath: basePath,
    );

    emit(
      state.copyWith(
        status: ContentDownloadStatus.completed,
        downloadedBytes: state.totalBytes,
        completedFiles: state.totalFiles,
        bytesPerSecond: 0,
      ),
    );
    unawaited(_clearPanelDownloadNotification());
  }

  Future<void> _resumeCurrentFileThenContinue() async {
    if (_currentTaskId == null || _currentIndex >= _manifest.length) {
      return;
    }

    final file = _manifest[_currentIndex];
    final savedDir = await _repository.ensureTypeDirectory(file.type);
    final completed = await _monitorTask(
      file: file,
      taskId: _currentTaskId!,
      savedDir: savedDir,
      emitFailureOnTerminalState: true,
    );

    if (!completed) {
      return;
    }

    _currentIndex += 1;
    emit(
      state.copyWith(
        completedFiles: state.completedFiles + 1,
        currentFileName: _currentIndex < _manifest.length
            ? _manifest[_currentIndex].name
            : null,
        bytesPerSecond: 0,
      ),
    );
    unawaited(_updatePanelDownloadNotification(paused: false));
    await _downloadRemainingFiles();
  }

  Future<bool> _downloadFileWithRetries(
    DownloadableContentFile file,
    String savedDir,
  ) async {
    var attempt = 0;
    while (attempt < _maxRetriesPerFile) {
      final taskId = await _repository.enqueueFileDownload(
        file: file,
        savedDir: savedDir,
      );

      if (taskId == null) {
        attempt += 1;
        if (attempt >= _maxRetriesPerFile) {
          emit(
            state.copyWith(
              status: ContentDownloadStatus.failed,
              errorMessage: 'تعذر بدء تنزيل ${file.name}',
            ),
          );
          unawaited(_clearPanelDownloadNotification());
          return false;
        }
        continue;
      }

      _currentTaskId = taskId;
      final shouldEmitFailure = attempt >= (_maxRetriesPerFile - 1);
      final completed = await _monitorTask(
        file: file,
        taskId: taskId,
        savedDir: savedDir,
        emitFailureOnTerminalState: shouldEmitFailure,
      );

      if (completed) {
        return true;
      }

      if (_pauseRequested || state.isPaused) {
        return false;
      }

      if (state.status == ContentDownloadStatus.failed && shouldEmitFailure) {
        return false;
      }

      attempt += 1;
    }

    return false;
  }

  Future<bool> _monitorTask({
    required DownloadableContentFile file,
    required String taskId,
    required String savedDir,
    required bool emitFailureOnTerminalState,
  }) async {
    _lastProgressPercent = -1;
    await _taskSubscription?.cancel();
    final completer = Completer<bool>();

    Future<void> handleSnapshot(DownloadTaskSnapshot snapshot) async {
      if (completer.isCompleted) {
        return;
      }

      if (_pauseRequested && snapshot.state == DownloadTaskState.paused) {
        await _taskSubscription?.cancel();
        completer.complete(false);
        return;
      }

      final progress = snapshot.progress.clamp(0, 100);
      final shouldEmitProgress =
          _lastProgressPercent < 0 ||
          (progress - _lastProgressPercent).abs() >= 1 ||
          snapshot.state == DownloadTaskState.complete;

      if (shouldEmitProgress) {
        _lastProgressPercent = progress;
        final inFlightBytes = ((file.size * progress) / 100).round();
        final currentDownloaded = _stableDownloadedBytes + inFlightBytes;
        final speed = _computeSpeedBytesPerSecond(currentDownloaded);
        emit(
          state.copyWith(
            downloadedBytes: currentDownloaded,
            currentFileName: file.name,
            bytesPerSecond: speed,
          ),
        );
        unawaited(_updatePanelDownloadNotification(paused: false));
      }

      if (snapshot.state == DownloadTaskState.complete) {
        final localPath = '$savedDir${Platform.pathSeparator}${file.name}';
        await _repository.cacheDownloadedFile(file: file, localPath: localPath);
        _stableDownloadedBytes += file.size;
        _lastSpeedSampleAt = DateTime.now();
        _lastSpeedSampleBytes = _stableDownloadedBytes;
        emit(
          state.copyWith(
            downloadedBytes: _stableDownloadedBytes,
            bytesPerSecond: 0,
          ),
        );
        unawaited(_updatePanelDownloadNotification(paused: false));
        await _taskSubscription?.cancel();
        completer.complete(true);
        return;
      }

      if (snapshot.state == DownloadTaskState.failed ||
          snapshot.state == DownloadTaskState.canceled) {
        if (emitFailureOnTerminalState) {
          emit(
            state.copyWith(
              status: ContentDownloadStatus.failed,
              errorMessage: 'فشل تنزيل ${file.name}.',
            ),
          );
          unawaited(_clearPanelDownloadNotification());
        }
        await _taskSubscription?.cancel();
        completer.complete(false);
      }
    }

    final initialSnapshot = await _repository.getTaskSnapshot(taskId);
    await handleSnapshot(initialSnapshot);
    if (completer.isCompleted) {
      return completer.future;
    }

    _taskSubscription = _repository
        .observeTaskSnapshot(taskId)
        .listen(
          (snapshot) {
            unawaited(handleSnapshot(snapshot));
          },
          onError: (Object error) {
            if (completer.isCompleted) {
              return;
            }
            if (emitFailureOnTerminalState) {
              emit(
                state.copyWith(
                  status: ContentDownloadStatus.failed,
                  errorMessage: 'فشل تنزيل ${file.name}: $error',
                ),
              );
              unawaited(_clearPanelDownloadNotification());
            }
            completer.complete(false);
          },
          cancelOnError: true,
        );

    return completer.future;
  }

  int _computeSpeedBytesPerSecond(int currentDownloadedBytes) {
    final now = DateTime.now();
    final previousAt = _lastSpeedSampleAt;
    if (previousAt == null) {
      _lastSpeedSampleAt = now;
      _lastSpeedSampleBytes = currentDownloadedBytes;
      return 0;
    }

    final elapsedMs = now.difference(previousAt).inMilliseconds;
    if (elapsedMs < 600) {
      return state.bytesPerSecond;
    }

    final byteDelta = currentDownloadedBytes - _lastSpeedSampleBytes;
    _lastSpeedSampleAt = now;
    _lastSpeedSampleBytes = currentDownloadedBytes;
    if (byteDelta <= 0) {
      return 0;
    }

    return (byteDelta * 1000 / elapsedMs).round();
  }

  Future<void> _updatePanelDownloadNotification({required bool paused}) {
    final totalBytes = state.totalBytes;
    final percent = totalBytes <= 0
        ? 0
        : ((state.downloadedBytes * 100) / totalBytes).round();
    return NotificationService.showContentDownloadProgress(
      progressPercent: percent,
      downloadedBytes: state.downloadedBytes,
      totalBytes: totalBytes,
      bytesPerSecond: paused ? 0 : state.bytesPerSecond,
      paused: paused,
    );
  }

  Future<void> _clearPanelDownloadNotification() {
    return NotificationService.clearContentDownloadProgress();
  }

  @override
  Future<void> close() async {
    await _taskSubscription?.cancel();
    return super.close();
  }
}
