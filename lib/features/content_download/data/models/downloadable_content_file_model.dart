import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';
import 'package:yusr_app/features/content_download/domain/entities/downloadable_content_file.dart';

class DownloadableContentFileModel extends DownloadableContentFile {
  const DownloadableContentFileModel({
    required super.id,
    required super.name,
    required super.type,
    required super.url,
    required super.size,
  });

  factory DownloadableContentFileModel.fromMap(Map<String, dynamic> map) {
    return DownloadableContentFileModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: DownloadContentType.fromValue(map['type']?.toString() ?? ''),
      url: map['url']?.toString() ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
    );
  }
}
