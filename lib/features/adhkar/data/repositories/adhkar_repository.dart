import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';

import '../models/adhkar_models.dart';
import 'adhkar_remote_data_source.dart';

class AdhkarRepository {
  AdhkarRepository({AdhkarRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  static List<AdhkarCategory>? _cache;
  static const List<String> _downloadedAdhkarFileCandidates = <String>[
    'adhkar.json',
    'azkar.json',
    'daily_adhkar.json',
  ];
  final AdhkarRemoteDataSource? _remoteDataSource;

  Future<List<AdhkarCategory>> loadCategories() async {
    if (_cache != null) return _cache!;

    final downloaded = await _loadDownloadedCategories();
    if (downloaded.isNotEmpty) {
      _cache = downloaded;
      return _cache!;
    }

    final remote = await _loadRemoteCategories();
    if (remote.isNotEmpty) {
      _cache = remote;
      return _cache!;
    }

    return _loadLocalCategories();
  }

  Future<List<AdhkarCategory>> _loadRemoteCategories() async {
    try {
      return await _remoteDataSource?.loadCategories() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  Future<List<AdhkarCategory>> _loadLocalCategories() async {
    final raw = await rootBundle.loadString('assets/data/adhkar.json');
    _cache = await compute(_parseAdhkarCategories, raw);
    return _cache!;
  }

  Future<List<AdhkarCategory>> _loadDownloadedCategories() async {
    if (!StorageService.adhkarContentDownloaded) {
      return const [];
    }

    final basePath = StorageService.downloadedContentBasePath;
    if (basePath == null || basePath.isEmpty) {
      return const [];
    }

    final adhkarDir = Directory(
      '$basePath${Platform.pathSeparator}${DownloadContentType.adhkar.value}',
    );
    if (!await adhkarDir.exists()) {
      return const [];
    }

    for (final fileName in _downloadedAdhkarFileCandidates) {
      final parsed = await _parseAdhkarFromFile(
        File('${adhkarDir.path}${Platform.pathSeparator}$fileName'),
      );
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    await for (final entity in adhkarDir.list()) {
      if (entity is! File || !entity.path.toLowerCase().endsWith('.json')) {
        continue;
      }
      final parsed = await _parseAdhkarFromFile(entity);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    return const [];
  }

  Future<List<AdhkarCategory>> _parseAdhkarFromFile(File file) async {
    try {
      if (!await file.exists()) {
        return const [];
      }
      final raw = await file.readAsString();
      return compute(_parseAdhkarCategories, raw);
    } catch (_) {
      return const [];
    }
  }
}

List<AdhkarCategory> _parseAdhkarCategories(String raw) {
  final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
  return data
      .map((e) => AdhkarCategory.fromJson(e as Map<String, dynamic>))
      .toList();
}
