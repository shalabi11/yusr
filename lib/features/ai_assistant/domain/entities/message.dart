import 'package:equatable/equatable.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response_type.dart';

enum MessageRole { user, assistant }

class Message extends Equatable {
  const Message({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.responseType,
  });

  final String id;
  final MessageRole role;
  final String text;
  final DateTime createdAt;
  final AssistantResponseType? responseType;

  @override
  List<Object?> get props => [id, role, text, createdAt, responseType];
}
