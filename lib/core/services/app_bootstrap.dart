import 'dart:async';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/utils/app_logger.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/services/storage/storage_hive_bootstrap.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
import 'package:yusr_app/injection_container.dart';

enum AppBootstrapStatus { idle, running, ready, failed }

class AppBootstrap {
  AppBootstrap._();

  static final AppBootstrap instance = AppBootstrap._();

  final ValueNotifier<AppBootstrapStatus> status =
      ValueNotifier<AppBootstrapStatus>(AppBootstrapStatus.idle);
  final Completer<void> _readyCompleter = Completer<void>();
  Future<void>? _deferredInitFuture;

  Object? _error;

  Future<void> get ready => _readyCompleter.future;

  Object? get error => _error;

  Future<void> start() async {
    if (status.value == AppBootstrapStatus.running ||
        status.value == AppBootstrapStatus.ready) {
      return ready;
    }

    status.value = AppBootstrapStatus.running;

    try {
      final sharedPrefsFuture = SharedPreferences.getInstance();

      await Future.wait<void>(<Future<void>>[
        sharedPrefsFuture.then<void>(initializeStorageHive),
        SupabaseBootstrap.init(),
      ]);

      final sharedPreferences = await sharedPrefsFuture;
      await initDependencies(sharedPreferences: sharedPreferences);

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
