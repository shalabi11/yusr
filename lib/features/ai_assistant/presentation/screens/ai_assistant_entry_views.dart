part of 'ai_assistant_entry_screen.dart';

extension AIAssistantEntryViews on AIAssistantEntryScreen {
  Widget buildSupabaseDisabled() {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي')),
      body: AppRadialBackground(
        child: RefreshIndicator(
          onRefresh: () async {},
          color: AppColors.accent,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 420,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'المساعد الذكي غير متاح الآن لأن إعدادات Supabase غير مفعّلة.\n\nشغّل التطبيق مع SUPABASE_URL و SUPABASE_ANON_KEY عبر --dart-define.',
                      style: TextStyle(color: AppColors.textWhite, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAssistantChat() {
    return BlocProvider(
      create: (_) => sl<ChatCubit>(),
      child: const ChatScreen(),
    );
  }
}
