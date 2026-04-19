part of 'injection_container.dart';

void _registerCoreServices(SharedPreferences prefs) {
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
}
