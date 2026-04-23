import 'package:equatable/equatable.dart';
import 'package:yusr_app/features/home/data/daily_ayah_repository.dart';

class HomeState extends Equatable {
  const HomeState({
    this.dailyContentKey = 0,
    this.dailyAyah,
    this.isLoadingAyah = false,
  });

  final int dailyContentKey;
  final DailyAyah? dailyAyah;
  final bool isLoadingAyah;

  HomeState copyWith({
    int? dailyContentKey,
    DailyAyah? dailyAyah,
    bool? isLoadingAyah,
  }) {
    return HomeState(
      dailyContentKey: dailyContentKey ?? this.dailyContentKey,
      dailyAyah: dailyAyah ?? this.dailyAyah,
      isLoadingAyah: isLoadingAyah ?? this.isLoadingAyah,
    );
  }

  @override
  List<Object?> get props => [dailyContentKey, dailyAyah, isLoadingAyah];
}
