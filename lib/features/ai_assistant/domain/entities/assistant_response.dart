import 'package:equatable/equatable.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response_type.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/reminder.dart';

class AssistantResponse extends Equatable {
  const AssistantResponse({
    required this.type,
    required this.replyText,
    this.intent,
    this.actionName,
    this.reminder,
    this.missingFields = const <String>[],
    this.requiresConfirmation = false,
    this.executed = false,
    this.conversationId,
  });

  final AssistantResponseType type;
  final String replyText;
  final String? intent;
  final String? actionName;
  final Reminder? reminder;
  final List<String> missingFields;
  final bool requiresConfirmation;
  final bool executed;
  final String? conversationId;

  @override
  List<Object?> get props => [
    type,
    replyText,
    intent,
    actionName,
    reminder,
    missingFields,
    requiresConfirmation,
    executed,
    conversationId,
  ];
}
