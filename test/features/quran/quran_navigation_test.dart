import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_surah_tab.dart';

class FakeQuranRepository extends QuranRepository {
  FakeQuranRepository();
}

void main() {
  testWidgets('tapping surah opens text reader route', (tester) async {
    const surah = QuranSurah(
      number: 1,
      nameAr: 'الفاتحة',
      nameEn: 'Al-Fatiha',
      versesCount: 1,
      verses: <QuranVerse>[
        QuranVerse(
          number: 1,
          textAr: 'بسم الله الرحمن الرحيم',
          juz: 1,
          page: 1,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuranSurahTab(
            surahs: const <QuranSurah>[surah],
            search: '',
            matchedPreviewBySurah: const <int, String>{},
            readAsText: true,
            repo: FakeQuranRepository(),
            onReload: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('الفاتحة'));
    await tester.pumpAndSettle();

    expect(find.text('بسم الله الرحمن الرحيم'), findsOneWidget);
  });
}
