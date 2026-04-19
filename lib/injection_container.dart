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

part 'injection_container_core.dart';
part 'injection_container_features.dart';
part 'injection_container_cubits.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  const assistantWebhookUrl = String.fromEnvironment(
    'N8N_ASSISTANT_WEBHOOK_URL',
    defaultValue:
        'https://nonfenestrated-unreplevined-obdulia.ngrok-free.dev/webhook-test/yusr-assistant-split',
  );
  final prefs = await SharedPreferences.getInstance();

  _registerCoreServices(prefs);
  _registerContentDownloadFeature();
  _registerAssistantFeature(assistantWebhookUrl);
  StorageService.bind(sl<IStorageService>());
  _registerRepositories();
  _registerCubits();
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
