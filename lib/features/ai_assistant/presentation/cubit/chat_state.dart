import 'package:equatable/equatable.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';

class ChatState extends Equatable {
  const ChatState({
    this.messages = const <Message>[],
    this.isLoading = false,
    this.errorMessage,
    this.conversationId,
    this.lastResponse,
  });

  final List<Message> messages;
  final bool isLoading;
  final String? errorMessage;
  final String? conversationId;
  final AssistantResponse? lastResponse;

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? conversationId,
    AssistantResponse? lastResponse,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      conversationId: conversationId ?? this.conversationId,
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isLoading,
    errorMessage,
    conversationId,
    lastResponse,
  ];
}
