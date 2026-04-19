import 'package:equatable/equatable.dart';

import 'download_content_type.dart';

class DownloadableContentFile extends Equatable {
  const DownloadableContentFile({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.size,
  });

  final String id;
  final String name;
  final DownloadContentType type;
  final String url;
  final int size;

  @override
  List<Object?> get props => [id, name, type, url, size];
}
