import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';

import '../../support/fake_storage_service.dart';

void main() {
  group('QuranRepository indexes', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('quran_repo_test_');
      final quranDir = Directory(
        '${tempDir.path}${Platform.pathSeparator}quran',
      );
      await quranDir.create(recursive: true);

      final file = File(
        '${quranDir.path}${Platform.pathSeparator}mainDataQuran.json',
      );
      await file.writeAsString(
        '[\n'
        '  {\n'
        '    "number": 1,\n'
        '    "name": {"ar": "الفاتحة", "en": "Al-Fatiha"},\n'
        '    "verses_count": 2,\n'
        '    "verses": [\n'
        '      {"number": 1, "text": {"ar": "بسم الله"}, "juz": 1, "page": 1},\n'
        '      {"number": 2, "text": {"ar": "الحمد لله"}, "juz": 1, "page": 1}\n'
        '    ]\n'
        '  },\n'
        '  {\n'
        '    "number": 2,\n'
        '    "name": {"ar": "البقرة", "en": "Al-Baqarah"},\n'
        '    "verses_count": 2,\n'
        '    "verses": [\n'
        '      {"number": 1, "text": {"ar": "الم"}, "juz": 1, "page": 2},\n'
        '      {"number": 2, "text": {"ar": "ذلك الكتاب"}, "juz": 2, "page": 3}\n'
        '    ]\n'
        '  }\n'
        ']',
      );

      final storage = FakeStorageService()
        ..quranContentDownloaded = true
        ..downloadedContentBasePath = tempDir.path;
      StorageService.bind(storage);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('builds and reuses juz/surah/page indexes', () async {
      final repository = QuranRepository();

      final surahs = await repository.loadSurahs();
      final juz1 = await repository.pagesForJuz(1);
      final juz2 = await repository.pagesForJuz(2);
      final surah2Pages = await repository.pagesForSurah(2);
      final pageMeta = await repository.loadPageMetaByPage();
      final fromPage = await repository.getLastReadForPage(3);

      expect(surahs.length, 2);
      expect(juz1, <int>[1, 2]);
      expect(juz2, <int>[3]);
      expect(surah2Pages, <int>[2, 3]);
      expect(pageMeta[1]?.surahName, 'الفاتحة');
      expect(pageMeta[3]?.juzNumber, 2);
      expect(fromPage?.surahNumber, 2);
      expect(fromPage?.pageNumber, 3);
    });
  });
}
