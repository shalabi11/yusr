import 'package:yusr_app/features/adhkar/data/models/adhkar_models.dart';
import 'package:yusr_app/features/adhkar/data/repositories/adhkar_repository.dart';

class AdhkarUseCases {
  const AdhkarUseCases(this._repository);

  final AdhkarRepository _repository;

  Future<List<AdhkarCategory>> loadCategories() {
    return _repository.loadCategories();
  }
}
