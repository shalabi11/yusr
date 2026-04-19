import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_task_snapshot.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';

class BackgroundDownloaderDataSource {
  const BackgroundDownloaderDataSource();

  Future<String?> enqueue({
    required DownloadableContentFile file,
    required String savedDir,
  }) {
    return FlutterDownloader.enqueue(
      url: file.url,
      fileName: file.name,
      savedDir: savedDir,
      showNotification: true,
      openFileFromNotification: false,
    );
  }

  Future<DownloadTaskSnapshot> taskSnapshot(String taskId) async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE task_id='$taskId'",
    );

    if (tasks == null || tasks.isEmpty) {
      return const DownloadTaskSnapshot(
        state: DownloadTaskState.undefined,
        progress: 0,
      );
    }

    final task = tasks.first;
    return DownloadTaskSnapshot(
      state: _mapStatus(task.status),
      progress: task.progress,
    );
  }

  Future<void> pause(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
  }

  Future<String?> resume(String taskId) {
    return FlutterDownloader.resume(taskId: taskId);
  }

  DownloadTaskState _mapStatus(DownloadTaskStatus status) {
    switch (status) {
      case DownloadTaskStatus.undefined:
        return DownloadTaskState.undefined;
      case DownloadTaskStatus.enqueued:
        return DownloadTaskState.enqueued;
      case DownloadTaskStatus.running:
        return DownloadTaskState.running;
      case DownloadTaskStatus.complete:
        return DownloadTaskState.complete;
      case DownloadTaskStatus.failed:
        return DownloadTaskState.failed;
      case DownloadTaskStatus.canceled:
        return DownloadTaskState.canceled;
      case DownloadTaskStatus.paused:
        return DownloadTaskState.paused;
    }
  }
}
