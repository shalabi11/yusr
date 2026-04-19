import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';

class ResumeDownloadUseCase {
  const ResumeDownloadUseCase(this._repository);

  final ContentDownloadRepository _repository;

  Future<String?> call(String taskId) => _repository.resumeTask(taskId);
}
