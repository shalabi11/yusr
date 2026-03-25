import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/adhkar_models.dart';

class AdhkarRepository {
  static List<AdhkarCategory>? _cache;

  Future<List<AdhkarCategory>> loadCategories() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/data/adhkar.json');
    final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
    _cache = data
        .map((e) => AdhkarCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }
}
