import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/app_router.dart';
import 'package:yusr_app/core/theme/app_theme.dart';
import 'package:yusr_app/core/services/app_bootstrap.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';

import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:yusr_app/injection_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IslamicApp());
  Future.microtask(() => AppBootstrap.instance.start());
}

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppBootstrapStatus>(
      valueListenable: AppBootstrap.instance.status,
      builder: (context, status, _) {
        if (status != AppBootstrapStatus.ready) {
          return MaterialApp(
            title: 'يُسْر',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: '/',
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  sl<SettingsCubit>()..loadFromRemoteOnStartup(),
            ),
            BlocProvider(
              create: (context) =>
                  sl<PrayerTimesCubit>()..fetchPrayerTimes(force: true),
            ),
          ],
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return MaterialApp(
                key: ValueKey(state.langCode),
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
      },
    );
  }
}
