import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/home/domain/usecases/daily_ayah_use_cases.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._dailyAyahUseCases) : super(const HomeState());

  final DailyAyahUseCases _dailyAyahUseCases;

  Future<void> loadDailyContent() async {
    emit(state.copyWith(isLoadingAyah: true));
    try {
      final ayah = await _dailyAyahUseCases.getDailyAyah();
      emit(state.copyWith(
        dailyAyah: ayah,
        isLoadingAyah: false,
        dailyContentKey: state.dailyContentKey + 1,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingAyah: false));
    }
  }

  void refreshDailyContent() {
    loadDailyContent();
  }
}
