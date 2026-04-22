import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/features/content_download/data/models/downloadable_content_file_model.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';

class ContentRemoteDataSource {
  const ContentRemoteDataSource(this._supabaseClient);

  final SupabaseClient? _supabaseClient;

  Future<List<DownloadableContentFileModel>> fetchManifest({
    required Set<DownloadContentType> targetTypes,
  }) async {
    final client = _supabaseClient;
    if (client == null || targetTypes.isEmpty) {
      return const <DownloadableContentFileModel>[];
    }

    final typeValues = _typeValuesForTargets(
      targetTypes,
    ).toList(growable: false);

    try {
      final response = await client
          .from('files')
          .select('id, name, type, url, size')
          .inFilter('type', typeValues)
          .order('id', ascending: true);

      final rows = List<Map<String, dynamic>>.from(response as List);
      final files = <DownloadableContentFileModel>[];
      for (final row in rows) {
        try {
          final file = DownloadableContentFileModel.fromMap(row);
          if (file.name.isNotEmpty && file.url.isNotEmpty) {
            files.add(file);
          }
        } on FormatException {
          // Ignore unrecognized rows instead of failing the full manifest request.
        }
      }

      return files;
    } catch (e) {
      throw Exception('Failed to fetch manifest: $e');
    }
  }

  Set<String> _typeValuesForTargets(Set<DownloadContentType> targetTypes) {
    final values = <String>{};
    if (targetTypes.contains(DownloadContentType.quran)) {
      values.addAll(const <String>[
        'quran',
        'quran_images',
        'quran-images',
        'images',
      ]);
    }
    if (targetTypes.contains(DownloadContentType.adhkar)) {
      values.addAll(const <String>['adhkar', 'azkar', 'adkar']);
    }
    return values;
  }
}
