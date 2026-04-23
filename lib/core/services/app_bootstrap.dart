import 'dart:async';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/utils/app_logger.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/services/storage/storage_hive_bootstrap.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/core/sync/sync_orchestrator.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
import 'package:yusr_app/injection_container.dart';

enum AppBootstrapStatus { idle, running, ready, failed }

typedef SharedPreferencesLoader = Future<SharedPreferences> Function();
typedef StorageHiveInitializer = Future<void> Function(SharedPreferences prefs);
typedef SupabaseInitializer = Future<void> Function();
typedef DependenciesInitializer =
    Future<void> Function({required SharedPreferences sharedPreferences});

class AppBootstrap {
  AppBootstrap._();

  static final AppBootstrap instance = AppBootstrap._();

  @visibleForTesting
  static SharedPreferencesLoader sharedPreferencesLoader =
      SharedPreferences.getInstance;

  @visibleForTesting
  static StorageHiveInitializer storageHiveInitializer = initializeStorageHive;

  @visibleForTesting
  static SupabaseInitializer supabaseInitializer = SupabaseBootstrap.init;

  @visibleForTesting
  static DependenciesInitializer dependenciesInitializer = initDependencies;

  final ValueNotifier<AppBootstrapStatus> status =
      ValueNotifier<AppBootstrapStatus>(AppBootstrapStatus.idle);
  Completer<void> _readyCompleter = Completer<void>();
  Future<void>? _deferredInitFuture;

  Object? _error;

  Future<void> get ready => _readyCompleter.future;

  Object? get error => _error;

  @visibleForTesting
  void resetForTesting() {
    status.value = AppBootstrapStatus.idle;
    _error = null;
    _deferredInitFuture = null;
    _readyCompleter = Completer<void>();
  }

  @visibleForTesting
  static void resetTestHooks() {
    sharedPreferencesLoader = SharedPreferences.getInstance;
    storageHiveInitializer = initializeStorageHive;
    supabaseInitializer = SupabaseBootstrap.init;
    dependenciesInitializer = initDependencies;
  }

  Future<void> start() async {
    if (status.value == AppBootstrapStatus.running ||
        status.value == AppBootstrapStatus.ready) {
      return ready;
    }

    status.value = AppBootstrapStatus.running;

    try {
      final sharedPrefsFuture = sharedPreferencesLoader();

      await Future.wait<void>(<Future<void>>[
        sharedPrefsFuture.then<void>(storageHiveInitializer),
        supabaseInitializer(),
      ]);

      final sharedPreferences = await sharedPrefsFuture;
      await dependenciesInitializer(sharedPreferences: sharedPreferences);

      // Tune cache defaults for image-heavy screens like Quran page viewer.
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.maximumSize = 180;
      imageCache.maximumSizeBytes = 96 << 20;

      status.value = AppBootstrapStatus.ready;
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
      _scheduleDeferredInitAfterFirstFrame();
    } catch (error, stackTrace) {
      _error = error;
      AppLogger.error(
        'bootstrap',
        'start',
        'App bootstrap failed.',
        error: error,
        stackTrace: stackTrace,
      );
      status.value = AppBootstrapStatus.failed;
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    }
  }

  void _scheduleDeferredInitAfterFirstFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deferredInitFuture ??= _runDeferredInitialization();
    });
  }

  Future<void> _runDeferredInitialization() async {
    try {
      await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: false);

      try {
        await NotificationService.init();
      } catch (error, stackTrace) {
        AppLogger.warning(
          'bootstrap',
          'start',
          'Notification init failed. Continuing startup.',
          error: error,
        );
        AppLogger.error(
          'bootstrap',
          'start',
          'Stack trace for notification init failure.',
          error: error,
          stackTrace: stackTrace,
        );
        // Notifications should not block app usability.
      }

      try {
        final reminders = await sl<RemindersRepository>()
            .loadRemindersOnStartup();
        await NotificationService.syncReminders(reminders);
        await NotificationService.syncFastingReminders();
      } catch (error, stackTrace) {
        AppLogger.warning(
          'bootstrap',
          'start',
          'Reminder sync failed. Continuing startup.',
          error: error,
        );
        AppLogger.error(
          'bootstrap',
          'start',
          'Stack trace for reminder sync failure.',
          error: error,
          stackTrace: stackTrace,
        );
        // Reminder sync should not block app usability.
      }

      // Pre-load Quran catalog in background so it opens instantly later.
      unawaited(sl<QuranRepository>().primeCatalog());

      unawaited(sl<SyncOrchestrator>().syncAll());
    } catch (error, stackTrace) {
      AppLogger.warning(
        'bootstrap',
        'deferredInitialization',
        'Deferred bootstrap services failed. App remains usable.',
        error: error,
      );
      AppLogger.error(
        'bootstrap',
        'deferredInitialization',
        'Stack trace for deferred bootstrap failure.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
