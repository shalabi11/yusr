import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

part 'assistant_auth_screen_actions.dart';
part 'assistant_auth_screen_form.dart';

enum AssistantAuthMode { signIn, signUp }

class AssistantAuthScreen extends StatefulWidget {
  const AssistantAuthScreen({
    super.key,
    this.initialMode = AssistantAuthMode.signIn,
  });

  final AssistantAuthMode initialMode;

  @override
  State<AssistantAuthScreen> createState() => _AssistantAuthScreenState();
}

class _AssistantAuthScreenState extends State<AssistantAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late AssistantAuthMode _mode;
  bool _loading = false;

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _loading = value);
  }

  void _toggleMode() {
    if (!mounted) return;
    setState(() {
      _mode = _mode == AssistantAuthMode.signIn
          ? AssistantAuthMode.signUp
          : AssistantAuthMode.signIn;
    });
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSignIn = _mode == AssistantAuthMode.signIn;

    return Scaffold(
      appBar: AppBar(title: Text(isSignIn ? 'تسجيل الدخول' : 'إنشاء حساب')),
      body: buildAuthForm(isSignIn),
    );
  }
}
