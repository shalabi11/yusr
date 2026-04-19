part of 'injection_container.dart';

void _registerCubits() {
  if (!sl.isRegistered<SettingsCubit>()) {
    sl.registerFactory<SettingsCubit>(
      () => SettingsCubit(
        sl<IStorageService>(),
        sl<INotificationService>(),
        supabaseClient: sl.isRegistered<SupabaseClient>()
            ? sl<SupabaseClient>()
            : null,
      ),
    );
  }
  if (!sl.isRegistered<PrayerTimesCubit>()) {
    sl.registerFactory<PrayerTimesCubit>(
      () => PrayerTimesCubit(
        sl<PrayerTimesRepository>(),
        sl<IStorageService>(),
        sl<INotificationService>(),
      ),
    );
  }

  if (!sl.isRegistered<ChatCubit>()) {
    sl.registerFactory<ChatCubit>(
      () => ChatCubit(
        sl.isRegistered<SendMessageUseCase>()
            ? sl<SendMessageUseCase>()
            : const SendMessageUseCase(_UnavailableAssistantRepository()),
        sl<HandleAgentResponseUseCase>(),
      ),
    );
  }

  if (!sl.isRegistered<ContentDownloadCubit>()) {
    sl.registerLazySingleton<ContentDownloadCubit>(
      () => ContentDownloadCubit(
        sl<ContentDownloadRepository>(),
        sl<DownloadContentUseCase>(),
        sl<PauseDownloadUseCase>(),
        sl<ResumeDownloadUseCase>(),
      ),
    );
  }
}
