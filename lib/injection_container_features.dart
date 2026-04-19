part of 'injection_container.dart';

void _registerContentDownloadFeature() {
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

void _registerAssistantFeature(String assistantWebhookUrl) {
  if (assistantWebhookUrl.isNotEmpty &&
      !sl.isRegistered<AssistantRemoteDataSource>()) {
    sl.registerLazySingleton<AssistantRemoteDataSource>(
      () => AssistantRemoteDataSource(
        dio: sl<Dio>(),
        webhookUrl: assistantWebhookUrl,
      ),
    );
  }

  if (assistantWebhookUrl.isNotEmpty &&
      !sl.isRegistered<AssistantRepository>()) {
    sl.registerLazySingleton<AssistantRepository>(
      () => AssistantRepositoryImpl(sl<AssistantRemoteDataSource>()),
    );
  }

  if (assistantWebhookUrl.isNotEmpty &&
      !sl.isRegistered<SendMessageUseCase>()) {
    sl.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(sl<AssistantRepository>()),
    );
  }
  if (!sl.isRegistered<HandleAgentResponseUseCase>()) {
    sl.registerLazySingleton<HandleAgentResponseUseCase>(
      HandleAgentResponseUseCase.new,
    );
  }
}

void _registerRepositories() {
  if (!sl.isRegistered<PrayerTimesRepository>()) {
    sl.registerLazySingleton<PrayerTimesRepository>(
      () => PrayerTimesRepository(storageService: sl<IStorageService>()),
    );
  }
  if (!sl.isRegistered<RemindersRepository>()) {
    sl.registerLazySingleton<RemindersRepository>(
      () => RemindersRepository(
        remoteSync: sl.isRegistered<SupabaseClient>()
            ? RemindersRemoteSyncService(sl<SupabaseClient>())
            : null,
      ),
    );
  }
  if (!sl.isRegistered<AdhkarRepository>()) {
    sl.registerLazySingleton<AdhkarRepository>(
      () => AdhkarRepository(
        remoteDataSource: sl.isRegistered<SupabaseClient>()
            ? AdhkarRemoteDataSource(sl<SupabaseClient>())
            : null,
      ),
    );
  }
  if (!sl.isRegistered<QuranRepository>()) {
    sl.registerLazySingleton<QuranRepository>(
      () => QuranRepository(
        remoteSync: sl.isRegistered<SupabaseClient>()
            ? QuranRemoteSyncService(sl<SupabaseClient>())
            : null,
        catalogRemote: sl.isRegistered<SupabaseClient>()
            ? QuranCatalogRemoteService(sl<SupabaseClient>())
            : null,
      ),
    );
  }
  if (!sl.isRegistered<DailyAyahRepository>()) {
    sl.registerLazySingleton<DailyAyahRepository>(
      () => DailyAyahRepository(
        remoteDataSource: sl.isRegistered<SupabaseClient>()
            ? DailyAyahRemoteDataSource(sl<SupabaseClient>())
            : null,
      ),
    );
  }
}
