import 'package:dartz/dartz.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';

abstract class AssistantRepository {
  Future<Either<Failure, AssistantResponse>> sendMessage({
    required String userId,
    required String message,
    required List<Message> history,
    String? conversationId,
    String locale = 'ar',
    String timezone = 'Asia/Riyadh',
  });
}
