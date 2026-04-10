part of 'assistant_auth_screen.dart';

extension AssistantAuthForm on _AssistantAuthScreenState {
  Widget buildAuthForm(bool isSignIn) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'كلمة المرور'),
          ),
          if (!isSignIn) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primaryDark,
              ),
              child: Text(
                _loading
                    ? 'جاري المعالجة...'
                    : (isSignIn ? 'دخول' : 'إنشاء حساب'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : _toggleMode,
            child: Text(
              isSignIn
                  ? 'ليس لديك حساب؟ أنشئ حسابًا'
                  : 'لديك حساب؟ تسجيل الدخول',
            ),
          ),
        ],
      ),
    );
  }
}
