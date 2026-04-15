import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/error/failures.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';
import 'package:yusr_app/features/ai_assistant/domain/usecases/handle_agent_response_use_case.dart';
import 'package:yusr_app/features/ai_assistant/domain/usecases/send_message_use_case.dart';

import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._sendMessageUseCase, this._handleAgentResponseUseCase)
    : super(const ChatState());

  final SendMessageUseCase _sendMessageUseCase;
  final HandleAgentResponseUseCase _handleAgentResponseUseCase;

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.isLoading) {
      return;
    }

    final userMessage = Message(
      id: _buildId(),
      role: MessageRole.user,
      text: text,
      createdAt: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    emit(
      state.copyWith(
        messages: updatedMessages,
        isLoading: true,
        clearErrorMessage: true,
      ),
    );

    final result = await _sendMessageUseCase(
      SendMessageParams(
        userId: SupabaseBootstrap.currentUserId ?? 'anonymous',
        message: text,
        conversationId: state.conversationId,
        history: _recentHistory(updatedMessages),
      ),
    );

    result.fold(_onFailure, _onSuccess);
  }

  void handleResponse(AssistantResponse response) {
    final assistantMessage = _handleAgentResponseUseCase(response);
    emit(
      state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
        conversationId: response.conversationId ?? state.conversationId,
        lastResponse: response,
        clearErrorMessage: true,
      ),
    );
  }

  void _onSuccess(AssistantResponse response) {
    handleResponse(response);
  }

  void _onFailure(Failure failure) {
    final fallbackMessage = Message(
      id: _buildId(),
      role: MessageRole.assistant,
      text: failure.message,
      createdAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        messages: [...state.messages, fallbackMessage],
        isLoading: false,
        errorMessage: fallbackMessage.text,
      ),
    );
  }

  List<Message> _recentHistory(List<Message> messages) {
    const maxHistory = 12;
    if (messages.length <= maxHistory) {
      return messages;
    }

    return messages.sublist(messages.length - maxHistory);
  }

  String _buildId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
