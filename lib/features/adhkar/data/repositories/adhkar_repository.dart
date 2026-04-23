import 'dart:convert';
import 'package:yusr_app/core/utils/content_file_loader.dart';
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

    final result = await ContentFileLoader.loadAndParse<List<AdhkarCategory>>(
      fileCandidates: _downloadedAdhkarFileCandidates,
      type: DownloadContentType.adhkar,
      parser: _parseAdhkarCategories,
      assetPath: 'assets/data/adhkar.json',
    );

    if (result != null) {
      _cache = result;
      return _cache!;
    }

    final remote = await _loadRemoteCategories();
    if (remote.isNotEmpty) {
      _cache = remote;
      return _cache!;
    }

    return const [];
  }

  Future<List<AdhkarCategory>> _loadRemoteCategories() async {
    try {
      return await _remoteDataSource?.loadCategories() ?? const [];
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
