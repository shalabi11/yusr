part of 'assistant_auth_screen.dart';

extension AssistantAuthActions on _AssistantAuthScreenState {
  Future<void> submit() async {
    if (!SupabaseBootstrap.isEnabled) {
      showMessage('إعدادات Supabase غير مفعلة في التطبيق.');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('يرجى إدخال البريد وكلمة المرور');
      return;
    }

    if (_mode == AssistantAuthMode.signUp &&
        _confirmController.text != password) {
      showMessage('كلمة المرور غير متطابقة');
      return;
    }

    _setLoading(true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_mode == AssistantAuthMode.signIn) {
        await auth.signInWithPassword(email: email, password: password);
      } else {
        await auth.signUp(email: email, password: password);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/assistant');
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (_) {
      showMessage('تعذر إتمام العملية، حاول لاحقًا');
    } finally {
      _setLoading(false);
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
