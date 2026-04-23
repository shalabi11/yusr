import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/utils/app_logger.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';
import 'package:yusr_app/features/quran/presentation/models/quran_offline_availability.dart';

import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  QuranCubit({required this.useCases}) : super(_buildInitialState(useCases));

  final QuranUseCases useCases;
  // Timer? _searchDebounce;

  static QuranState _buildInitialState(QuranUseCases useCases) {
    final cachedSurahs = useCases.peekCachedSurahs();
    if (cachedSurahs == null || cachedSurahs.isEmpty) {
      return const QuranState();
    }

    final cachedLocalPageImagePaths =
        useCases.peekCachedLocalPageImagePaths() ?? const <int, String>{};

    return QuranState(
      status: QuranStatus.loaded,
      surahs: cachedSurahs,
      filteredSurahs: cachedSurahs,
      lastRead: useCases.getLastRead(),
      khatmaPlan: useCases.calculateKhatmaPlan(30),
      offlineAvailabilityBySurah: _buildOfflineAvailability(
        cachedSurahs,
        cachedLocalPageImagePaths,
      ),
    );
  }

  void refreshCachedState() {
    final cachedSurahs = useCases.peekCachedSurahs();
    if (cachedSurahs == null || cachedSurahs.isEmpty) {
      return;
    }

    final cachedLocalPageImagePaths =
        useCases.peekCachedLocalPageImagePaths() ?? const <int, String>{};

    emit(
      state.copyWith(
        status: QuranStatus.loaded,
        surahs: cachedSurahs,
        filteredSurahs: cachedSurahs,
        lastRead: useCases.getLastRead(),
        khatmaPlan: state.khatmaPlan ?? useCases.calculateKhatmaPlan(30),
        offlineAvailabilityBySurah: _buildOfflineAvailability(
          cachedSurahs,
          cachedLocalPageImagePaths,
        ),
        errorMessage: null,
      ),
    );
  }

  Future<void> loadData() async {
    if (state.status == QuranStatus.loading) {
      return;
    }

    final cachedSurahs = useCases.peekCachedSurahs();
    if (cachedSurahs != null && cachedSurahs.isNotEmpty) {
      refreshCachedState();
      return;
    }

    emit(state.copyWith(status: QuranStatus.loading, errorMessage: null));

    try {
      final surahs = await useCases.loadSurahs();

      final localPageImagePathsFuture = useCases.loadLocalPageImagePaths();
      unawaited(_syncStartupProgressSafely());

      final localPageImagePaths = await localPageImagePathsFuture;
      final lastRead = useCases.getLastRead();
      final khatmaPlan = useCases.calculateKhatmaPlan(30);
      final offlineAvailability = _buildOfflineAvailability(
        surahs,
        localPageImagePaths,
      );

      emit(
        state.copyWith(
          status: QuranStatus.loaded,
          surahs: surahs,
          filteredSurahs: surahs,
          lastRead: lastRead,
          khatmaPlan: khatmaPlan,
          offlineAvailabilityBySurah: offlineAvailability,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'quran',
        'loadData',
        'Failed to load Quran screen data; falling back to cached state.',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: QuranStatus.error,
          errorMessage: 'تعذر تحميل بيانات القرآن الكريم.',
          surahs: const [],
          filteredSurahs: const [],
          lastRead: useCases.getLastRead(),
        ),
      );
    }
  }

  Future<void> _syncStartupProgressSafely() async {
    try {
      await useCases.syncProgressOnStartup();
    } catch (error) {
      AppLogger.warning(
        'quran',
        'syncProgressOnStartup',
        'Startup progress sync failed in background; keeping local values.',
        error: error,
      );
    }
  }

  /*
  Future<void> _primeSmartSearchIndexSafely(List<QuranSurah> surahs) async {
    try {
      await useCases.primeSmartSearchIndex(surahs);
    } catch (error) {
      AppLogger.warning(
        'quran',
        'primeSmartSearchIndex',
        'Skipping smart search indexing due to startup failure.',
        error: error,
      );
    }
  }
  */

  void computeKhatmaPlan(int days) {
    if (days <= 0) days = 30;
    final khatmaPlan = useCases.calculateKhatmaPlan(days);
    emit(state.copyWith(khatmaPlan: khatmaPlan));
  }

  Future<void> scheduleKhatmaReminder() async {
    final plan = state.khatmaPlan;
    if (plan == null) return;

    try {
      await NotificationService.scheduleDailyNotification(
        id: 7001,
        title: 'تذكير الختمة',
        body: 'ورد اليوم: ${plan.pagesPerDay} صفحات (${plan.juzPerDay} جزء)',
        time: const TimeOfDay(hour: 20, minute: 0),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'quran',
        'scheduleKhatmaReminder',
        'Failed to schedule khatma reminder',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /*
  void toggleSearch() {
    if (state.isSearching) {
      emit(state.copyWith(
        isSearching: false,
        searchQuery: '',
        filteredSurahs: state.surahs,
        matchedPreviewBySurah: const {},
      ));
    } else {
      emit(state.copyWith(isSearching: true));
    }
  }

  void filterSurahs(String query) {
    _searchDebounce?.cancel();
    
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      emit(state.copyWith(
        searchQuery: query,
        filteredSurahs: state.surahs,
        matchedPreviewBySurah: const {},
      ));
      return;
    }

    // 1. Local filter by name
    final filteredByName = state.surahs.where((surah) {
      return surah.nameAr.contains(normalizedQuery) ||
             surah.nameEn.toLowerCase().contains(normalizedQuery);
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredSurahs: filteredByName,
    ));

    // 2. Debounced Smart Search for content
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      final matches = await useCases.searchSurahs(normalizedQuery);
      
      if (isClosed) return;

      final previews = {
        for (final m in matches) m.surahNumber: m.preview,
      };

      // Merge results: surahs that match by name OR by content
      final matchedSurahNumbers = matches.map((m) => m.surahNumber).toSet();
      final surahsByContent = state.surahs.where((s) => matchedSurahNumbers.contains(s.number));
      
      final combined = {...filteredByName, ...surahsByContent}.toList();
      combined.sort((a, b) => a.number.compareTo(b.number));

      emit(state.copyWith(
        filteredSurahs: combined,
        matchedPreviewBySurah: previews,
      ));
    });
  }
  */

  @override
  Future<void> close() {
    // _searchDebounce?.cancel();
    return super.close();
  }

  /*
  void updateMatchedPreviews(Map<int, String> previews) {
    emit(state.copyWith(matchedPreviewBySurah: previews));
  }
  */

  static Map<int, QuranOfflineAvailability> _buildOfflineAvailability(
    List<QuranSurah> surahs,
    Map<int, String> localPageImagePaths,
  ) {
    final localPages = localPageImagePaths.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toSet();

    if (localPages.isEmpty || surahs.isEmpty) {
      return <int, QuranOfflineAvailability>{
        for (final surah in surahs) surah.number: QuranOfflineAvailability.none,
      };
    }

    final availabilityBySurah = <int, QuranOfflineAvailability>{};
    for (final surah in surahs) {
      final surahPages = surah.verses.map((verse) => verse.page).toSet();
      if (surahPages.isEmpty) {
        availabilityBySurah[surah.number] = QuranOfflineAvailability.none;
        continue;
      }

      final matchedPages = surahPages.where(localPages.contains).length;
      if (matchedPages == 0) {
        availabilityBySurah[surah.number] = QuranOfflineAvailability.none;
      } else if (matchedPages == surahPages.length) {
        availabilityBySurah[surah.number] = QuranOfflineAvailability.full;
      } else {
        availabilityBySurah[surah.number] = QuranOfflineAvailability.partial;
      }
    }
    return availabilityBySurah;
  }
}
