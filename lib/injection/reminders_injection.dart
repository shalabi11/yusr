import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_remote_sync_service.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
import 'package:yusr_app/features/reminders/domain/usecases/reminders_use_cases.dart';

void registerRemindersDependencies(GetIt sl) {
  if (!sl.isRegistered<RemindersRepository>()) {
    sl.registerLazySingleton<RemindersRepository>(
      () => RemindersRepository(
        remoteSync: sl.isRegistered<SupabaseClient>()
            ? RemindersRemoteSyncService(sl<SupabaseClient>())
            : null,
      ),
    );
  }

  if (!sl.isRegistered<RemindersUseCases>()) {
    sl.registerLazySingleton<RemindersUseCases>(
      () => RemindersUseCases(sl<RemindersRepository>()),
    );
  }
}
