enum DownloadContentType {
  quran,
  adhkar;

  String get value => name;

  static DownloadContentType fromValue(String raw) {
    switch (raw.toLowerCase()) {
      case 'quran':
        return DownloadContentType.quran;
      case 'adhkar':
      default:
        return DownloadContentType.adhkar;
    }
  }
}
