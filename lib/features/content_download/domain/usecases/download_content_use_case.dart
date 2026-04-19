import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';

class DownloadContentUseCase {
  const DownloadContentUseCase(this._repository);

  final ContentDownloadRepository _repository;

  Future<List<DownloadableContentFile>> call(
    Set<DownloadContentType> targetTypes,
  ) {
    return _repository.fetchManifest(targetTypes: targetTypes);
  }
}
