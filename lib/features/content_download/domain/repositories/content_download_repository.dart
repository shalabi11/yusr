import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_task_snapshot.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';

abstract class ContentDownloadRepository {
  Future<List<DownloadableContentFile>> fetchManifest({
    required Set<DownloadContentType> targetTypes,
  });

  Future<String> ensureBaseDirectory();

  Future<String> ensureTypeDirectory(DownloadContentType type);

  Future<String?> enqueueFileDownload({
    required DownloadableContentFile file,
    required String savedDir,
  });

  Future<DownloadTaskSnapshot> getTaskSnapshot(String taskId);

  Stream<DownloadTaskSnapshot> observeTaskSnapshot(String taskId);

  Future<void> pauseTask(String taskId);

  Future<String?> resumeTask(String taskId);

  Future<void> cacheDownloadedFile({
    required DownloadableContentFile file,
    required String localPath,
  });

  Future<bool> isFileAlreadyDownloaded(DownloadableContentFile file);

  Future<void> markSelectionCompleted({
    required ContentDownloadOption option,
    required int version,
    required String basePath,
  });

  bool get isContentDownloaded;

  bool get isQuranContentDownloaded;

  bool get isAdhkarContentDownloaded;

  int get downloadedContentVersion;
}
