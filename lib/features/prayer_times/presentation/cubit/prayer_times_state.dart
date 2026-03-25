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

  const PrayerTimesLoaded(
    this.prayerTimes,
    this.locationName,
    this.lastUpdatedAt,
    this.isFromCache,
  );

  @override
  List<Object> get props => [
    prayerTimes,
    locationName,
    lastUpdatedAt,
    isFromCache,
  ];
}

class PrayerTimesError extends PrayerTimesState {
  final String message;

  const PrayerTimesError(this.message);

  @override
  List<Object> get props => [message];
}
