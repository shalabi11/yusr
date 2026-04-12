import 'package:flutter/material.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';

class AccountOnboardingScreen extends StatelessWidget {
  const AccountOnboardingScreen({super.key});

  Future<void> _skip(BuildContext context) async {
    await StorageService.setAccountOnboardingSeen(true);
    await SupabaseBootstrap.ensureAnonymousSession();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _openAuth(BuildContext context, {required bool isSignUp}) {
    Navigator.pushNamed(
      context,
      '/assistant-auth',
      arguments: {
        'isSignUp': isSignUp,
        'successRoute': '/home',
        'clearStackOnSuccess': true,
        'markAccountOnboardingSeenOnSuccess': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppRadialBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                color: AppColors.primaryDark.withValues(alpha: 0.65),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 56,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.accountOnboardingTitle.tr,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.accountOnboardingSubtitle.tr,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        AppStrings.accountOnboardingWarning.tr,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _openAuth(context, isSignUp: false),
                      icon: const Icon(Icons.login_rounded),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      label: Text(AppStrings.signIn.tr),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _openAuth(context, isSignUp: true),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: AppColors.textWhite,
                        side: const BorderSide(color: AppColors.accent),
                      ),
                      label: Text(AppStrings.signUp.tr),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _skip(context),
                      child: Text(
                        AppStrings.skipForNow.tr,
                        style: const TextStyle(color: AppColors.textWhite),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.accountOnboardingSkipHint.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
