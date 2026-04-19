class QuranLastRead {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final int juzNumber;

  const QuranLastRead({
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.juzNumber,
  });

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'verseNumber': verseNumber,
    'pageNumber': pageNumber,
    'juzNumber': juzNumber,
  };

  factory QuranLastRead.fromJson(Map<String, dynamic> json) => QuranLastRead(
    surahNumber: json['surahNumber'] as int? ?? 1,
    verseNumber: json['verseNumber'] as int? ?? 1,
    pageNumber: json['pageNumber'] as int? ?? 1,
    juzNumber: json['juzNumber'] as int? ?? 1,
  );
}
