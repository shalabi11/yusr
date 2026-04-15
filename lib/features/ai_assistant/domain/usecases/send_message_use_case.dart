import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';
import 'package:yusr_app/features/ai_assistant/domain/repositories/assistant_repository.dart';

class SendMessageParams extends Equatable {
  const SendMessageParams({
    required this.userId,
    required this.message,
    required this.history,
    this.conversationId,
    this.locale = 'ar',
    this.timezone = 'Asia/Riyadh',
  });

  final String userId;
  final String message;
  final List<Message> history;
  final String? conversationId;
  final String locale;
  final String timezone;

  @override
  List<Object?> get props => [
    userId,
    message,
    history,
    conversationId,
    locale,
    timezone,
  ];
}

class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final AssistantRepository _repository;

  Future<Either<Failure, AssistantResponse>> call(SendMessageParams params) {
    return _repository.sendMessage(
      userId: params.userId,
      message: params.message,
      history: params.history,
      conversationId: params.conversationId,
      locale: params.locale,
      timezone: params.timezone,
    );
  }
}
