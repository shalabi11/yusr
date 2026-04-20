import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_catalog_remote_service.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_remote_sync_service.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/data/search/quran_smart_search_service.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';

void registerQuranDependencies(GetIt sl) {
  if (!sl.isRegistered<QuranRepository>()) {
    sl.registerLazySingleton<QuranRepository>(
      () => QuranRepository(
        remoteSync: sl.isRegistered<SupabaseClient>()
            ? QuranRemoteSyncService(sl<SupabaseClient>())
            : null,
        catalogRemote: sl.isRegistered<SupabaseClient>()
            ? QuranCatalogRemoteService(sl<SupabaseClient>())
            : null,
      ),
    );
  }

  if (!sl.isRegistered<QuranSmartSearchService>()) {
    sl.registerLazySingleton<QuranSmartSearchService>(
      QuranSmartSearchService.new,
    );
  }

  if (!sl.isRegistered<QuranUseCases>()) {
    sl.registerLazySingleton<QuranUseCases>(
      () => QuranUseCases(
        sl<QuranRepository>(),
        smartSearchService: sl<QuranSmartSearchService>(),
      ),
    );
  }
}
