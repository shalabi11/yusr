import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/features/ai_assistant/domain/usecases/handle_agent_response_use_case.dart';
import 'package:yusr_app/features/ai_assistant/domain/usecases/send_message_use_case.dart';
import 'package:yusr_app/features/ai_assistant/presentation/cubit/chat_cubit.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/services/download_orchestrator.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/home/domain/usecases/daily_ayah_use_cases.dart';
import 'package:yusr_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:yusr_app/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:yusr_app/features/prayer_times/domain/prayer_countdown_service.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

void registerCubits(GetIt sl) {
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
        sl<PrayerCountdownService>(),
      ),
    );
  }

  if (!sl.isRegistered<ChatCubit>()) {
    sl.registerFactory<ChatCubit>(
      () =>
          ChatCubit(sl<SendMessageUseCase>(), sl<HandleAgentResponseUseCase>()),
    );
  }

  if (!sl.isRegistered<ContentDownloadCubit>()) {
    sl.registerLazySingleton<ContentDownloadCubit>(
      () => ContentDownloadCubit(
        sl<DownloadOrchestrator>(),
        sl<ContentDownloadRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<HomeCubit>()) {
    sl.registerFactory<HomeCubit>(() => HomeCubit(sl<DailyAyahUseCases>()));
  }
}
