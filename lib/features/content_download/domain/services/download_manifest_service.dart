import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/usecases/download_content_use_case.dart';

class DownloadManifestService {
  final DownloadContentUseCase _downloadContentUseCase;
  final ContentDownloadRepository _repository;

  DownloadManifestService(this._downloadContentUseCase, this._repository);

  Future<ManifestResult> prepareManifest(Set<DownloadContentType> targetTypes) async {
    final requestedManifest = await _downloadContentUseCase(targetTypes);
    
    if (requestedManifest.isEmpty) {
      return const ManifestResult.empty();
    }

    final sortedManifest = [...requestedManifest]
      ..sort((a, b) => a.type.index.compareTo(b.type.index));

    final pending = <DownloadableContentFile>[];
    int downloadedBytes = 0;
    int completedFiles = 0;

    for (final file in sortedManifest) {
      final alreadyDownloaded = await _repository.isFileAlreadyDownloaded(file);
      if (alreadyDownloaded) {
        downloadedBytes += file.size;
        completedFiles += 1;
        continue;
      }
      pending.add(file);
    }

    final totalBytes = sortedManifest.fold<int>(0, (sum, file) => sum + file.size);
    final totalFiles = sortedManifest.length;

    return ManifestResult(
      pendingFiles: pending,
      totalBytes: totalBytes,
      totalFiles: totalFiles,
      alreadyDownloadedBytes: downloadedBytes,
      alreadyCompletedFiles: completedFiles,
    );
  }
}

class ManifestResult {
  final List<DownloadableContentFile> pendingFiles;
  final int totalBytes;
  final int totalFiles;
  final int alreadyDownloadedBytes;
  final int alreadyCompletedFiles;

  const ManifestResult({
    required this.pendingFiles,
    required this.totalBytes,
    required this.totalFiles,
    required this.alreadyDownloadedBytes,
    required this.alreadyCompletedFiles,
  });

  const ManifestResult.empty()
      : pendingFiles = const [],
        totalBytes = 0,
        totalFiles = 0,
        alreadyDownloadedBytes = 0,
        alreadyCompletedFiles = 0;

  bool get isEmpty => pendingFiles.isEmpty && alreadyCompletedFiles == 0;
}
