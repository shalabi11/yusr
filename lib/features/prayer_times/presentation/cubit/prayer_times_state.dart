part of 'prayer_times_cubit.dart';

abstract class PrayerTimesState extends Equatable {
  const PrayerTimesState();

  @override
  List<Object> get props => [];
}

class PrayerTimesInitial extends PrayerTimesState {}

class PrayerTimesLoading extends PrayerTimesState {}

class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimeModel prayerTimes;
  final String locationName;
  final DateTime lastUpdatedAt;
  final bool isFromCache;
  final String nextPrayerKey;
  final IconData nextPrayerIcon;
  final String countdownText;

  const PrayerTimesLoaded(
    this.prayerTimes,
    this.locationName,
    this.lastUpdatedAt,
    this.isFromCache,
    this.nextPrayerKey,
    this.nextPrayerIcon,
    this.countdownText,
  );

  PrayerTimesLoaded copyWith({
    PrayerTimeModel? prayerTimes,
    String? locationName,
    DateTime? lastUpdatedAt,
    bool? isFromCache,
    String? nextPrayerKey,
    IconData? nextPrayerIcon,
    String? countdownText,
  }) {
    return PrayerTimesLoaded(
      prayerTimes ?? this.prayerTimes,
      locationName ?? this.locationName,
      lastUpdatedAt ?? this.lastUpdatedAt,
      isFromCache ?? this.isFromCache,
      nextPrayerKey ?? this.nextPrayerKey,
      nextPrayerIcon ?? this.nextPrayerIcon,
      countdownText ?? this.countdownText,
    );
  }

  @override
  List<Object> get props => [
    prayerTimes,
    locationName,
    lastUpdatedAt,
    isFromCache,
    nextPrayerKey,
    nextPrayerIcon,
    countdownText,
  ];
}

class PrayerTimesError extends PrayerTimesState {
  final String message;

  const PrayerTimesError(this.message);

  @override
  List<Object> get props => [message];
}
