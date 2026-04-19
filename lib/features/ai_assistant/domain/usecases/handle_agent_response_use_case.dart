import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response_type.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';

class HandleAgentResponseUseCase {
  Message call(AssistantResponse response) {
    return Message(
      id: _buildId(),
      role: MessageRole.assistant,
      text: _buildText(response),
      createdAt: DateTime.now(),
      responseType: response.type,
    );
  }

  String _buildText(AssistantResponse response) {
    if (response.replyText.trim().isNotEmpty) {
      return response.replyText.trim();
    }

    switch (response.type) {
      case AssistantResponseType.answer:
        return 'تمت معالجة طلبك.';
      case AssistantResponseType.askForMissingInfo:
        return 'أحتاج تفاصيل إضافية قبل التنفيذ.';
      case AssistantResponseType.actionProposal:
        return 'هذا الإجراء جاهز للمراجعة. اكتب "نعم" للتأكيد.';
      case AssistantResponseType.actionReady:
        return response.executed
            ? 'تم تنفيذ الإجراء بنجاح.'
            : 'الإجراء جاهز للتنفيذ.';
    }
  }

  String _buildId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
