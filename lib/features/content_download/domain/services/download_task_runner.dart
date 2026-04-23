import 'dart:async';
import 'dart:io';
import 'package:yusr_app/features/content_download/domain/entities/download_task_snapshot.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/services/retry_executor.dart';

typedef DownloadProgressCallback = void Function(DownloadTaskSnapshot snapshot);

class DownloadTaskRunner {
  final ContentDownloadRepository _repository;
  final RetryExecutor _retryExecutor;
  final RetryPolicy _retryPolicy;

  DownloadTaskRunner(
    this._repository, {
    RetryExecutor? retryExecutor,
    RetryPolicy retryPolicy = const RetryPolicy(maxAttempts: 3),
  }) : _retryExecutor = retryExecutor ?? const RetryExecutor(),
       _retryPolicy = retryPolicy;

  Future<bool> run(
    DownloadableContentFile file, {
    required String savedDir,
    required DownloadProgressCallback onProgress,
    bool pauseRequested = false,
  }) async {
    final outcome = await _retryExecutor.execute(
      policy: _retryPolicy,
      operation: (attempt) async {
        final taskId = await _repository.enqueueFileDownload(
          file: file,
          savedDir: savedDir,
        );

        if (taskId == null) {
          return attempt >= _retryPolicy.maxAttempts ? RetryDirective.abort : RetryDirective.retry;
        }

        final completed = await _monitorTask(
          file: file,
          taskId: taskId,
          savedDir: savedDir,
          onProgress: onProgress,
          pauseRequested: pauseRequested,
        );

        if (completed) return RetryDirective.success;
        if (pauseRequested) return RetryDirective.abort;
        
        return attempt >= _retryPolicy.maxAttempts ? RetryDirective.abort : RetryDirective.retry;
      },
    );

    return outcome == RetryDirective.success;
  }

  Future<bool> _monitorTask({
    required DownloadableContentFile file,
    required String taskId,
    required String savedDir,
    required DownloadProgressCallback onProgress,
    required bool pauseRequested,
  }) async {
    final completer = Completer<bool>();
    StreamSubscription? subscription;

    Future<void> processSnapshot(DownloadTaskSnapshot snapshot) async {
      if (completer.isCompleted) return;

      onProgress(snapshot);

      if (snapshot.state == DownloadTaskState.complete) {
        final localPath = '$savedDir${Platform.pathSeparator}${file.name}';
        await _repository.cacheDownloadedFile(file: file, localPath: localPath);
        completer.complete(true);
      } else if (snapshot.state == DownloadTaskState.failed ||
                 snapshot.state == DownloadTaskState.canceled ||
                 (pauseRequested && snapshot.state == DownloadTaskState.paused)) {
        completer.complete(false);
      }
    }

    final initial = await _repository.getTaskSnapshot(taskId);
    await processSnapshot(initial);
    
    if (completer.isCompleted) return completer.future;

    subscription = _repository.observeTaskSnapshot(taskId).listen(
      processSnapshot,
      onError: (_) => completer.complete(false),
      cancelOnError: true,
    );

    try {
      return await completer.future;
    } finally {
      await subscription.cancel();
    }
  }
}
