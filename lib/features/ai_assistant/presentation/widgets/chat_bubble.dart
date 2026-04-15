import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/assistant_response_type.dart';
import 'package:yusr_app/features/ai_assistant/domain/entities/message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.accent.withValues(alpha: 0.2)
              : AppColors.primaryDark.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUser
                ? AppColors.accent.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && message.responseType != null)
              _TypeBadge(type: message.responseType!),
            if (!isUser && message.responseType != null)
              const SizedBox(height: 6),
            Text(
              message.text,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 15,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatTime(message.createdAt),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final AssistantResponseType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label(type),
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _label(AssistantResponseType value) {
    switch (value) {
      case AssistantResponseType.answer:
        return 'إجابة';
      case AssistantResponseType.askForMissingInfo:
        return 'نقص بيانات';
      case AssistantResponseType.actionProposal:
        return 'طلب تأكيد';
      case AssistantResponseType.actionReady:
        return 'تنفيذ';
    }
  }
}
