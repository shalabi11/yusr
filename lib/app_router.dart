import 'package:flutter/material.dart';
import 'package:yusr_app/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:yusr_app/features/splash/splash_screen.dart';
import 'package:yusr_app/features/intro/intro_screen.dart';
import 'package:yusr_app/features/home/home_screen.dart';
import 'package:yusr_app/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_screen.dart';
import 'package:yusr_app/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:yusr_app/features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/intro':
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
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
      default:
        return null;
    }
  }
}
