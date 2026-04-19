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

    final typeValues = targetTypes.map((e) => e.value).toList(growable: false);
    final response = await client
        .from('files')
        .select('id, name, type, url, size')
        .inFilter('type', typeValues)
        .order('id', ascending: true);

    final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return rows
        .map(DownloadableContentFileModel.fromMap)
        .where((e) => e.name.isNotEmpty && e.url.isNotEmpty)
        .toList();
  }
}
