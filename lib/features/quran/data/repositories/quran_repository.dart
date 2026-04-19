import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';

import '../models/quran_models.dart';
import 'quran_catalog_remote_service.dart';
import 'quran_remote_sync_service.dart';

part 'quran_repository_catalog.dart';
part 'quran_repository_progress.dart';
part 'quran_repository_startup_sync.dart';

class QuranRepository {
  QuranRepository({
    QuranRemoteSyncService? remoteSync,
    QuranCatalogRemoteService? catalogRemote,
  }) : _remoteSync = remoteSync,
       _catalogRemote = catalogRemote;

  static const List<String> _downloadedQuranFileCandidates = <String>[
    'mainDataQuran.json',
    'quran.json',
    'catalog.json',
  ];
  static const String _lastReadKey = 'quran_last_read';
  static const String _bookmarksKey = 'quran_bookmarks';
  static List<QuranSurah>? _cachedSurahs;
  static Map<int, String>? _cachedPageImageUrls;
  static Map<int, String>? _cachedLocalPageImagePaths;

  final QuranRemoteSyncService? _remoteSync;
  final QuranCatalogRemoteService? _catalogRemote;
  bool _startupSynced = false;
}
