import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'حدث خطأ في التخزين المحلي']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'تعذر تحديد الموقع']);
}
