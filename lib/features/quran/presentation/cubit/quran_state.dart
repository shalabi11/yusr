import 'package:equatable/equatable.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/presentation/models/quran_offline_availability.dart';

enum QuranStatus { initial, loading, loaded, error }

class QuranState extends Equatable {
  const QuranState({
    this.status = QuranStatus.initial,
    this.surahs = const [],
    this.filteredSurahs = const [],
    this.lastRead,
    this.khatmaPlan,
    this.offlineAvailabilityBySurah = const {},
    // this.matchedPreviewBySurah = const {},
    // this.searchQuery = '',
    // this.isSearching = false,
    this.errorMessage,
  });

  final QuranStatus status;
  final List<QuranSurah> surahs;
  final List<QuranSurah> filteredSurahs;
  final QuranLastRead? lastRead;
  final KhatmaPlan? khatmaPlan;
  final Map<int, QuranOfflineAvailability> offlineAvailabilityBySurah;
  // final Map<int, String> matchedPreviewBySurah;
  // final String searchQuery;
  // final bool isSearching;
  final String? errorMessage;

  QuranState copyWith({
    QuranStatus? status,
    List<QuranSurah>? surahs,
    List<QuranSurah>? filteredSurahs,
    QuranLastRead? lastRead,
    KhatmaPlan? khatmaPlan,
    Map<int, QuranOfflineAvailability>? offlineAvailabilityBySurah,
    // Map<int, String>? matchedPreviewBySurah,
    // String? searchQuery,
    // bool? isSearching,
    String? errorMessage,
  }) {
    return QuranState(
      status: status ?? this.status,
      surahs: surahs ?? this.surahs,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
      lastRead: lastRead ?? this.lastRead,
      khatmaPlan: khatmaPlan ?? this.khatmaPlan,
      offlineAvailabilityBySurah: offlineAvailabilityBySurah ?? this.offlineAvailabilityBySurah,
      // matchedPreviewBySurah: matchedPreviewBySurah ?? this.matchedPreviewBySurah,
      // searchQuery: searchQuery ?? this.searchQuery,
      // isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        surahs,
        filteredSurahs,
        lastRead,
        khatmaPlan,
        offlineAvailabilityBySurah,
        // matchedPreviewBySurah,
        // searchQuery,
        // isSearching,
        errorMessage,
      ];
}
