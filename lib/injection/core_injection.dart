import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/services/storage/istorage_service.dart';
import 'package:yusr_app/core/services/storage/storage_sevice_impl.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/core/sync/sync_orchestrator.dart';

void registerCoreServices(GetIt sl, SharedPreferences prefs) {
  if (!sl.isRegistered<IStorageService>()) {
    sl.registerLazySingleton<IStorageService>(() => StorageServiceImpl(prefs));
  }
  if (!sl.isRegistered<INotificationService>()) {
    sl.registerLazySingleton<INotificationService>(
      () => NotificationServiceAdapter(),
    );
  }
  if (SupabaseBootstrap.isEnabled && !sl.isRegistered<SupabaseClient>()) {
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 45),
        ),
      ),
    );
  }
  if (!sl.isRegistered<SyncOrchestrator>()) {
    sl.registerLazySingleton<SyncOrchestrator>(SyncOrchestrator.new);
  }
}
