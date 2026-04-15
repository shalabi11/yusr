part of 'ai_assistant_entry_screen.dart';

extension AIAssistantEntryGate on AIAssistantEntryScreen {
  Widget buildAnonymousGate(BuildContext context) {
    Future<void> refreshGate() async {
      await SupabaseBootstrap.ensureAnonymousSession();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/assistant');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي')),
      body: AppRadialBackground(
        child: RefreshIndicator(
          onRefresh: refreshGate,
          color: AppColors.accent,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  color: AppColors.primaryDark.withValues(alpha: 0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'استخدام المساعد الذكي يتطلب حسابًا',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'يمكنك متابعة استخدام بقية التطبيق بدون حساب، لكن للوصول للمساعد يلزم تسجيل الدخول.',
                          style: TextStyle(color: AppColors.textWhite),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/assistant-auth',
                                arguments: {'isSignUp': true},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.primaryDark,
                            ),
                            child: const Text('إنشاء حساب جديد'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/assistant-auth',
                                arguments: {'isSignUp': false},
                              );
                            },
                            child: const Text('لديك حساب؟ تسجيل الدخول'),
                          ),
                        ),
                      ],
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
}
