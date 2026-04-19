import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> syncInitialState() async {
    if (_repository.isQuranContentDownloaded) {
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
        completedFiles: 0,
        totalFiles: 0,
      ),
    );

    try {
      _manifest = await _downloadContentUseCase(option.targetTypes);
      if (_manifest.isEmpty) {
        emit(
          state.copyWith(
            status: ContentDownloadStatus.failed,
            errorMessage:
                'لا توجد ملفات متاحة للتنزيل الآن. تحقق من جدول files في Supabase.',
          ),
        );
        return;
      }

      _manifest = [..._manifest]
        ..sort((a, b) => a.type.index.compareTo(b.type.index));
      _currentIndex = 0;
      _stableDownloadedBytes = 0;
      _pauseRequested = false;
      _currentTaskId = null;

      final totalBytes = _manifest.fold<int>(0, (sum, file) => sum + file.size);

      emit(
        state.copyWith(
          status: ContentDownloadStatus.downloading,
          selectedOption: option,
          totalBytes: totalBytes,
          totalFiles: _manifest.length,
          completedFiles: 0,
          downloadedBytes: 0,
          currentFileName: _manifest.first.name,
        ),
      );

      await _downloadRemainingFiles();
    } catch (e) {
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
      emit(state.copyWith(status: ContentDownloadStatus.paused));
    } catch (e) {
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
        ),
      );
      unawaited(_resumeCurrentFileThenContinue());
    } catch (e) {
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

      final taskId = await _repository.enqueueFileDownload(
        file: file,
        savedDir: savedDir,
      );

      if (taskId == null) {
        emit(
          state.copyWith(
            status: ContentDownloadStatus.failed,
            errorMessage: 'تعذر بدء تنزيل ${file.name}',
          ),
        );
        return;
      }

      _currentTaskId = taskId;
      final completed = await _monitorTask(
        file: file,
        taskId: taskId,
        savedDir: savedDir,
      );

      if (!completed) {
        return;
      }

      _currentIndex += 1;
      emit(
        state.copyWith(
          completedFiles: _currentIndex,
          currentFileName: _currentIndex < _manifest.length
              ? _manifest[_currentIndex].name
              : null,
        ),
      );
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
      ),
    );
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
    );

    if (!completed) {
      return;
    }

    _currentIndex += 1;
    emit(
      state.copyWith(
        completedFiles: _currentIndex,
        currentFileName: _currentIndex < _manifest.length
            ? _manifest[_currentIndex].name
            : null,
      ),
    );
    await _downloadRemainingFiles();
  }

  Future<bool> _monitorTask({
    required DownloadableContentFile file,
    required String taskId,
    required String savedDir,
  }) async {
    while (true) {
      if (_pauseRequested) {
        return false;
      }

      final snapshot = await _repository.getTaskSnapshot(taskId);
      final inFlightBytes = ((file.size * snapshot.progress) / 100).round();
      final currentDownloaded = _stableDownloadedBytes + inFlightBytes;

      emit(
        state.copyWith(
          downloadedBytes: currentDownloaded,
          currentFileName: file.name,
        ),
      );

      if (snapshot.state == DownloadTaskState.complete) {
        final localPath = '$savedDir${Platform.pathSeparator}${file.name}';
        await _repository.cacheDownloadedFile(file: file, localPath: localPath);
        _stableDownloadedBytes += file.size;
        emit(state.copyWith(downloadedBytes: _stableDownloadedBytes));
        return true;
      }

      if (snapshot.state == DownloadTaskState.failed ||
          snapshot.state == DownloadTaskState.canceled) {
        emit(
          state.copyWith(
            status: ContentDownloadStatus.failed,
            errorMessage: 'فشل تنزيل ${file.name}.',
          ),
        );
        return false;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }
}
