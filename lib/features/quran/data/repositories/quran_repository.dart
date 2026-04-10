import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yusr_app/core/services/storage_service.dart';

import '../models/quran_models.dart';
import 'quran_remote_sync_service.dart';

part 'quran_repository_catalog.dart';
part 'quran_repository_progress.dart';
part 'quran_repository_startup_sync.dart';

class QuranRepository {
  QuranRepository({QuranRemoteSyncService? remoteSync})
    : _remoteSync = remoteSync;

  static const String _quranAssetPath = 'assets/data/mainDataQuran.json';
  static const String _lastReadKey = 'quran_last_read';
  static const String _bookmarksKey = 'quran_bookmarks';
  static List<QuranSurah>? _cachedSurahs;

  final QuranRemoteSyncService? _remoteSync;
  bool _startupSynced = false;
}
