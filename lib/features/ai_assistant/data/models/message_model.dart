import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';

class MessageModel {
  const MessageModel({
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final String role;
  final String text;
  final DateTime createdAt;

  factory MessageModel.fromEntity(Message entity) {
    return MessageModel(
      role: entity.role.name,
      text: entity.text,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
