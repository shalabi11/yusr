import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:yusr_app/core/database/app_database.dart';
import 'package:yusr_app/core/sync/sync_orchestrator.dart';
import 'package:yusr_app/core/sync/unified_sync_engine.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_catalog_remote_service.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_remote_sync_service.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
// import 'package:yusr_app/core/database/app_database.dart';
// import 'package:yusr_app/features/quran/data/search/quran_search_db_layer.dart';
// import 'package:yusr_app/features/quran/data/search/quran_search_index_builder.dart';
// import 'package:yusr_app/features/quran/data/search/quran_search_query_engine.dart';
// import 'package:yusr_app/features/quran/data/search/quran_smart_search_service.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';

void registerQuranDependencies(GetIt sl) {
  if (!sl.isRegistered<QuranRepository>()) {
    sl.registerLazySingleton<QuranRepository>(
      () {
        final repo = QuranRepository(
          remoteSync: sl.isRegistered<SupabaseClient>()
              ? QuranRemoteSyncService(
                  sl<SupabaseClient>(),
                  syncEngine: sl<UnifiedSyncEngine>(),
                )
              : null,
          catalogRemote: sl.isRegistered<SupabaseClient>()
              ? QuranCatalogRemoteService(sl<SupabaseClient>())
              : null,
        );
        sl<SyncOrchestrator>().register(repo);
        return repo;
      },
    );
  }

  /*
  if (!sl.isRegistered<QuranSearchDbLayer>()) {
    final dbLayer = QuranSearchDbLayer();
    AppDatabase.instance.registerTable(dbLayer);
    sl.registerLazySingleton<QuranSearchDbLayer>(() => dbLayer);
  }
  */

  /*
  if (!sl.isRegistered<QuranSmartSearchService>()) {
    sl.registerLazySingleton<QuranSmartSearchService>(
      () => QuranSmartSearchService(
        dbLayer: sl<QuranSearchDbLayer>(),
        indexBuilder: QuranSearchIndexBuilder(sl<QuranSearchDbLayer>()),
        queryEngine: QuranSearchQueryEngine(sl<QuranSearchDbLayer>()),
      ),
    );
  }
  */

  if (!sl.isRegistered<QuranUseCases>()) {
    sl.registerLazySingleton<QuranUseCases>(
      () => QuranUseCases(sl<QuranRepository>()),
      /*
      () => QuranUseCases(
        sl<QuranRepository>(),
        smartSearchService: sl<QuranSmartSearchService>(),
      ),
      */
    );
  }
}
