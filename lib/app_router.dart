import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/ai_assistant/presentation/screens/ai_assistant_entry_screen.dart';
import 'package:yusr_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:yusr_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:yusr_app/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/splash/splash_screen.dart';
import 'package:yusr_app/features/intro/presentation/intro_screen.dart';
import 'package:yusr_app/features/home/presentation/screens/home_screen.dart';
import 'package:yusr_app/features/onboarding/presentation/screens/account_onboarding_screen.dart';
import 'package:yusr_app/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_screen.dart';
import 'package:yusr_app/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:yusr_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:yusr_app/features/content_download/presentation/screens/content_download_screen.dart';
import 'package:yusr_app/injection_container.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/intro':
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/onboarding-auth':
        return MaterialPageRoute(
          builder: (_) => const AccountOnboardingScreen(),
        );
      case '/reminders':
        return MaterialPageRoute(builder: (_) => const RemindersScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/quran':
        return MaterialPageRoute(builder: (_) => const QuranScreen());
      case '/adhkar':
        return MaterialPageRoute(builder: (_) => const AdhkarScreen());
      case '/prayer':
        return MaterialPageRoute(builder: (_) => const PrayerTimesScreen());
      case '/assistant':
        return MaterialPageRoute(
          builder: (_) => const AIAssistantEntryScreen(),
        );
      case '/content-download':
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ContentDownloadCubit>(
            create: (_) => sl<ContentDownloadCubit>()..syncInitialState(),
            child: const ContentDownloadScreen(),
          ),
        );
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/auth':
      case '/assistant-auth':
        final args = settings.arguments as Map<String, dynamic>?;
        final startInSignUpMode = args?['isSignUp'] == true;
        final successRoute = args?['successRoute']?.toString() ?? '/home';
        final clearStackOnSuccess = args?['clearStackOnSuccess'] == true;
        final markAccountOnboardingSeenOnSuccess =
            args?['markAccountOnboardingSeenOnSuccess'] == true;
        return MaterialPageRoute(
          builder: (_) => AuthScreen(
            startInSignUpMode: startInSignUpMode,
            successRoute: successRoute,
            clearStackOnSuccess: clearStackOnSuccess,
            markAccountOnboardingSeenOnSuccess:
                markAccountOnboardingSeenOnSuccess,
          ),
        );
      default:
        return null;
    }
  }
}
