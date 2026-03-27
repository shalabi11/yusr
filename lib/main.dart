import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/app_router.dart';
import 'package:yusr_app/core/theme/app_theme.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';

import 'package:yusr_app/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await NotificationService.init();
  await _syncReminderNotificationsOnStartup();
  runApp(const IslamicApp());
}

Future<void> _syncReminderNotificationsOnStartup() async {
  final reminders = RemindersRepository().getReminders();
  await NotificationService.syncReminders(reminders);
  await NotificationService.syncFastingReminders();
}

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(
          create: (context) =>
              PrayerTimesCubit(PrayerTimesRepository())
                ..fetchPrayerTimes(force: true),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            key: ValueKey(
              state.langCode,
            ), // 🚀 Forces complete refresh of widget tree when language changes
            title: 'يُسْر',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: '/',
            builder: (context, child) {
              return Directionality(
                textDirection: state.langCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
