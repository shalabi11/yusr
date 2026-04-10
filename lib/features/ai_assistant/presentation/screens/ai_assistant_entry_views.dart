part of 'ai_assistant_entry_screen.dart';

extension AIAssistantEntryViews on AIAssistantEntryScreen {
  Widget buildSupabaseDisabled() {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي')),
      body: const AppRadialBackground(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'المساعد الذكي غير متاح حاليًا لأن إعدادات Supabase غير مفعلة.',
              style: TextStyle(color: AppColors.textWhite, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAssistantPlaceholder() {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي')),
      body: const AppRadialBackground(
        child: Center(
          child: Text(
            'واجهة المساعد الذكي قيد التطوير، والحساب الآن مفعل بنجاح.',
            style: TextStyle(color: AppColors.textWhite, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
