import 'dart:async';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/features/reminders/data/repositories/reminders_repository.dart';
import 'package:yusr_app/injection_container.dart';

enum AppBootstrapStatus { idle, running, ready, failed }

class AppBootstrap {
  AppBootstrap._();

  static final AppBootstrap instance = AppBootstrap._();

  final ValueNotifier<AppBootstrapStatus> status = ValueNotifier<AppBootstrapStatus>(
    AppBootstrapStatus.idle,
  );
  final Completer<void> _readyCompleter = Completer<void>();

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
      await Hive.initFlutter();
      await SupabaseBootstrap.init();
      await initDependencies();
      await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: false);

      // Tune cache defaults for image-heavy screens like Quran page viewer.
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.maximumSize = 250;
      imageCache.maximumSizeBytes = 140 << 20;

      try {
        await NotificationService.init();
      } catch (_) {
        // Notifications should not block app usability.
      }

      try {
        final reminders = await sl<RemindersRepository>().loadRemindersOnStartup();
        await NotificationService.syncReminders(reminders);
        await NotificationService.syncFastingReminders();
      } catch (_) {
        // Reminder sync should not block app usability.
      }

      status.value = AppBootstrapStatus.ready;
    } catch (e) {
      _error = e;
      status.value = AppBootstrapStatus.failed;
    } finally {
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    }
  }
}