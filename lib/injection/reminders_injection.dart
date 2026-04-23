import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/sync/sync_orchestrator.dart';
import 'package:yusr_app/core/sync/unified_sync_engine.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_remote_sync_service.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
import 'package:yusr_app/features/reminders/domain/usecases/reminders_use_cases.dart';

void registerRemindersDependencies(GetIt sl) {
  if (!sl.isRegistered<RemindersRepository>()) {
    sl.registerLazySingleton<RemindersRepository>(
      () {
        final repo = RemindersRepository(
          remoteSync: sl.isRegistered<SupabaseClient>()
              ? RemindersRemoteSyncService(
                  sl<SupabaseClient>(),
                  syncEngine: sl<UnifiedSyncEngine>(),
                )
              : null,
        );
        sl<SyncOrchestrator>().register(repo);
        return repo;
      },
    );
  }

  if (!sl.isRegistered<RemindersUseCases>()) {
    sl.registerLazySingleton<RemindersUseCases>(
      () => RemindersUseCases(sl<RemindersRepository>()),
    );
  }
}
