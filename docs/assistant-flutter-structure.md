# Flutter Clean Architecture Structure

lib/features/ai_assistant/
- data/
  - datasources/
    - assistant_remote_data_source.dart
  - models/
    - assistant_response_model.dart
    - message_model.dart
    - reminder_model.dart
  - repositories/
    - assistant_repository_impl.dart
- domain/
  - entities/
    - assistant_response.dart
    - assistant_response_type.dart
    - message.dart
    - reminder.dart
  - repositories/
    - assistant_repository.dart
  - usecases/
    - send_message_use_case.dart
    - handle_agent_response_use_case.dart
- presentation/
  - cubit/
    - chat_cubit.dart
    - chat_state.dart
  - screens/
    - ai_assistant_entry_screen.dart
    - ai_assistant_entry_gate.dart
    - ai_assistant_entry_views.dart
    - chat_screen.dart
  - widgets/
    - chat_bubble.dart
    - chat_input_field.dart

## Responsibilities
- Presentation Layer
  - ChatScreen + ChatBubble + ChatInputField for UI only.
  - ChatCubit orchestrates use cases and state.
- Domain Layer
  - Message and Reminder entities.
  - SendMessageUseCase and HandleAgentResponseUseCase business flow.
- Data Layer
  - RemoteDataSource calls n8n webhook.
  - RepositoryImpl maps DTO <-> Domain and handles failures.

## Dependency Injection
Registered in lib/injection_container.dart:
- AssistantRemoteDataSource
- AssistantRepository (AssistantRepositoryImpl)
- SendMessageUseCase
- HandleAgentResponseUseCase
- ChatCubit

Environment variable required:
- N8N_ASSISTANT_WEBHOOK_URL
