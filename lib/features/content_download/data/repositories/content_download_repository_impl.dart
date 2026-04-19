import 'package:yusr_app/features/content_download/data/datasources/background_downloader_data_source.dart';
import 'package:yusr_app/features/content_download/data/datasources/content_local_data_source.dart';
import 'package:yusr_app/features/content_download/data/datasources/content_remote_data_source.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_task_snapshot.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';

class ContentDownloadRepositoryImpl implements ContentDownloadRepository {
  ContentDownloadRepositoryImpl({
    required ContentRemoteDataSource remoteDataSource,
    required ContentLocalDataSource localDataSource,
    required BackgroundDownloaderDataSource downloaderDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _downloaderDataSource = downloaderDataSource;

  final ContentRemoteDataSource _remoteDataSource;
  final ContentLocalDataSource _localDataSource;
  final BackgroundDownloaderDataSource _downloaderDataSource;

  @override
  Future<List<DownloadableContentFile>> fetchManifest({
    required Set<DownloadContentType> targetTypes,
  }) async {
    return _remoteDataSource.fetchManifest(targetTypes: targetTypes);
  }

  @override
  Future<String> ensureBaseDirectory() =>
      _localDataSource.ensureBaseDirectory();

  @override
  Future<String> ensureTypeDirectory(DownloadContentType type) {
    return _localDataSource.ensureTypeDirectory(type);
  }

  @override
  Future<String?> enqueueFileDownload({
    required DownloadableContentFile file,
    required String savedDir,
  }) {
    return _downloaderDataSource.enqueue(file: file, savedDir: savedDir);
  }

  @override
  Future<DownloadTaskSnapshot> getTaskSnapshot(String taskId) {
    return _downloaderDataSource.taskSnapshot(taskId);
  }

  @override
  Stream<DownloadTaskSnapshot> observeTaskSnapshot(String taskId) {
    return _downloaderDataSource.observeTask(taskId);
  }

  @override
  Future<void> pauseTask(String taskId) => _downloaderDataSource.pause(taskId);

  @override
  Future<String?> resumeTask(String taskId) {
    return _downloaderDataSource.resume(taskId);
  }

  @override
  Future<void> cacheDownloadedFile({
    required DownloadableContentFile file,
    required String localPath,
  }) {
    return _localDataSource.cacheDownloadedFile(
      file: file,
      localPath: localPath,
    );
  }

  @override
  Future<bool> isFileAlreadyDownloaded(DownloadableContentFile file) {
    return _localDataSource.isFileCachedAndExists(file);
  }

  @override
  Future<void> markSelectionCompleted({
    required ContentDownloadOption option,
    required int version,
    required String basePath,
  }) {
    return _localDataSource.markSelectionCompleted(
      option: option,
      version: version,
      basePath: basePath,
    );
  }

  @override
  bool get isContentDownloaded => _localDataSource.isContentDownloaded;

  @override
  bool get isQuranContentDownloaded =>
      _localDataSource.isQuranContentDownloaded;

  @override
  bool get isAdhkarContentDownloaded =>
      _localDataSource.isAdhkarContentDownloaded;

  @override
  int get downloadedContentVersion => _localDataSource.downloadedContentVersion;
}
