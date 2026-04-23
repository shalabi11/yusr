import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_task_snapshot.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/services/download_orchestrator.dart';
import 'package:yusr_app/features/content_download/domain/services/content_download_notifier.dart';
import 'package:yusr_app/features/content_download/domain/services/download_manifest_service.dart';
import 'package:yusr_app/features/content_download/domain/services/download_notification_throttler.dart';
import 'package:yusr_app/features/content_download/domain/services/download_progress_tracker.dart';
import 'package:yusr_app/features/content_download/domain/services/download_task_runner.dart';
import 'package:yusr_app/features/content_download/domain/usecases/download_content_use_case.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';

class _FakeContentDownloadNotifier implements ContentDownloadNotifier {
  @override
  Future<void> clearProgress() async {}

  @override
  Future<void> showProgress({
    required int progressPercent,
    required int downloadedBytes,
    required int totalBytes,
    required int bytesPerSecond,
    required bool paused,
  }) async {}
}

class FakeContentDownloadRepository implements ContentDownloadRepository {
  final Map<String, StreamController<DownloadTaskSnapshot>> _controllers =
      <String, StreamController<DownloadTaskSnapshot>>{};

  bool shouldFailTask = false;
  bool completedMarked = false;

  @override
  Future<String> ensureBaseDirectory() async => '/tmp';

  @override
  Future<String> ensureTypeDirectory(DownloadContentType type) async => '/tmp';

  @override
  Future<String?> enqueueFileDownload({
    required DownloadableContentFile file,
    required String savedDir,
  }) async {
    const taskId = 'task-1';
    _controllers.putIfAbsent(taskId, () => StreamController.broadcast());
    return taskId;
  }

  @override
  Future<List<DownloadableContentFile>> fetchManifest({
    required Set<DownloadContentType> targetTypes,
  }) async {
    return const <DownloadableContentFile>[
      DownloadableContentFile(
        id: '1',
        name: 'quran.json',
        type: DownloadContentType.quran,
        url: 'https://example.com/quran.json',
        size: 100,
      ),
    ];
  }

  @override
  Future<DownloadTaskSnapshot> getTaskSnapshot(String taskId) async {
    if (shouldFailTask) {
      return const DownloadTaskSnapshot(
        state: DownloadTaskState.failed,
        progress: 0,
      );
    }
    return const DownloadTaskSnapshot(
      state: DownloadTaskState.enqueued,
      progress: 0,
    );
  }

  @override
  Stream<DownloadTaskSnapshot> observeTaskSnapshot(String taskId) {
    return _controllers[taskId]!.stream;
  }

  @override
  Future<void> pauseTask(String taskId) async {}

  @override
  Future<String?> resumeTask(String taskId) async => taskId;

  @override
  Future<void> cacheDownloadedFile({
    required DownloadableContentFile file,
    required String localPath,
  }) async {}

  @override
  Future<bool> isFileAlreadyDownloaded(DownloadableContentFile file) async =>
      false;

  @override
  Future<void> markSelectionCompleted({
    required ContentDownloadOption option,
    required int version,
    required String basePath,
  }) async {
    completedMarked = true;
  }

  @override
  bool get isAdhkarContentDownloaded => false;

  @override
  bool get isContentDownloaded => false;

  @override
  bool get isQuranContentDownloaded => false;

  @override
  int get downloadedContentVersion => 0;

  void emitSnapshot(DownloadTaskSnapshot snapshot) {
    _controllers['task-1']?.add(snapshot);
  }
}

void main() {
  group('ContentDownloadCubit', () {
    test('completes download from stream snapshots', () async {
      final repo = FakeContentDownloadRepository();
      final orchestrator = DownloadOrchestrator(
        repo,
        DownloadManifestService(DownloadContentUseCase(repo), repo),
        DownloadTaskRunner(repo),
        DownloadProgressTracker(),
        DownloadNotificationThrottler(_FakeContentDownloadNotifier()),
      );
      final cubit = ContentDownloadCubit(orchestrator, repo);

      final future = cubit.startDownload(ContentDownloadOption.quranOnly);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      repo.emitSnapshot(
        const DownloadTaskSnapshot(
          state: DownloadTaskState.running,
          progress: 50,
        ),
      );
      repo.emitSnapshot(
        const DownloadTaskSnapshot(
          state: DownloadTaskState.complete,
          progress: 100,
        ),
      );
      await future;

      expect(cubit.state.status, ContentDownloadStatus.completed);
      expect(cubit.state.downloadedBytes, cubit.state.totalBytes);
      expect(repo.completedMarked, isTrue);

      await cubit.close();
    });

    test('fails download when task stream emits failure', () async {
      final repo = FakeContentDownloadRepository();
      repo.shouldFailTask = true;
      final orchestrator = DownloadOrchestrator(
        repo,
        DownloadManifestService(DownloadContentUseCase(repo), repo),
        DownloadTaskRunner(repo),
        DownloadProgressTracker(),
        DownloadNotificationThrottler(_FakeContentDownloadNotifier()),
      );
      final cubit = ContentDownloadCubit(orchestrator, repo);

      final future = cubit.startDownload(ContentDownloadOption.quranOnly);
      await future;

      expect(cubit.state.status, ContentDownloadStatus.failed);
      expect(cubit.state.errorMessage, contains('فشل تنزيل'));

      await cubit.close();
    });
  });
}
