import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';

class ContentLocalDataSource {
  ContentLocalDataSource(this._storageService);

  static const String _metaBoxName = 'content_download_meta';

  final IStorageService _storageService;

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_metaBoxName)) {
      return Hive.box<dynamic>(_metaBoxName);
    }
    return Hive.openBox<dynamic>(_metaBoxName);
  }

  Future<String> ensureBaseDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${root.path}${Platform.pathSeparator}downloaded_content',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> ensureTypeDirectory(DownloadContentType type) async {
    final base = await ensureBaseDirectory();
    final dir = Directory('$base${Platform.pathSeparator}${type.value}');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<void> cacheDownloadedFile({
    required DownloadableContentFile file,
    required String localPath,
  }) async {
    final box = await _openBox();
    final key = 'file_${file.id}_${file.name}';
    await box.put(key, <String, dynamic>{
      'id': file.id,
      'name': file.name,
      'type': file.type.value,
      'url': file.url,
      'size': file.size,
      'local_path': localPath,
      'downloaded_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> isFileCachedAndExists(DownloadableContentFile file) async {
    final box = await _openBox();
    final key = 'file_${file.id}_${file.name}';
    final record = box.get(key);
    if (record is! Map) {
      return false;
    }

    final localPath = record['local_path']?.toString();
    if (localPath == null || localPath.isEmpty) {
      return false;
    }

    final localFile = File(localPath);
    if (!await localFile.exists()) {
      return false;
    }

    final expectedSize = file.size;
    if (expectedSize <= 0) {
      return true;
    }
    return (await localFile.length()) >= expectedSize;
  }

  Future<void> markSelectionCompleted({
    required ContentDownloadOption option,
    required int version,
    required String basePath,
  }) async {
    await _storageService.setDownloadedContentVersion(version);
    await _storageService.setDownloadedContentBasePath(basePath);

    final containsQuran = option.targetTypes.contains(
      DownloadContentType.quran,
    );
    final containsAdhkar = option.targetTypes.contains(
      DownloadContentType.adhkar,
    );

    if (containsQuran) {
      await _storageService.setQuranContentDownloaded(true);
    }
    if (containsAdhkar) {
      await _storageService.setAdhkarContentDownloaded(true);
    }

    await _storageService.setContentDownloaded(
      _storageService.quranContentDownloaded &&
          _storageService.adhkarContentDownloaded,
    );
  }

  bool get isContentDownloaded => _storageService.isContentDownloaded;

  bool get isQuranContentDownloaded => _storageService.quranContentDownloaded;

  bool get isAdhkarContentDownloaded => _storageService.adhkarContentDownloaded;

  int get downloadedContentVersion => _storageService.downloadedContentVersion;
}
