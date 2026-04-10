import 'quran_verse.dart';

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
