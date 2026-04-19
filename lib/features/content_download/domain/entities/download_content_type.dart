enum DownloadContentType {
  quran,
  adhkar;

  String get value => name;

  static DownloadContentType? tryFromValue(String raw) {
    final normalized = raw
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '');
    switch (normalized) {
      case 'quran':
      case 'quranimages':
      case 'quranpages':
      case 'images':
        return DownloadContentType.quran;
      case 'adhkar':
      case 'azkar':
      case 'adkar':
      case 'athkar':
        return DownloadContentType.adhkar;
      default:
        return null;
    }
  }

  static DownloadContentType fromValue(String raw) {
    return tryFromValue(raw) ?? DownloadContentType.adhkar;
  }
}
