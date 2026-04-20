import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/data/search/quran_smart_search_service.dart';

class QuranUseCases {
  QuranUseCases(this._repository, {QuranSmartSearchService? smartSearchService})
    : _smartSearchService = smartSearchService;

  final QuranRepository _repository;
  final QuranSmartSearchService? _smartSearchService;

  Future<List<QuranSurah>> loadSurahs() {
    return _repository.loadSurahs();
  }

  Future<void> syncProgressOnStartup() {
    return _repository.syncProgressOnStartup();
  }

  QuranLastRead? getLastRead() {
    return _repository.getLastRead();
  }

  Future<void> saveLastRead(QuranLastRead data) {
    return _repository.saveLastRead(data);
  }

  List<QuranBookmark> getBookmarks() {
    return _repository.getBookmarks();
  }

  Future<void> addBookmark(QuranLastRead data) {
    return _repository.addBookmark(data);
  }

  Future<void> removeBookmark(String id) {
    return _repository.removeBookmark(id);
  }

  Future<List<int>> pagesForSurah(int surahNumber) {
    return _repository.pagesForSurah(surahNumber);
  }

  Future<List<int>> pagesForJuz(int juzNumber) {
    return _repository.pagesForJuz(juzNumber);
  }

  KhatmaPlan calculateKhatmaPlan(int days) {
    return _repository.calculateKhatmaPlan(days);
  }

  Future<QuranLastRead?> getLastReadForPage(int pageNumber) {
    return _repository.getLastReadForPage(pageNumber);
  }

  Future<Map<int, QuranPageMeta>> loadPageMetaByPage() {
    return _repository.loadPageMetaByPage();
  }

  Future<Map<int, String>> loadPageImageUrls() {
    return _repository.loadPageImageUrls();
  }

  Future<Map<int, String>> loadLocalPageImagePaths() {
    return _repository.loadLocalPageImagePaths();
  }

  Future<void> primeSmartSearchIndex(List<QuranSurah> surahs) {
    final service = _smartSearchService;
    if (service == null) {
      return Future<void>.value();
    }
    return service.ensureIndex(surahs);
  }

  Future<List<QuranSmartSearchMatch>> searchSurahs(
    String query, {
    int limit = 60,
  }) {
    final service = _smartSearchService;
    if (service == null) {
      return Future<List<QuranSmartSearchMatch>>.value(
        const <QuranSmartSearchMatch>[],
      );
    }
    return service.search(query, limit: limit);
  }
}
