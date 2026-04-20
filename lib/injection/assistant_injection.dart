import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/features/ai_assistant/data/datasources/assistant_remote_data_source.dart';
import 'package:yusr_app/features/ai_assistant/data/repositories/assistant_repository_impl.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';
import 'package:yusr_app/features/ai_assistant/domain/repositories/assistant_repository.dart';
import 'package:yusr_app/features/ai_assistant/domain/usecases/handle_agent_response_use_case.dart';
import 'package:yusr_app/features/ai_assistant/domain/usecases/send_message_use_case.dart';

void registerAssistantDependencies(GetIt sl, {required String webhookUrl}) {
  if (webhookUrl.isNotEmpty && !sl.isRegistered<AssistantRemoteDataSource>()) {
    sl.registerLazySingleton<AssistantRemoteDataSource>(
      () => AssistantRemoteDataSource(dio: sl<Dio>(), webhookUrl: webhookUrl),
    );
  }

  if (!sl.isRegistered<AssistantRepository>()) {
    if (webhookUrl.isNotEmpty) {
      sl.registerLazySingleton<AssistantRepository>(
        () => AssistantRepositoryImpl(sl<AssistantRemoteDataSource>()),
      );
    } else {
      sl.registerLazySingleton<AssistantRepository>(
        () => const UnavailableAssistantRepository(),
      );
    }
  }

  if (!sl.isRegistered<SendMessageUseCase>()) {
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

class UnavailableAssistantRepository implements AssistantRepository {
  const UnavailableAssistantRepository();

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
