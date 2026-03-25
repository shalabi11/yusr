class QuranVerse {
  final int number;
  final String textAr;
  final int juz;
  final int page;

  const QuranVerse({
    required this.number,
    required this.textAr,
    required this.juz,
    required this.page,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    final text = (json['text'] as Map<String, dynamic>? ?? const {});
    return QuranVerse(
      number: json['number'] as int? ?? 0,
      textAr: text['ar']?.toString() ?? '',
      juz: json['juz'] as int? ?? 1,
      page: json['page'] as int? ?? 1,
    );
  }
}

class QuranSurah {
  final int number;
  final String nameAr;
  final String nameEn;
  final int versesCount;
  final List<QuranVerse> verses;

  const QuranSurah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.versesCount,
    required this.verses,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as Map<String, dynamic>? ?? const {});
    final versesJson = (json['verses'] as List<dynamic>? ?? const []);
    return QuranSurah(
      number: json['number'] as int? ?? 0,
      nameAr: name['ar']?.toString() ?? '',
      nameEn: name['en']?.toString() ?? '',
      versesCount: json['verses_count'] as int? ?? versesJson.length,
      verses: versesJson
          .map((v) => QuranVerse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

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

class KhatmaPlan {
  final int days;
  final int pagesPerDay;
  final double juzPerDay;

  const KhatmaPlan({
    required this.days,
    required this.pagesPerDay,
    required this.juzPerDay,
  });
}
