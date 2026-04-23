import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';
import 'package:yusr_app/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:yusr_app/features/quran/presentation/cubit/quran_state.dart';
import 'package:yusr_app/features/quran/presentation/models/quran_offline_availability.dart';

import '../../support/fake_storage_service.dart';

void main() {
  group('QuranCubit cache-first behavior', () {
    late Directory tempDir;
    late FakeStorageService storage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('quran_cubit_test_');

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

      await File(
        '${quranDir.path}${Platform.pathSeparator}1.png',
      ).writeAsString('fake image content');

      storage = FakeStorageService()
        ..quranContentDownloaded = true
        ..downloadedContentBasePath = tempDir.path;

      StorageService.bind(storage);

      final repository = QuranRepository();
      await repository.loadSurahs();
      await repository.loadLocalPageImagePaths();

      await storage.saveData(
        'quran_last_read',
        const QuranLastRead(
          surahNumber: 1,
          verseNumber: 1,
          pageNumber: 1,
          juzNumber: 1,
        ).toJson(),
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('starts with cached Quran data', () {
      final cubit = QuranCubit(useCases: QuranUseCases(QuranRepository()));
      addTearDown(cubit.close);

      expect(cubit.state.status, QuranStatus.loaded);
      expect(cubit.state.surahs, isNotEmpty);
      expect(cubit.state.filteredSurahs, equals(cubit.state.surahs));
      expect(cubit.state.lastRead?.pageNumber, 1);
      expect(
        cubit.state.offlineAvailabilityBySurah[1],
        QuranOfflineAvailability.full,
      );
      expect(cubit.state.errorMessage, isNull);
    });

    test('refreshes cached metadata without dropping loaded content', () async {
      final cubit = QuranCubit(useCases: QuranUseCases(QuranRepository()));
      addTearDown(cubit.close);

      await storage.saveData(
        'quran_last_read',
        const QuranLastRead(
          surahNumber: 2,
          verseNumber: 2,
          pageNumber: 3,
          juzNumber: 2,
        ).toJson(),
      );

      cubit.refreshCachedState();

      expect(cubit.state.status, QuranStatus.loaded);
      expect(cubit.state.surahs, isNotEmpty);
      expect(cubit.state.filteredSurahs, isNotEmpty);
      expect(cubit.state.lastRead?.surahNumber, 2);
      expect(cubit.state.lastRead?.pageNumber, 3);
      expect(cubit.state.errorMessage, isNull);
    });
  });
}
