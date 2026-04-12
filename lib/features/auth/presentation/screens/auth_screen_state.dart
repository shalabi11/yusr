part of 'auth_screen.dart';

class _AuthScreenState extends State<AuthScreen> {
  late final AuthFormCubit _authFormCubit;
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authFormCubit = createAuthFormCubit(
      startInSignUpMode: widget.startInSignUpMode,
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _authFormCubit.close();
    super.dispose();
  }

  Future<void> _submit() {
    return _authFormCubit.submit(
      username: _userNameController.text,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
      markAccountOnboardingSeenOnSuccess:
          widget.markAccountOnboardingSeenOnSuccess,
    );
  }

  void _onAuthStateChanged(AuthFormState state) {
    if (state.infoMessage != null && state.infoMessage!.isNotEmpty) {
      context.showAuthMessage(state.infoMessage!);
      _authFormCubit.consumeFeedback();
      return;
    }

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      context.showAuthMessage(state.errorMessage!, isError: true);
      _authFormCubit.consumeFeedback();
      return;
    }

    if (!state.navigateOnSuccess) {
      return;
    }

    navigateAfterAuthSuccess(
      context: context,
      successRoute: widget.successRoute,
      clearStackOnSuccess: widget.clearStackOnSuccess,
    );

    _authFormCubit.consumeFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authFormCubit,
      child: BlocConsumer<AuthFormCubit, AuthFormState>(
        listener: (_, state) => _onAuthStateChanged(state),
        builder: (_, state) {
          final isSignIn = !state.isSignUpMode;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              leading: BackButton(color: AppColors.textWhite),
              title: Text(
                isSignIn ? 'تسجيل الدخول' : 'إنشاء حساب',
                style: const TextStyle(color: AppColors.textWhite),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: AppRadialBackground(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 100,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: AuthGlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AuthHeaderIcon(),
                          const SizedBox(height: 32),
                          if (!isSignIn) ...[
                            CustomAuthTextField(
                              controller: _userNameController,
                              label: 'اسم المستخدم',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                          ],
                          CustomAuthTextField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          CustomAuthTextField(
                            controller: _passwordController,
                            label: 'كلمة المرور',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          if (!isSignIn) ...[
                            const SizedBox(height: 16),
                            CustomAuthTextField(
                              controller: _confirmController,
                              label: 'تأكيد كلمة المرور',
                              icon: Icons.lock_reset,
                              obscureText: true,
                            ),
                          ],
                          const SizedBox(height: 32),
                          AuthSubmitButton(
                            loading: state.isSubmitting,
                            onPressed: _submit,
                            label: isSignIn ? 'تسجيل الدخول' : 'إنشاء حساب',
                          ),
                          const SizedBox(height: 24),
                          AuthModeSwitchButton(
                            enabled: !state.isSubmitting,
                            onPressed: _authFormCubit.toggleMode,
                            label: isSignIn
                                ? 'إنشاء حساب - ليس لديك حساب؟'
                                : 'تسجيل الدخول - لديك حساب بالفعل؟',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
