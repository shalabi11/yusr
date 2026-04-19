part of 'profile_screen.dart';

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthController _authController;
  late final ImagePicker _imagePicker;
  String? _username;
  String? _email;
  String? _avatarUrl;
  bool _isAnonymous = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _authController = createAuthController();
    _imagePicker = ImagePicker();
    _loadUser();
  }

  void _loadUser() {
    _username = _authController.currentUsername();
    _email = _authController.currentEmail();
    _avatarUrl = _authController.currentAvatarUrl();
    _isAnonymous = _authController.isCurrentUserAnonymous();
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _loading = value);
  }

  Future<void> _refreshProfile() async {
    _loadUser();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _changeAvatar() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile == null) {
      return;
    }

    final fileExtension = _extractFileExtension(pickedFile.path);
    final bytes = await pickedFile.readAsBytes();

    _setLoading(true);
    final result = await _authController.updateAvatar(
      bytes: bytes,
      fileExtension: fileExtension,
    );

    if (!mounted) {
      return;
    }

    _setLoading(false);

    if (!result.isSuccess) {
      context.showAuthMessage(
        result.errorMessage ?? 'تعذّر تحديث صورة الملف الشخصي',
        isError: true,
      );
      return;
    }

    setState(() {
      _avatarUrl = result.avatarUrl;
    });

    context.showAuthMessage('تم تحديث صورة الملف الشخصي بنجاح');
  }

  String _extractFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1 || lastDot == path.length - 1) {
      return 'jpg';
    }

    return path.substring(lastDot + 1).toLowerCase();
  }

  Future<void> _logout() async {
    _setLoading(true);
    try {
      await _authController.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (_) {
      if (!mounted) return;
      context.showAuthMessage('حاول مرة أخرى لاحقاً', isError: true);
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  Future<void> _editProfile() async {
    var draftUsername = (_username ?? '').trim();

    final updatedUsername = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل الملف الشخصي'),
          content: TextFormField(
            initialValue: draftUsername,
            onChanged: (value) {
              draftUsername = value;
            },
            decoration: const InputDecoration(
              labelText: 'اسم المستخدم',
              hintText: 'أدخل اسم المستخدم الجديد',
            ),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, draftUsername.trim());
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (updatedUsername == null || updatedUsername.isEmpty) {
      return;
    }

    _setLoading(true);
    final errorMessage = await _authController.updateUsername(updatedUsername);

    if (!mounted) {
      return;
    }

    _setLoading(false);

    if (errorMessage != null) {
      context.showAuthMessage(errorMessage, isError: true);
      return;
    }

    setState(() {
      _username = updatedUsername;
    });

    context.showAuthMessage('تم تحديث الملف الشخصي بنجاح');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(color: AppColors.textWhite),
        title: Text(
          'الملف الشخصي',
          style: const TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppRadialBackground(
        child: Center(
          child: RefreshIndicator(
            onRefresh: _refreshProfile,
            color: AppColors.accent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      ProfileUserAvatar(
                        avatarUrl: _avatarUrl,
                        loading: _loading,
                        onTap: _changeAvatar,
                      ),
                      const SizedBox(height: 24),
                      ProfileUserNameText(
                        isAnonymous: _isAnonymous,
                        username: _username,
                        email: _email,
                      ),
                      const SizedBox(height: 32),
                      if (_isAnonymous) ...[
                        ProfileGuestActions(
                          onSignIn: () {
                            Navigator.pushNamed(context, '/auth');
                          },
                        ),
                      ] else ...[
                        ProfileEditButton(
                          loading: _loading,
                          onPressed: _editProfile,
                        ),
                        const SizedBox(height: 12),
                        ProfileSignOutButton(
                          loading: _loading,
                          onPressed: _logout,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
