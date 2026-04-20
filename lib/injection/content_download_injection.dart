import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/features/content_download/data/datasources/background_downloader_data_source.dart';
import 'package:yusr_app/features/content_download/data/datasources/content_local_data_source.dart';
import 'package:yusr_app/features/content_download/data/datasources/content_remote_data_source.dart';
import 'package:yusr_app/features/content_download/data/repositories/content_download_repository_impl.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
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
}
