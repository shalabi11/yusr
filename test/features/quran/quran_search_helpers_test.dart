import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/features/quran/data/models/quran_surah.dart';
import 'package:yusr_app/features/quran/data/models/quran_verse.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_surah_tab_helpers.dart';

void main() {
  test('buildSurahSubtitle uses precomputed preview when searching', () {
    const surah = QuranSurah(
      number: 1,
      nameAr: 'الفاتحة',
      nameEn: 'Al-Fatiha',
      versesCount: 7,
      verses: <QuranVerse>[],
    );

    final subtitle = buildSurahSubtitle(
      surah,
      'الحمد',
      'الحمد لله رب العالمين',
    );

    expect(subtitle, startsWith('نتيجة آية:'));
    expect(subtitle.contains('الحمد لله'), isTrue);
  });
}
