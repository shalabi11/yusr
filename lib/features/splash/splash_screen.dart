import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yusr_app/core/services/app_bootstrap.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _minimumSplashDuration = Duration(milliseconds: 700);

  late AnimationController _controller;
  late Animation<double> _animation;
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    unawaited(_navigateWhenReady());
  }

  Future<void> _navigateWhenReady() async {
    await AppBootstrap.instance.ready;

    final elapsed = DateTime.now().difference(_startedAt);
    if (elapsed < _minimumSplashDuration) {
      await Future<void>.delayed(_minimumSplashDuration - elapsed);
    }

    if (!mounted) return;

    if (AppBootstrap.instance.status.value != AppBootstrapStatus.ready) {
      Navigator.pushReplacementNamed(context, '/intro');
      return;
    }

    final hasSeenIntro = StorageService.introSeen;
    final hasSeenAccountOnboarding = StorageService.accountOnboardingSeen;
    final isQuranDownloaded = StorageService.quranContentDownloaded;
    final nextRoute = !hasSeenIntro
        ? '/intro'
        : (!hasSeenAccountOnboarding
              ? '/onboarding-auth'
              : (isQuranDownloaded ? '/home' : '/content-download'));
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.background],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: _animation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mosque_outlined,
                    size: 100,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.appName.tr,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
