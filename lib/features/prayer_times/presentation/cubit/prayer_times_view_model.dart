import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

enum PrayerTimesViewType { loading, error, loaded, empty }

class PrayerTimesViewModel {
  const PrayerTimesViewModel({
    required this.type,
    this.loaded,
    this.errorMessage,
  });

  final PrayerTimesViewType type;
  final PrayerTimesLoaded? loaded;
  final String? errorMessage;

  static PrayerTimesViewModel fromState(PrayerTimesState state) {
    if (state is PrayerTimesLoading) {
      return const PrayerTimesViewModel(type: PrayerTimesViewType.loading);
    }
    if (state is PrayerTimesError) {
      return PrayerTimesViewModel(
        type: PrayerTimesViewType.error,
        errorMessage: state.message,
      );
    }
    if (state is PrayerTimesLoaded) {
      return PrayerTimesViewModel(
        type: PrayerTimesViewType.loaded,
        loaded: state,
      );
    }
    return const PrayerTimesViewModel(type: PrayerTimesViewType.empty);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PrayerTimesViewModel &&
        other.type == type &&
        other.loaded == loaded &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(type, loaded, errorMessage);
}
