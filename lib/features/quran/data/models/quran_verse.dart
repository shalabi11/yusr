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
