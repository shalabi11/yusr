import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/core/services/storage/storage_sevice_impl.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_repository.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_remote_data_source.dart';
import 'package:yusr_app/features/ai_assistant/data/datasources/assistant_remote_data_source.dart';
import 'package:yusr_app/features/ai_assistant/data/repositories/assistant_repository_impl.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';
import 'package:yusr_app/features/ai_assistant/domain/repositories/assistant_repository.dart';
import 'package:yusr_app/features/ai_assistant/domain/usecases/handle_agent_response_use_case.dart';
import 'package:yusr_app/features/ai_assistant/domain/usecases/send_message_use_case.dart';
import 'package:yusr_app/features/ai_assistant/presentation/cubit/chat_cubit.dart';
import 'package:yusr_app/features/content_download/data/datasources/background_downloader_data_source.dart';
import 'package:yusr_app/features/content_download/data/datasources/content_local_data_source.dart';
import 'package:yusr_app/features/content_download/data/datasources/content_remote_data_source.dart';
import 'package:yusr_app/features/content_download/data/repositories/content_download_repository_impl.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/usecases/download_content_use_case.dart';
import 'package:yusr_app/features/content_download/domain/usecases/pause_download_use_case.dart';
import 'package:yusr_app/features/content_download/domain/usecases/resume_download_use_case.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/home/data/daily_ayah_repository.dart';
import 'package:yusr_app/features/home/data/daily_ayah_remote_data_source.dart';
import 'package:yusr_app/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_catalog_remote_service.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_remote_sync_service.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_remote_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  const assistantWebhookUrl = String.fromEnvironment(
    'N8N_ASSISTANT_WEBHOOK_URL',
    defaultValue:
        'https://nonfenestrated-unreplevined-obdulia.ngrok-free.dev/webhook-test/yusr-assistant-split',
  );
  final prefs = await SharedPreferences.getInstance();

  if (!sl.isRegistered<IStorageService>()) {
    sl.registerLazySingleton<IStorageService>(() => StorageServiceImpl(prefs));
  }
  if (!sl.isRegistered<INotificationService>()) {
    sl.registerLazySingleton<INotificationService>(
      () => NotificationServiceAdapter(),
    );
  }
  if (SupabaseBootstrap.isEnabled && !sl.isRegistered<SupabaseClient>()) {
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 45),
        ),
      ),
    );
  }

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
  StorageService.bind(sl<IStorageService>());

  // Repositories
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

  // Cubits
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
    sl.registerFactory<ContentDownloadCubit>(
      () => ContentDownloadCubit(
        sl<ContentDownloadRepository>(),
        sl<DownloadContentUseCase>(),
        sl<PauseDownloadUseCase>(),
        sl<ResumeDownloadUseCase>(),
      ),
    );
  }
}

class _UnavailableAssistantRepository implements AssistantRepository {
  const _UnavailableAssistantRepository();

  @override
  Future<dartz.Either<Failure, AssistantResponse>> sendMessage({
    required String userId,
    required String message,
    required List<Message> history,
    String? conversationId,
    String locale = 'ar',
    String timezone = 'Asia/Riyadh',
  }) async {
    return const dartz.Left(
      ServerFailure(
        'N8N webhook غير مفعّل. مرّر N8N_ASSISTANT_WEBHOOK_URL عبر --dart-define.',
      ),
    );
  }
}
