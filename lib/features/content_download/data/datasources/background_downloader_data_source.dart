import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:isolate';
import 'dart:async';
import 'dart:ui';
import 'package:yusr_app/features/content_download/domain/entities/download_task_snapshot.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';

class BackgroundDownloaderDataSource {
  const BackgroundDownloaderDataSource();

  static const String _portName = 'yusr_downloader_send_port';
  static final ReceivePort _receivePort = ReceivePort();
  static final StreamController<_TaskUpdate> _updatesController =
      StreamController<_TaskUpdate>.broadcast();

  static bool _isBound = false;
  static bool _isCallbackRegistered = false;

  static void _ensureStreamBinding() {
    if (!_isBound) {
      IsolateNameServer.removePortNameMapping(_portName);
      IsolateNameServer.registerPortWithName(_receivePort.sendPort, _portName);
      _receivePort.listen((dynamic data) {
        if (data is! List<dynamic> || data.length < 3) {
          return;
        }

        final taskId = data[0]?.toString() ?? '';
        final statusValue = data[1] is int ? data[1] as int : -1;
        final progress = data[2] is int ? data[2] as int : 0;
        if (taskId.isEmpty) {
          return;
        }

        final status =
            (statusValue >= 0 && statusValue < DownloadTaskStatus.values.length)
            ? DownloadTaskStatus.values[statusValue]
            : DownloadTaskStatus.undefined;
        _updatesController.add(
          _TaskUpdate(
            taskId: taskId,
            snapshot: DownloadTaskSnapshot(
              state: _mapStatus(status),
              progress: progress.clamp(0, 100),
            ),
          ),
        );
      });
      _isBound = true;
    }

    if (!_isCallbackRegistered) {
      FlutterDownloader.registerCallback(_downloadCallback);
      _isCallbackRegistered = true;
    }
  }

  Future<String?> enqueue({
    required DownloadableContentFile file,
    required String savedDir,
  }) {
    _ensureStreamBinding();
    return FlutterDownloader.enqueue(
      url: file.url,
      fileName: file.name,
      savedDir: savedDir,
      showNotification: false,
      openFileFromNotification: false,
    );
  }

  Future<DownloadTaskSnapshot> taskSnapshot(String taskId) async {
    _ensureStreamBinding();
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
    _ensureStreamBinding();
    await FlutterDownloader.pause(taskId: taskId);
  }

  Future<String?> resume(String taskId) {
    _ensureStreamBinding();
    return FlutterDownloader.resume(taskId: taskId);
  }

  Stream<DownloadTaskSnapshot> observeTask(String taskId) {
    _ensureStreamBinding();
    return _updatesController.stream
        .where((update) => update.taskId == taskId)
        .map((update) => update.snapshot);
  }

  static DownloadTaskState _mapStatus(DownloadTaskStatus status) {
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

class _TaskUpdate {
  const _TaskUpdate({required this.taskId, required this.snapshot});

  final String taskId;
  final DownloadTaskSnapshot snapshot;
}

@pragma('vm:entry-point')
void _downloadCallback(String id, int status, int progress) {
  final sendPort = IsolateNameServer.lookupPortByName(
    BackgroundDownloaderDataSource._portName,
  );
  sendPort?.send([id, status, progress]);
}
