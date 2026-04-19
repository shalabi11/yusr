class QuranBookmark {
  final String id;
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final int juzNumber;
  final DateTime createdAt;

  const QuranBookmark({
    required this.id,
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.juzNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'verseNumber': verseNumber,
    'pageNumber': pageNumber,
    'juzNumber': juzNumber,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QuranBookmark.fromJson(Map<String, dynamic> json) => QuranBookmark(
    id: json['id']?.toString() ?? '',
    surahNumber: json['surahNumber'] as int? ?? 1,
    verseNumber: json['verseNumber'] as int? ?? 1,
    pageNumber: json['pageNumber'] as int? ?? 1,
    juzNumber: json['juzNumber'] as int? ?? 1,
    createdAt:
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now(),
  );
}
