import 'package:equatable/equatable.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';

enum ContentDownloadStatus {
  initial,
  preparing,
  downloading,
  paused,
  completed,
  failed,
}

class ContentDownloadState extends Equatable {
  const ContentDownloadState({
    this.status = ContentDownloadStatus.initial,
    this.selectedOption,
    this.currentFileName,
    this.errorMessage,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.completedFiles = 0,
    this.totalFiles = 0,
    this.wasAlreadyDownloaded = false,
  });

  final ContentDownloadStatus status;
  final ContentDownloadOption? selectedOption;
  final String? currentFileName;
  final String? errorMessage;
  final int downloadedBytes;
  final int totalBytes;
  final int completedFiles;
  final int totalFiles;
  final bool wasAlreadyDownloaded;

  bool get isPreparing => status == ContentDownloadStatus.preparing;

  bool get isDownloading => status == ContentDownloadStatus.downloading;

  bool get isPaused => status == ContentDownloadStatus.paused;

  double get progress =>
      totalBytes == 0 ? 0.0 : (downloadedBytes / totalBytes).clamp(0.0, 1.0);

  ContentDownloadState copyWith({
    ContentDownloadStatus? status,
    ContentDownloadOption? selectedOption,
    String? currentFileName,
    String? errorMessage,
    bool clearError = false,
    int? downloadedBytes,
    int? totalBytes,
    int? completedFiles,
    int? totalFiles,
    bool? wasAlreadyDownloaded,
  }) {
    return ContentDownloadState(
      status: status ?? this.status,
      selectedOption: selectedOption ?? this.selectedOption,
      currentFileName: currentFileName ?? this.currentFileName,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      completedFiles: completedFiles ?? this.completedFiles,
      totalFiles: totalFiles ?? this.totalFiles,
      wasAlreadyDownloaded: wasAlreadyDownloaded ?? this.wasAlreadyDownloaded,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedOption,
    currentFileName,
    errorMessage,
    downloadedBytes,
    totalBytes,
    completedFiles,
    totalFiles,
    wasAlreadyDownloaded,
  ];
}
