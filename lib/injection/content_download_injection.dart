import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/features/content_download/data/datasources/background_downloader_data_source.dart';
import 'package:yusr_app/features/content_download/data/datasources/content_local_data_source.dart';
import 'package:yusr_app/features/content_download/data/datasources/content_remote_data_source.dart';
import 'package:yusr_app/features/content_download/data/repositories/content_download_repository_impl.dart';
import 'package:yusr_app/features/content_download/data/services/panel_content_download_notifier.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/services/content_download_notifier.dart';
import 'package:yusr_app/features/content_download/domain/services/download_manifest_service.dart';
import 'package:yusr_app/features/content_download/domain/services/download_notification_throttler.dart';
import 'package:yusr_app/features/content_download/domain/services/download_orchestrator.dart';
import 'package:yusr_app/features/content_download/domain/services/download_progress_tracker.dart';
import 'package:yusr_app/features/content_download/domain/services/download_task_runner.dart';
import 'package:yusr_app/features/content_download/domain/services/retry_executor.dart';
import 'package:yusr_app/features/content_download/domain/usecases/download_content_use_case.dart';
import 'package:yusr_app/features/content_download/domain/usecases/pause_download_use_case.dart';
import 'package:yusr_app/features/content_download/domain/usecases/resume_download_use_case.dart';

void registerContentDownloadDependencies(GetIt sl) {
  if (!sl.isRegistered<ContentRemoteDataSource>()) {
    sl.registerLazySingleton<ContentRemoteDataSource>(
      () => ContentRemoteDataSource(
        sl.isRegistered<SupabaseClient>() ? sl<SupabaseClient>() : null,
      ),
    );
  }
  if (!sl.isRegistered<ContentLocalDataSource>()) {
    sl.registerLazySingleton<ContentLocalDataSource>(
      () => ContentLocalDataSource(sl<IStorageService>()),
    );
  }
  if (!sl.isRegistered<BackgroundDownloaderDataSource>()) {
    sl.registerLazySingleton<BackgroundDownloaderDataSource>(
      () => const BackgroundDownloaderDataSource(),
    );
  }
  if (!sl.isRegistered<ContentDownloadRepository>()) {
    sl.registerLazySingleton<ContentDownloadRepository>(
      () => ContentDownloadRepositoryImpl(
        remoteDataSource: sl<ContentRemoteDataSource>(),
        localDataSource: sl<ContentLocalDataSource>(),
        downloaderDataSource: sl<BackgroundDownloaderDataSource>(),
      ),
    );
  }
  if (!sl.isRegistered<DownloadContentUseCase>()) {
    sl.registerLazySingleton<DownloadContentUseCase>(
      () => DownloadContentUseCase(sl<ContentDownloadRepository>()),
    );
  }
  if (!sl.isRegistered<PauseDownloadUseCase>()) {
    sl.registerLazySingleton<PauseDownloadUseCase>(
      () => PauseDownloadUseCase(sl<ContentDownloadRepository>()),
    );
  }
  if (!sl.isRegistered<ResumeDownloadUseCase>()) {
    sl.registerLazySingleton<ResumeDownloadUseCase>(
      () => ResumeDownloadUseCase(sl<ContentDownloadRepository>()),
    );
  }

  if (!sl.isRegistered<ContentDownloadNotifier>()) {
    sl.registerLazySingleton<ContentDownloadNotifier>(
      () => const PanelContentDownloadNotifier(),
    );
  }

  if (!sl.isRegistered<DownloadNotificationThrottler>()) {
    sl.registerFactory<DownloadNotificationThrottler>(
      () => DownloadNotificationThrottler(sl<ContentDownloadNotifier>()),
    );
  }

  if (!sl.isRegistered<DownloadProgressTracker>()) {
    sl.registerFactory<DownloadProgressTracker>(DownloadProgressTracker.new);
  }

  if (!sl.isRegistered<RetryExecutor>()) {
    sl.registerLazySingleton<RetryExecutor>(() => const RetryExecutor());
  }

  if (!sl.isRegistered<DownloadManifestService>()) {
    sl.registerFactory<DownloadManifestService>(
      () => DownloadManifestService(sl<DownloadContentUseCase>(), sl<ContentDownloadRepository>()),
    );
  }

  if (!sl.isRegistered<DownloadTaskRunner>()) {
    sl.registerFactory<DownloadTaskRunner>(
      () => DownloadTaskRunner(sl<ContentDownloadRepository>(), retryExecutor: sl<RetryExecutor>()),
    );
  }

  if (!sl.isRegistered<DownloadOrchestrator>()) {
    sl.registerLazySingleton<DownloadOrchestrator>(
      () => DownloadOrchestrator(
        sl<ContentDownloadRepository>(),
        sl<DownloadManifestService>(),
        sl<DownloadTaskRunner>(),
        sl<DownloadProgressTracker>(),
        sl<DownloadNotificationThrottler>(),
      ),
    );
  }
}
