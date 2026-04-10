import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/adhkar_models.dart';
import 'adhkar_remote_data_source.dart';

class AdhkarRepository {
  AdhkarRepository({AdhkarRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  static List<AdhkarCategory>? _cache;
  final AdhkarRemoteDataSource? _remoteDataSource;

  Future<List<AdhkarCategory>> loadCategories() async {
    if (_cache != null) return _cache!;

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
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    _cache = data
        .map((e) => AdhkarCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }
}
