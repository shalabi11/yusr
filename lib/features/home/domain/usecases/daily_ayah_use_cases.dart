import 'package:yusr_app/features/home/data/daily_ayah_repository.dart';

class DailyAyahUseCases {
  const DailyAyahUseCases(this._repository);

  final DailyAyahRepository _repository;

  Future<DailyAyah> getDailyAyah() {
    return _repository.getDailyAyah();
  }
}
