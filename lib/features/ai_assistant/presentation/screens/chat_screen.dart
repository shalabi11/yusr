import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/ai_assistant/presentation/cubit/chat_cubit.dart';
import 'package:yusr_app/features/ai_assistant/presentation/cubit/chat_state.dart';
import 'package:yusr_app/features/ai_assistant/presentation/widgets/chat_bubble.dart';
import 'package:yusr_app/features/ai_assistant/presentation/widgets/chat_input_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _refreshChat() async {
    if (mounted) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي')),
      body: AppRadialBackground(
        child: BlocConsumer<ChatCubit, ChatState>(
          listenWhen: (previous, current) =>
              previous.messages.length != current.messages.length,
          listener: (_, __) => _scrollToBottom(),
          builder: (context, state) {
            return Column(
              children: [
                Expanded(child: _buildMessages(state)),
                ChatInputField(
                  isLoading: state.isLoading,
                  onSend: context.read<ChatCubit>().sendMessage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessages(ChatState state) {
    if (state.messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshChat,
        color: AppColors.accent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 360,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'جرّب: "ضيفلي أذكار الصباح عالتذكيرات"\nوسيسألك المساعد عن الوقت والتكرار ثم يطلب تأكيد التنفيذ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final itemCount = state.messages.length + (state.isLoading ? 1 : 0);

    return RefreshIndicator(
      onRefresh: _refreshChat,
      color: AppColors.accent,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= state.messages.length) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '... جاري التحليل',
                  style: TextStyle(color: AppColors.textWhite),
                ),
              ),
            );
          }

          return ChatBubble(message: state.messages[index]);
        },
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }
}
