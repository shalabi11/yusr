import 'package:dartz/dartz.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/features/ai_assistant/data/datasources/assistant_remote_data_source.dart';
import 'package:yusr_app/features/ai_assistant/data/models/assistant_response_model.dart';
import 'package:yusr_app/features/ai_assistant/data/models/message_model.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';
import 'package:yusr_app/features/ai_assistant/domain/repositories/assistant_repository.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  const AssistantRepositoryImpl(this._remoteDataSource);

  final AssistantRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AssistantResponse>> sendMessage({
    required String userId,
    required String message,
    required List<Message> history,
    String? conversationId,
    String locale = 'ar',
    String timezone = 'Asia/Riyadh',
  }) async {
    try {
      final payload = <String, dynamic>{
        'user_id': userId,
        'message': message,
        'conversation_id': conversationId,
        'locale': locale,
        'timezone': timezone,
        'history': history
            .map((entry) => MessageModel.fromEntity(entry).toJson())
            .toList(),
      };

      final responseJson = await _remoteDataSource.sendPayload(payload);
      final parsed = AssistantResponseModel.fromJson(responseJson);
      return Right(parsed);
    } catch (e) {
      return Left(ServerFailure('تعذر الوصول إلى المساعد الذكي: $e'));
    }
  }
}
