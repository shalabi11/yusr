import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';

class PauseDownloadUseCase {
  const PauseDownloadUseCase(this._repository);

  final ContentDownloadRepository _repository;

  Future<void> call(String taskId) => _repository.pauseTask(taskId);
}
