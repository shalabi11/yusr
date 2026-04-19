import 'package:yusr_app/features/ai_assistant/data/models/reminder_model.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response_type.dart';

class AssistantResponseModel extends AssistantResponse {
  const AssistantResponseModel({
    required super.type,
    required super.replyText,
    super.intent,
    super.actionName,
    super.reminder,
    super.missingFields,
    super.requiresConfirmation,
    super.executed,
    super.conversationId,
  });

  factory AssistantResponseModel.fromJson(Map<String, dynamic> json) {
    final type = _parseType(json['type']?.toString());
    final action = _asMap(json['action']);
    final actionData = _asMap(action['data']);
    final missingFields = _asStringList(json['missing_fields']);

    return AssistantResponseModel(
      type: type,
      replyText:
          json['reply_text']?.toString() ?? json['reply']?.toString() ?? '',
      intent: json['intent']?.toString(),
      actionName: action['name']?.toString() ?? json['action_name']?.toString(),
      reminder: actionData.isEmpty ? null : ReminderModel.fromMap(actionData),
      missingFields: missingFields,
      requiresConfirmation: _asBool(
        action['requires_confirmation'] ?? json['requires_confirmation'],
      ),
      executed: _asBool(json['executed']),
      conversationId: json['conversation_id']?.toString(),
    );
  }

  static AssistantResponseType _parseType(String? raw) {
    switch (raw) {
      case 'ask_for_missing_info':
        return AssistantResponseType.askForMissingInfo;
      case 'action_proposal':
        return AssistantResponseType.actionProposal;
      case 'action_ready':
        return AssistantResponseType.actionReady;
      case 'answer':
      default:
        return AssistantResponseType.answer;
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }

    return const <String, dynamic>{};
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return const <String>[];
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }
}
